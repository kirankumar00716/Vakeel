from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from ..database import get_db
from ..models.user import User
from ..schemas import Token, UserCreate, User as UserSchema
from ..utils.auth import create_access_token, get_current_active_user, ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter()

@router.post("/token", response_model=Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.username == form_data.username).first()
    
    if not user or not user.verify_password(form_data.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}


@router.post("/register", response_model=UserSchema)
async def register_user(user_create: UserCreate, db: Session = Depends(get_db)):
    # Check if username exists
    db_user_by_username = db.query(User).filter(User.username == user_create.username).first()
    if db_user_by_username:
        raise HTTPException(status_code=400, detail="Username already registered")
    
    # Check if email exists
    db_user_by_email = db.query(User).filter(User.email == user_create.email).first()
    if db_user_by_email:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Create new user
    hashed_password = User.hash_password(user_create.password)
    db_user = User(
        username=user_create.username,
        email=user_create.email,
        hashed_password=hashed_password
    )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return db_user


@router.get("/me", response_model=UserSchema)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user