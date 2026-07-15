from datetime import datetime
from fastapi import APIRouter, HTTPException, Depends
from beanie import PydanticObjectId
from beanie.odm.fields import ExpressionField
from app.models.dose_log import DoseLog, DoseLogCreate
from app.models.supplement import Supplement
from app.models.response import APIResponse
from app.models.user import User
from app.core.deps import get_current_user

router = APIRouter(prefix="/dose-logs", tags=["dose-logs"])


@router.post("", response_model=APIResponse)
async def create_dose_log(log: DoseLogCreate, current_user: User = Depends(get_current_user)):
    # Verify supplement exists and belongs to user
    try:
        sid = PydanticObjectId(log.supplement_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid supplement ID")
    supplement = await Supplement.get(sid)
    if not supplement:
        raise HTTPException(status_code=404, detail="Supplement not found")
    if supplement.user_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")
    
    # Decrement stock
    if supplement.stock_count > 0:
        supplement.stock_count -= 1
        await supplement.save()
    
    new_log = DoseLog(**log.model_dump(), user_id=str(current_user.id))
    await new_log.insert()
    return APIResponse(success=True, data=new_log.model_dump(), message="Dose logged")


@router.delete("/{supplement_id}/{date}", response_model=APIResponse)
async def remove_dose_log(supplement_id: str, date: str, current_user: User = Depends(get_current_user)):
    # Find and delete the dose log
    log = await DoseLog.find_one(
        ExpressionField("supplement_id") == supplement_id,
        ExpressionField("date") == date,
        ExpressionField("user_id") == str(current_user.id)
    )
    if not log:
        raise HTTPException(status_code=404, detail="Dose log not found")
    
    # Restore stock
    try:
        sid = PydanticObjectId(supplement_id)
        supplement = await Supplement.get(sid)
        if supplement and supplement.user_id == str(current_user.id):
            supplement.stock_count += 1
            await supplement.save()
    except Exception:
        pass
    
    await log.delete()
    return APIResponse(success=True, message="Dose log removed")


@router.get("/supplement/{supplement_id}", response_model=APIResponse)
async def get_logs_for_supplement(supplement_id: str, current_user: User = Depends(get_current_user)):
    # Verify ownership
    try:
        sid = PydanticObjectId(supplement_id)
        supplement = await Supplement.get(sid)
        if not supplement or supplement.user_id != str(current_user.id):
            raise HTTPException(status_code=403, detail="Not authorized")
    except HTTPException:
        raise
    except Exception:
        pass
    
    logs = await DoseLog.find(
        ExpressionField("supplement_id") == supplement_id,
        ExpressionField("user_id") == str(current_user.id)
    ).to_list()
    return APIResponse(success=True, data=[l.model_dump() for l in logs])


@router.get("/today/{date}", response_model=APIResponse)
async def get_today_logs(date: str, current_user: User = Depends(get_current_user)):
    logs = await DoseLog.find(
        ExpressionField("date") == date,
        ExpressionField("user_id") == str(current_user.id)
    ).to_list()
    return APIResponse(success=True, data=[l.model_dump() for l in logs])
