from fastapi import APIRouter, HTTPException, Depends
from beanie.odm.fields import ExpressionField
from beanie import PydanticObjectId
from typing import Optional

from app.models.appointment import Appointment, AppointmentCreate, AppointmentUpdate
from app.models.response import APIResponse
from app.models.user import User
from app.core.deps import get_current_user

router = APIRouter(prefix="/appointments", tags=["appointments"])


@router.post("", response_model=APIResponse)
async def create_appointment(appointment: AppointmentCreate, current_user: User = Depends(get_current_user)):
    new_a = Appointment(**appointment.model_dump(), user_id=str(current_user.id))
    await new_a.insert()
    return APIResponse(success=True, data=new_a.model_dump(), message="Appointment scheduled")


@router.get("", response_model=APIResponse)
async def get_all_appointments(current_user: User = Depends(get_current_user)):
    appointments = await Appointment.find(ExpressionField("user_id") == str(current_user.id)).to_list()
    return APIResponse(success=True, data=[a.model_dump() for a in appointments])


@router.get("/{appointment_id}", response_model=APIResponse)
async def get_appointment(appointment_id: str, current_user: User = Depends(get_current_user)):
    try:
        aid = PydanticObjectId(appointment_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid appointment ID")
    appointment = await Appointment.get(aid)
    if not appointment or appointment.user_id != str(current_user.id):
        raise HTTPException(status_code=404, detail="Appointment not found")
    return APIResponse(success=True, data=appointment.model_dump())


@router.put("/{appointment_id}", response_model=APIResponse)
async def update_appointment(appointment_id: str, update: AppointmentUpdate, current_user: User = Depends(get_current_user)):
    try:
        aid = PydanticObjectId(appointment_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid appointment ID")
    appointment = await Appointment.get(aid)
    if not appointment or appointment.user_id != str(current_user.id):
        raise HTTPException(status_code=404, detail="Appointment not found")
    update_data = {k: v for k, v in update.model_dump().items() if v is not None}
    for key, value in update_data.items():
        setattr(appointment, key, value)
    await appointment.save()
    return APIResponse(success=True, data=appointment.model_dump(), message="Appointment updated")


@router.delete("/{appointment_id}", response_model=APIResponse)
async def delete_appointment(appointment_id: str, current_user: User = Depends(get_current_user)):
    try:
        aid = PydanticObjectId(appointment_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid appointment ID")
    appointment = await Appointment.get(aid)
    if not appointment or appointment.user_id != str(current_user.id):
        raise HTTPException(status_code=404, detail="Appointment not found")
    await appointment.delete()
    return APIResponse(success=True, message="Appointment cancelled")
