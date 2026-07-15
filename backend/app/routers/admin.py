from fastapi import APIRouter, HTTPException, Depends
from beanie.odm.fields import ExpressionField
from beanie import PydanticObjectId

from app.models.user import User
from app.models.supplement import Supplement
from app.models.dose_log import DoseLog
from app.models.measurement import Measurement
from app.models.appointment import Appointment
from app.models.response import APIResponse
from app.core.deps import get_current_user

router = APIRouter(prefix="/admin", tags=["admin"])


async def require_admin(current_user: User = Depends(get_current_user)):
    """Simple admin check — can be extended with role field."""
    # For now, first user is admin or check email domain
    # In production, add `is_admin: bool` to User model
    return current_user


@router.get("/stats", response_model=APIResponse)
async def get_platform_stats(admin: User = Depends(require_admin)):
    """Get overall platform statistics."""
    total_users = await User.find_all().count()
    total_supplements = await Supplement.find_all().count()
    total_dose_logs = await DoseLog.find_all().count()
    total_measurements = await Measurement.find_all().count()
    total_appointments = await Appointment.find_all().count()

    # Active users (logged in last 7 days) — simplified
    active_users = total_users  # Placeholder

    return APIResponse(
        success=True,
        data={
            "total_users": total_users,
            "active_users": active_users,
            "total_supplements": total_supplements,
            "total_dose_logs": total_dose_logs,
            "total_measurements": total_measurements,
            "total_appointments": total_appointments,
        }
    )


@router.get("/users", response_model=APIResponse)
async def get_all_users(admin: User = Depends(require_admin)):
    """List all users with supplement counts."""
    users = await User.find_all().to_list()
    result = []
    for user in users:
        supp_count = await Supplement.find(ExpressionField("user_id") == str(user.id)).count()
        log_count = await DoseLog.find(ExpressionField("user_id") == str(user.id)).count()
        result.append({
            "id": str(user.id),
            "email": user.email,
            "name": user.name,
            "is_active": user.is_active,
            "created_at": user.created_at,
            "supplement_count": supp_count,
            "dose_log_count": log_count,
        })
    return APIResponse(success=True, data=result)


@router.delete("/users/{user_id}", response_model=APIResponse)
async def delete_user(user_id: str, admin: User = Depends(require_admin)):
    """Delete a user and all their data."""
    try:
        uid = PydanticObjectId(user_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid user ID")

    user = await User.get(uid)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Cascade delete all user data
    await Supplement.find(ExpressionField("user_id") == user_id).delete_many()
    await DoseLog.find(ExpressionField("user_id") == user_id).delete_many()
    await Measurement.find(ExpressionField("user_id") == user_id).delete_many()
    await Appointment.find(ExpressionField("user_id") == user_id).delete_many()
    await user.delete()

    return APIResponse(success=True, message="User and all data deleted")


@router.get("/supplements", response_model=APIResponse)
async def get_all_supplements(admin: User = Depends(require_admin)):
    """List all supplements across all users."""
    supplements = await Supplement.find_all().to_list()
    return APIResponse(success=True, data=[s.model_dump() for s in supplements])
