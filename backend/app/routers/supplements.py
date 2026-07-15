from fastapi import APIRouter, HTTPException, Depends
from beanie.odm.fields import ExpressionField
from beanie import PydanticObjectId
from app.models.supplement import Supplement, SupplementCreate, SupplementUpdate
from app.models.dose_log import DoseLog
from app.models.response import APIResponse
from app.models.user import User
from app.core.deps import get_current_user

router = APIRouter(prefix="/supplements", tags=["supplements"])


@router.post("", response_model=APIResponse)
async def create_supplement(supplement: SupplementCreate, current_user: User = Depends(get_current_user)):
    new_supp = Supplement(**supplement.model_dump(), user_id=str(current_user.id))
    await new_supp.insert()
    return APIResponse(success=True, data=new_supp.model_dump(), message="Supplement created")


@router.get("", response_model=APIResponse)
async def get_all_supplements(current_user: User = Depends(get_current_user)):
    supplements = await Supplement.find(ExpressionField("user_id") == str(current_user.id)).to_list()
    return APIResponse(success=True, data=[s.model_dump() for s in supplements])


@router.get("/{supplement_id}", response_model=APIResponse)
async def get_supplement(supplement_id: str, current_user: User = Depends(get_current_user)):
    try:
        sid = PydanticObjectId(supplement_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid supplement ID")
    supplement = await Supplement.get(sid)
    if not supplement:
        raise HTTPException(status_code=404, detail="Supplement not found")
    if supplement.user_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")
    return APIResponse(success=True, data=supplement.model_dump())


@router.put("/{supplement_id}", response_model=APIResponse)
async def update_supplement(supplement_id: str, update: SupplementUpdate, current_user: User = Depends(get_current_user)):
    try:
        sid = PydanticObjectId(supplement_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid supplement ID")
    supplement = await Supplement.get(sid)
    if not supplement:
        raise HTTPException(status_code=404, detail="Supplement not found")
    if supplement.user_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")
    update_data = {k: v for k, v in update.model_dump().items() if v is not None}
    for key, value in update_data.items():
        setattr(supplement, key, value)
    await supplement.save()
    return APIResponse(success=True, data=supplement.model_dump(), message="Supplement updated")


@router.delete("/{supplement_id}", response_model=APIResponse)
async def delete_supplement(supplement_id: str, current_user: User = Depends(get_current_user)):
    try:
        sid = PydanticObjectId(supplement_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid supplement ID")
    supplement = await Supplement.get(sid)
    if not supplement:
        raise HTTPException(status_code=404, detail="Supplement not found")
    if supplement.user_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")
    # Cascade delete dose logs
    await DoseLog.find(ExpressionField("supplement_id") == supplement_id, ExpressionField("user_id") == str(current_user.id)).delete_many()
    await supplement.delete()
    return APIResponse(success=True, message="Supplement and associated logs deleted")
