from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from backend.routes.assistant_router import router as assistant_router
from backend.routes.email_router import router as email_router
from backend.services.groq_service import GroqService

app = FastAPI(
    title="MailCraft AI API",
    description="Backend API for the MailCraft AI mobile application.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(email_router)
app.include_router(assistant_router)

groq_service = GroqService()


@app.get("/api/health")
async def health():
    return {"status": "ok", "service": "MailCraft AI backend"}


@app.get("/api/ai-test")
async def ai_test():
    result = await groq_service.test_groq_connection()
    return result
