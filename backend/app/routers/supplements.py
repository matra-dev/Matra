from typing import List
from fastapi import APIRouter, HTTPException
from beanie import PydanticObjectId
from app.models.supplement import Supplement, SupplementCreate, SupplementUpdate
from app.models.dose_log import DoseLog
from app.models.response import APIResponse

router = APIRouter(prefix="/supplements", tags=["supplements"])


@router.post("", response_model=APIResponse)
async def create_supplement(supplement: SupplementCreate):
    new_supp = Supplement(**supplement.model_dump())
    await new_supp.insert()
    return APIResponse(success=True, data=new_supp.model_dump(), message="Supplement created")


@router.get("", response_model=APIResponse)
async def get_all_supplements():
    supplements = await Supplement.find_all().to_list()
    return APIResponse(success=True, data=[s.model_dump() for s in supplements])


@router.get("/{supplement_id}", response_model=APIResponse)
async def get_supplement(supplement_id: str):
    try:
        sid = PydanticObjectId(supplement_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid supplement ID")
    supplement = await Supplement.get(sid)
    if not supplement:
        raise HTTPException(status_code=404, detail="Supplement not found")
    return APIResponse(success=True, data=supplement.model_dump())


@router.put("/{supplement_id}", response_model=APIResponse)
async def update_supplement(supplement_id: str, update: SupplementUpdate):
    try:
        sid = PydanticObjectId(supplement_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid supplement ID")
    supplement = await Supplement.get(sid)
    if not supplement:
        raise HTTPException(status_code=404, detail="Supplement not found")
    update_data = {k: v for k, v in update.model_dump().items() if v is not None}
    for key, value in update_data.items():
        setattr(supplement, key, value)
    await supplement.save()
    return APIResponse(success=True, data=supplement.model_dump(), message="Supplement updated")


@router.delete("/{supplement_id}", response_model=APIResponse)
async def delete_supplement(supplement_id: str):
    try:
        sid = PydanticObjectId(supplement_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid supplement ID")
    supplement = await Supplement.get(sid)
    if not supplement:
        raise HTTPException(status_code=404, detail="Supplement not found")
    # Cascade delete dose logs
    await DoseLog.find(DoseLog.supplement_id == supplement_id).delete_many()
    await supplement.delete()
    return APIResponse(success=True, message="Supplement and associated logs deleted")
