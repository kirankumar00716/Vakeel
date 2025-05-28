from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models.user import User
from ..models.profile import Profile
from ..schemas import Profile as ProfileSchema, ProfileCreate, ProfileUpdate
from ..utils.auth import get_current_active_user

router = APIRouter()

@router.post("/", response_model=ProfileSchema)
async def create_profile(
    profile_create: ProfileCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Check if profile already exists
    existing_profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    
    if existing_profile:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Profile already exists for this user"
        )
    
    # Create new profile
    db_profile = Profile(
        **profile_create.dict(),
        user_id=current_user.id
    )
    
    db.add(db_profile)
    db.commit()
    db.refresh(db_profile)
    
    return db_profile


@router.get("/me", response_model=ProfileSchema)
async def read_own_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    
    if db_profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found"
        )
        
    return db_profile


@router.put("/me", response_model=ProfileSchema)
async def update_own_profile(
    profile_update: ProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    
    if db_profile is None:
        # If profile doesn't exist, create a new one
        db_profile = Profile(
            **profile_update.dict(exclude_unset=True),
            user_id=current_user.id
        )
        
        db.add(db_profile)
    else:
        # Update existing profile
        update_data = profile_update.dict(exclude_unset=True)
        
        for key, value in update_data.items():
            setattr(db_profile, key, value)
    
    db.commit()
    db.refresh(db_profile)
    
    return db_profile


@router.get("/{user_id}", response_model=ProfileSchema)
async def read_user_profile(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_profile = db.query(Profile).filter(Profile.user_id == user_id).first()
    
    if db_profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found"
        )
        
    return db_profile