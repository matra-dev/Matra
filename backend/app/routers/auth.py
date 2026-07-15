from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from app.core.security import create_access_token, get_password_hash
from app.core.deps import get_current_user
from app.models.user import User, UserCreate, UserLogin
from app.models.response import APIResponse
from app.services.otp_service import send_otp, verify_otp

router = APIRouter(prefix="/auth", tags=["auth"])


from beanie.odm.fields import ExpressionField


# ─── OTP Schemas ─────────────────────────────────────────────────────────────

class SendOTPRequest(BaseModel):
    phone: str = Field(..., min_length=6, max_length=15)
    country_code: str = Field(default="+91", max_length=5)


class VerifyOTPRequest(BaseModel):
    phone: str = Field(..., min_length=6, max_length=15)
    country_code: str = Field(default="+91", max_length=5)
    otp: str = Field(..., min_length=6, max_length=6)
    name: str = Field(default="", max_length=100)


# ─── Existing Email Auth ───────────────────────────────────────────────────

@router.post("/register", response_model=APIResponse)
async def register(user_data: UserCreate):
    # Check if user exists by email
    if user_data.email:
        existing = await User.find_one(ExpressionField("email") == user_data.email)
        if existing:
            raise HTTPException(status_code=400, detail="Email already registered")
    
    # Create user
    user = User(
        email=user_data.email,
        name=user_data.name,
        hashed_password=get_password_hash(user_data.password) if user_data.password else None,
    )
    await user.insert()
    
    # Generate token
    token = create_access_token({"sub": str(user.id)})
    
    return APIResponse(
        success=True,
        data={
            "token": token,
            "user": {
                "id": str(user.id),
                "email": user.email,
                "name": user.name,
            }
        },
        message="User registered successfully"
    )


@router.post("/login", response_model=APIResponse)
async def login(credentials: UserLogin):
    user = await User.find_one(ExpressionField("email") == credentials.email)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    if not user.verify_password(credentials.password):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    token = create_access_token({"sub": str(user.id)})
    
    return APIResponse(
        success=True,
        data={
            "token": token,
            "user": {
                "id": str(user.id),
                "email": user.email,
                "name": user.name,
            }
        },
        message="Login successful"
    )


@router.get("/me", response_model=APIResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    return APIResponse(
        success=True,
        data={
            "id": str(current_user.id),
            "email": current_user.email,
            "phone": current_user.phone,
            "name": current_user.name,
        }
    )


# ─── Phone OTP Auth ──────────────────────────────────────────────────────────

@router.post("/send-otp", response_model=APIResponse)
async def send_otp_endpoint(request: SendOTPRequest):
    """
    Send OTP to the given phone number via Fast2SMS.
    In demo mode, OTP is printed to console instead of sent.
    """
    result = send_otp(request.phone, request.country_code)
    
    if result["success"]:
        return APIResponse(
            success=True,
            data={"expires_in": result.get("expires_in", 300)},
            message=result["message"],
        )
    else:
        raise HTTPException(status_code=429, detail=result["message"])


@router.post("/verify-otp", response_model=APIResponse)
async def verify_otp_endpoint(request: VerifyOTPRequest):
    """
    Verify OTP and login/register the user.
    If user doesn't exist, creates a new account.
    """
    # Verify the OTP
    result = verify_otp(request.phone, request.country_code, request.otp)
    
    if not result["success"]:
        raise HTTPException(status_code=401, detail=result["message"])
    
    # OTP is valid - find or create user
    full_phone = f"{request.country_code}{request.phone.lstrip('+').lstrip('0')}"
    
    user = await User.find_one(ExpressionField("phone") == full_phone)
    
    is_new_user = False
    if not user:
        # Create new user
        user = User(
            phone=full_phone,
            country_code=request.country_code,
            name=request.name or None,
            hashed_password=None,  # No password for OTP users
        )
        await user.insert()
        is_new_user = True
    
    # Generate token
    token = create_access_token({"sub": str(user.id)})
    
    return APIResponse(
        success=True,
        data={
            "token": token,
            "user": {
                "id": str(user.id),
                "phone": user.phone,
                "name": user.name,
            },
            "is_new_user": is_new_user,
        },
        message="Login successful" if not is_new_user else "Account created successfully"
    )
