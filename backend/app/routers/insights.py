from datetime import datetime, timedelta
from typing import List, Dict, Any
from fastapi import APIRouter, Depends
from beanie.odm.fields import ExpressionField
from beanie import PydanticObjectId

from app.models.user import User
from app.models.supplement import Supplement
from app.models.dose_log import DoseLog
from app.models.response import APIResponse
from app.core.deps import get_current_user

router = APIRouter(prefix="/insights", tags=["insights"])


def _get_date_range(days: int) -> tuple:
    """Get date range for last N days."""
    end = datetime.now()
    start = end - timedelta(days=days)
    return start.strftime("%Y-%m-%d"), end.strftime("%Y-%m-%d")


def _get_week_start(date_str: str) -> str:
    """Get Monday of the week for a given date."""
    dt = datetime.strptime(date_str, "%Y-%m-%d")
    monday = dt - timedelta(days=dt.weekday())
    return monday.strftime("%Y-%m-%d")


@router.get("/dashboard", response_model=APIResponse)
async def get_dashboard_insights(current_user: User = Depends(get_current_user)):
    """Get all dashboard metrics for the current user."""
    user_id = str(current_user.id)

    # Get all user's supplements and logs
    supplements = await Supplement.find(ExpressionField("user_id") == user_id).to_list()
    all_logs = await DoseLog.find(ExpressionField("user_id") == user_id).to_list()

    # Build date-indexed log lookup
    logs_by_date: Dict[str, List[DoseLog]] = {}
    logs_by_supplement: Dict[str, List[DoseLog]] = {}
    for log in all_logs:
        logs_by_date.setdefault(log.date, []).append(log)
        logs_by_supplement.setdefault(log.supplement_id, []).append(log)

    # Calculate adherence
    total_expected = 0
    total_taken = 0
    perfect_days = 0
    missed_doses = 0

    # Get last 30 days
    today = datetime.now()
    date_strs = [(today - timedelta(days=i)).strftime("%Y-%m-%d") for i in range(30)]

    daily_adherence = []
    for date_str in reversed(date_strs):
        day_logs = logs_by_date.get(date_str, [])
        taken_ids = {log.supplement_id for log in day_logs}

        expected = 0
        taken = 0
        for supp in supplements:
            # Check if supplement was active on this date
            if supp.start_date <= date_str:
                expected += 1
                if supp.id in taken_ids:
                    taken += 1

        total_expected += expected
        total_taken += taken
        missed = expected - taken
        missed_doses += missed

        if expected > 0:
            adherence = (taken / expected) * 100
            if adherence >= 100:
                perfect_days += 1
        else:
            adherence = 0

        daily_adherence.append({
            "date": date_str,
            "expected": expected,
            "taken": taken,
            "adherence": round(adherence, 1),
            "perfect": expected > 0 and taken >= expected,
        })

    # Weekly breakdown (last 7 days)
    weekly = []
    for i in range(6, -1, -1):
        date_str = (today - timedelta(days=i)).strftime("%Y-%m-%d")
        day_logs = logs_by_date.get(date_str, [])
        taken_ids = {log.supplement_id for log in day_logs}

        expected = sum(1 for s in supplements if s.start_date <= date_str)
        taken = sum(1 for s in supplements if s.id in taken_ids and s.start_date <= date_str)

        weekly.append({
            "day": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][(today - timedelta(days=i)).weekday()],
            "date": date_str,
            "total": max(expected, 1),
            "taken": taken,
            "adherence": round((taken / max(expected, 1)) * 100) if expected > 0 else 0,
        })

    # Streak calculation
    streak = 0
    for day in reversed(daily_adherence):
        if day["perfect"]:
            streak += 1
        elif day["expected"] > 0:
            break

    # Overall adherence
    overall_adherence = round((total_taken / max(total_expected, 1)) * 100, 1)

    # Stock alerts
    low_stock = [s.model_dump() for s in supplements if s.stock_count <= 5]

    return APIResponse(
        success=True,
        data={
            "overall_adherence": overall_adherence,
            "perfect_days": perfect_days,
            "missed_doses": missed_doses,
            "current_streak": streak,
            "total_supplements": len(supplements),
            "total_doses_logged": len(all_logs),
            "weekly_breakdown": weekly,
            "daily_adherence": daily_adherence[-7:],  # Last 7 days
            "low_stock": low_stock,
        }
    )


@router.get("/supplement/{supplement_id}", response_model=APIResponse)
async def get_supplement_insights(
    supplement_id: str,
    current_user: User = Depends(get_current_user)
):
    """Get insights for a specific supplement."""
    user_id = str(current_user.id)

    # Verify ownership
    try:
        sid = PydanticObjectId(supplement_id)
        supplement = await Supplement.get(sid)
        if not supplement or supplement.user_id != user_id:
            return APIResponse(success=False, error="Not authorized")
    except Exception:
        return APIResponse(success=False, error="Invalid supplement ID")

    # Get logs for this supplement
    logs = await DoseLog.find(
        ExpressionField("supplement_id") == supplement_id,
        ExpressionField("user_id") == user_id
    ).to_list()

    # Calculate last 30 days adherence
    today = datetime.now()
    daily = []
    for i in range(29, -1, -1):
        date_str = (today - timedelta(days=i)).strftime("%Y-%m-%d")
        taken = any(log.date == date_str for log in logs)
        daily.append({
            "date": date_str,
            "taken": taken,
            "day": (today - timedelta(days=i)).day,
        })

    total_taken = sum(1 for d in daily if d["taken"])
    adherence = round((total_taken / 30) * 100, 1)

    # Weekly trend (last 4 weeks)
    weekly_trend = []
    for week in range(3, -1, -1):
        week_start = today - timedelta(days=week * 7 + today.weekday())
        week_taken = 0
        for day in range(7):
            date_str = (week_start + timedelta(days=day)).strftime("%Y-%m-%d")
            if any(log.date == date_str for log in logs):
                week_taken += 1
        weekly_trend.append({
            "week": f"W{4 - week}",
            "taken": week_taken,
            "total": 7,
        })

    return APIResponse(
        success=True,
        data={
            "supplement": supplement.model_dump(),
            "adherence_30d": adherence,
            "doses_taken": total_taken,
            "daily_log": daily,
            "weekly_trend": weekly_trend,
            "stock_remaining": supplement.stock_count,
            "days_since_start": (today - datetime.strptime(supplement.start_date, "%Y-%m-%d")).days,
        }
    )


@router.get("/trends", response_model=APIResponse)
async def get_trends(current_user: User = Depends(get_current_user)):
    """Get adherence trend data for charting."""
    user_id = str(current_user.id)

    supplements = await Supplement.find(ExpressionField("user_id") == user_id).to_list()
    all_logs = await DoseLog.find(ExpressionField("user_id") == user_id).to_list()

    logs_by_date: Dict[str, List[str]] = {}
    for log in all_logs:
        logs_by_date.setdefault(log.date, []).append(log.supplement_id)

    # Last 16 days for trend chart
    today = datetime.now()
    trend = []
    for i in range(15, -1, -1):
        date_str = (today - timedelta(days=i)).strftime("%Y-%m-%d")
        taken_ids = set(logs_by_date.get(date_str, []))

        expected = sum(1 for s in supplements if s.start_date <= date_str)
        taken = sum(1 for s in supplements if s.id in taken_ids and s.start_date <= date_str)

        adherence = round((taken / max(expected, 1)) * 100) if expected > 0 else 0
        trend.append({
            "day": (today - timedelta(days=i)).day,
            "adherence": adherence,
        })

    return APIResponse(success=True, data={"trend": trend})
