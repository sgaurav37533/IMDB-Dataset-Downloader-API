from fastapi import APIRouter
from app.api.v1 import datasets


api_router = APIRouter()

api_router.include_router(datasets.router, tags=["datasets"])
