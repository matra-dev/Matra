from datetime import datetime
from fastapi import APIRouter, HTTPException, Depends
from beanie.odm.fields import ExpressionField
from app.models.calorie_log import CalorieLog, CalorieLogCreate
from app.models.response import APIResponse
from app.models.user import User
from app.core.deps import get_current_user

router = APIRouter(prefix="/calorie-logs", tags=["calorie-logs"])


def _serialize_calorie_log(log: CalorieLog) -> dict:
    """Convert calorie log to JSON-serializable dict with string IDs."""
    data = log.model_dump(mode='json')
    data['id'] = str(log.id)
    return data


@router.post("", response_model=APIResponse)
async def create_calorie_log(log: CalorieLogCreate, current_user: User = Depends(get_current_user)):
    new_log = CalorieLog(**log.model_dump(), user_id=str(current_user.id))
    await new_log.insert()
    return APIResponse(success=True, data=_serialize_calorie_log(new_log), message="Calorie intake logged")


@router.delete("/{log_id}", response_model=APIResponse)
async def delete_calorie_log(log_id: str, current_user: User = Depends(get_current_user)):
    log = await CalorieLog.find_one(
        ExpressionField("_id") == log_id,
        ExpressionField("user_id") == str(current_user.id)
    )
    if not log:
        raise HTTPException(status_code=404, detail="Calorie log not found")
    await log.delete()
    return APIResponse(success=True, message="Calorie log deleted")


@router.get("/today/{date}", response_model=APIResponse)
async def get_today_calorie_logs(date: str, current_user: User = Depends(get_current_user)):
    logs = await CalorieLog.find(
        ExpressionField("date") == date,
        ExpressionField("user_id") == str(current_user.id)
    ).to_list()
    return APIResponse(success=True, data=[_serialize_calorie_log(l) for l in logs])


@router.get("/range/{start_date}/{end_date}", response_model=APIResponse)
async def get_calorie_logs_range(start_date: str, end_date: str, current_user: User = Depends(get_current_user)):
    logs = await CalorieLog.find(
        ExpressionField("date") >= start_date,
        ExpressionField("date") <= end_date,
        ExpressionField("user_id") == str(current_user.id)
    ).to_list()
    return APIResponse(success=True, data=[_serialize_calorie_log(l) for l in logs])
