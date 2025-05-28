@echo off
echo Starting Vakeel Backend Server...
cd backend
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
