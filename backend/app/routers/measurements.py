from fastapi import APIRouter, HTTPException, Depends
from beanie.odm.fields import ExpressionField
from beanie import PydanticObjectId
from typing import Optional

from app.models.measurement import Measurement, MeasurementCreate, MeasurementUpdate
from app.models.response import APIResponse
from app.models.user import User
from app.core.deps import get_current_user

router = APIRouter(prefix="/measurements", tags=["measurements"])


@router.post("", response_model=APIResponse)
async def create_measurement(measurement: MeasurementCreate, current_user: User = Depends(get_current_user)):
    new_m = Measurement(**measurement.model_dump(), user_id=str(current_user.id))
    await new_m.insert()
    return APIResponse(success=True, data=new_m.model_dump(), message="Measurement recorded")


@router.get("", response_model=APIResponse)
async def get_all_measurements(current_user: User = Depends(get_current_user)):
    measurements = await Measurement.find(ExpressionField("user_id") == str(current_user.id)).to_list()
    return APIResponse(success=True, data=[m.model_dump() for m in measurements])


@router.get("/{measurement_id}", response_model=APIResponse)
async def get_measurement(measurement_id: str, current_user: User = Depends(get_current_user)):
    try:
        mid = PydanticObjectId(measurement_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid measurement ID")
    measurement = await Measurement.get(mid)
    if not measurement or measurement.user_id != str(current_user.id):
        raise HTTPException(status_code=404, detail="Measurement not found")
    return APIResponse(success=True, data=measurement.model_dump())


@router.put("/{measurement_id}", response_model=APIResponse)
async def update_measurement(measurement_id: str, update: MeasurementUpdate, current_user: User = Depends(get_current_user)):
    try:
        mid = PydanticObjectId(measurement_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid measurement ID")
    measurement = await Measurement.get(mid)
    if not measurement or measurement.user_id != str(current_user.id):
        raise HTTPException(status_code=404, detail="Measurement not found")
    update_data = {k: v for k, v in update.model_dump().items() if v is not None}
    for key, value in update_data.items():
        setattr(measurement, key, value)
    await measurement.save()
    return APIResponse(success=True, data=measurement.model_dump(), message="Measurement updated")


@router.delete("/{measurement_id}", response_model=APIResponse)
async def delete_measurement(measurement_id: str, current_user: User = Depends(get_current_user)):
    try:
        mid = PydanticObjectId(measurement_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid measurement ID")
    measurement = await Measurement.get(mid)
    if not measurement or measurement.user_id != str(current_user.id):
        raise HTTPException(status_code=404, detail="Measurement not found")
    await measurement.delete()
    return APIResponse(success=True, message="Measurement deleted")
