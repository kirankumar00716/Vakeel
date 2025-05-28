from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..models.user import User
from ..schemas import User as UserSchema, UserUpdate
from ..utils.auth import get_current_active_user

router = APIRouter()

@router.get("/", response_model=List[UserSchema])
async def read_users(
    skip: int = 0, 
    limit: int = 100, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    users = db.query(User).offset(skip).limit(limit).all()
    return users


@router.get("/{user_id}", response_model=UserSchema)
async def read_user(
    user_id: int, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_user = db.query(User).filter(User.id == user_id).first()
    
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
        
    return db_user


@router.put("/{user_id}", response_model=UserSchema)
async def update_user(
    user_id: int,
    user_update: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Only allow users to update their own profile unless implementing admin role
    if current_user.id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to update this user"
        )
    
    db_user = db.query(User).filter(User.id == user_id).first()
    
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
        
    # Update user fields if provided
    if user_update.username is not None:
        # Check if username is taken
        existing_username = db.query(User).filter(
            User.username == user_update.username,
            User.id != user_id
        ).first()
        
        if existing_username:
            raise HTTPException(status_code=400, detail="Username already in use")
            
        db_user.username = user_update.username
        
    if user_update.email is not None:
        # Check if email is taken
        existing_email = db.query(User).filter(
            User.email == user_update.email,
            User.id != user_id
        ).first()
        
        if existing_email:
            raise HTTPException(status_code=400, detail="Email already in use")
            
        db_user.email = user_update.email
        
    if user_update.password is not None:
        db_user.hashed_password = User.hash_password(user_update.password)
    
    db.commit()
    db.refresh(db_user)
    
    return db_user


@router.delete("/{user_id}", response_model=UserSchema)
async def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Only allow users to delete their own account unless implementing admin role
    if current_user.id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to delete this user"
        )
    
    db_user = db.query(User).filter(User.id == user_id).first()
    
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
        
    db.delete(db_user)
    db.commit()
    
    return db_user