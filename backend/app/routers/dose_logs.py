from datetime import datetime
from fastapi import APIRouter, HTTPException
from beanie import PydanticObjectId
from app.models.dose_log import DoseLog, DoseLogCreate
from app.models.supplement import Supplement
from app.models.response import APIResponse

router = APIRouter(prefix="/dose-logs", tags=["dose-logs"])


@router.post("", response_model=APIResponse)
async def create_dose_log(log: DoseLogCreate):
    # Verify supplement exists
    try:
        sid = PydanticObjectId(log.supplement_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid supplement ID")
    supplement = await Supplement.get(sid)
    if not supplement:
        raise HTTPException(status_code=404, detail="Supplement not found")
    
    # Decrement stock
    if supplement.stock_count > 0:
        supplement.stock_count -= 1
        await supplement.save()
    
    new_log = DoseLog(**log.model_dump())
    await new_log.insert()
    return APIResponse(success=True, data=new_log.model_dump(), message="Dose logged")


@router.delete("/{supplement_id}/{date}", response_model=APIResponse)
async def remove_dose_log(supplement_id: str, date: str):
    # Find and delete the dose log
    log = await DoseLog.find_one(
        DoseLog.supplement_id == supplement_id,
        DoseLog.date == date
    )
    if not log:
        raise HTTPException(status_code=404, detail="Dose log not found")
    
    # Restore stock
    try:
        sid = PydanticObjectId(supplement_id)
        supplement = await Supplement.get(sid)
        if supplement:
            supplement.stock_count += 1
            await supplement.save()
    except Exception:
        pass
    
    await log.delete()
    return APIResponse(success=True, message="Dose log removed")


@router.get("/supplement/{supplement_id}", response_model=APIResponse)
async def get_logs_for_supplement(supplement_id: str):
    logs = await DoseLog.find(DoseLog.supplement_id == supplement_id).to_list()
    return APIResponse(success=True, data=[l.model_dump() for l in logs])


@router.get("/today/{date}", response_model=APIResponse)
async def get_today_logs(date: str):
    logs = await DoseLog.find(DoseLog.date == date).to_list()
    return APIResponse(success=True, data=[l.model_dump() for l in logs])
