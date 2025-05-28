import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import user, auth, legal_query, profile

app = FastAPI(
    title="Vakeel API",
    description="Backend API for the Vakeel legal assistant mobile application",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api", tags=["Authentication"])
app.include_router(user.router, prefix="/api/users", tags=["Users"])
app.include_router(profile.router, prefix="/api/profiles", tags=["Profiles"])
app.include_router(legal_query.router, prefix="/api/legal", tags=["Legal Queries"])

@app.get("/", tags=["Root"])
async def root():
    return {"message": "Welcome to Vakeel API", "status": "online"}

@app.get("/api/health-check", tags=["Health"])
async def health_check():
    return {"status": "ok", "message": "API is running"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=True)