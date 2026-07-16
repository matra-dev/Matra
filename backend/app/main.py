import os
from contextlib import asynccontextmanager
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


@asynccontextmanager
async def lifespan(app: FastAPI):
    client = AsyncIOMotorClient(MONGODB_URL)
    await init_beanie(
        database=client[DB_NAME],
        document_models=[Supplement, DoseLog, User, Measurement, Appointment, WaterLog, CalorieLog]
    )
    yield
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
    return {"status": "healthy"}
