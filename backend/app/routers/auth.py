from fastapi import APIRouter, HTTPException, Depends
from app.core.security import create_access_token, get_password_hash
from app.core.deps import get_current_user
from app.models.user import User, UserCreate, UserLogin
from app.models.response import APIResponse

router = APIRouter(prefix="/auth", tags=["auth"])


from beanie.odm.fields import ExpressionField

@router.post("/register", response_model=APIResponse)
async def register(user_data: UserCreate):
    # Check if user exists
    existing = await User.find_one(ExpressionField("email") == user_data.email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Create user
    user = User(
        email=user_data.email,
        name=user_data.name,
        hashed_password=get_password_hash(user_data.password),
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
            "name": current_user.name,
        }
    )
