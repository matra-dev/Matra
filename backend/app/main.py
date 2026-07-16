import os
import asyncio
from contextlib import asynccontextmanager
from datetime import datetime
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie
from dotenv import load_dotenv

from app.models.supplement import Supplement
from app.models.dose_log import DoseLog
from app.models.user import User
from app.models.measurement import Measurement
from app.models.appointment import Appointment
from app.models.water_log import WaterLog
from app.models.calorie_log import CalorieLog
from app.routers import supplements, dose_logs, auth, insights, measurements, appointments, admin, water_logs, calorie_logs

load_dotenv()

MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DB_NAME = os.getenv("DB_NAME", "stacksense")

# ─── Keep-Alive: Prevents Render Free Tier Spin-Down ────────────────────────
# Render free tier spins down after 15 min of inactivity.
# This self-pinger hits /health every 14 minutes to keep the service alive.
# Also acts as a health monitor — logs if the service becomes unreachable.

_KEEP_ALIVE_INTERVAL = 14 * 60  # 14 minutes (Render spins down after 15)
_KEEP_ALIVE_URL = os.getenv("RENDER_EXTERNAL_URL")  # Auto-set by Render
_KEEP_ALIVE_ENABLED = os.getenv("KEEP_ALIVE_ENABLED", "true").lower() == "true"


async def _self_ping_loop():
    """Background task that pings /health every 14 minutes to prevent spin-down."""
    import aiohttp

    url = _KEEP_ALIVE_URL
    if not url:
        # Fallback: try to construct from known Render pattern
        service_name = os.getenv("RENDER_SERVICE_NAME", "matra")
        url = f"https://{service_name}.onrender.com/health"

    ping_url = f"{url.rstrip('/')}/health"

    while True:
        await asyncio.sleep(_KEEP_ALIVE_INTERVAL)
        try:
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=10)) as session:
                async with session.get(ping_url) as resp:
                    if resp.status == 200:
                        print(f"[{datetime.now().isoformat()}] Keep-alive ping OK: {ping_url}")
                    else:
                        print(f"[{datetime.now().isoformat()}] Keep-alive ping returned {resp.status}")
        except Exception as e:
            print(f"[{datetime.now().isoformat()}] Keep-alive ping failed: {e}")


@asynccontextmanager
async def lifespan(app: FastAPI):
    client = AsyncIOMotorClient(MONGODB_URL)
    await init_beanie(
        database=client[DB_NAME],
        document_models=[Supplement, DoseLog, User, Measurement, Appointment, WaterLog, CalorieLog]
    )

    # Start keep-alive background task (only on Render)
    keep_alive_task = None
    if _KEEP_ALIVE_ENABLED and (_KEEP_ALIVE_URL or os.getenv("RENDER")):
        keep_alive_task = asyncio.create_task(_self_ping_loop())
        print(f"[{datetime.now().isoformat()}] Keep-alive pinger started (interval: {_KEEP_ALIVE_INTERVAL}s)")

    yield

    if keep_alive_task:
        keep_alive_task.cancel()
    client.close()


app = FastAPI(
    title="StackSense API",
    description="Supplement Tracker Backend API",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(supplements.router)
app.include_router(dose_logs.router)
app.include_router(insights.router)
app.include_router(measurements.router)
app.include_router(appointments.router)
app.include_router(admin.router)
app.include_router(water_logs.router)
app.include_router(calorie_logs.router)


@app.get("/")
async def root():
    return {"message": "StackSense API is running", "version": "1.0.0"}


@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}
