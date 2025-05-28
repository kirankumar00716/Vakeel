from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..models.user import User
from ..models.legal_query import LegalQuery
from ..schemas import LegalQuery as LegalQuerySchema, LegalQueryCreate, LegalQueryUpdate
from ..utils.auth import get_current_active_user
from ..llm.llama_service import LlamaLegalService

router = APIRouter()
llm_service = LlamaLegalService()

@router.post("/query", response_model=LegalQuerySchema)
async def create_legal_query(
    query: LegalQueryCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Categorize the query
    category = llm_service.categorize_query(query.query)
    
    # Generate response using LLM
    result = llm_service.generate_response(query.query)
    
    if result.get("error") and not result.get("response"):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Failed to generate legal response"
        )
    
    # Save the query and response
    db_query = LegalQuery(
        user_id=current_user.id,
        query=query.query,
        response=result["response"],
        category=category if query.category is None else query.category,
        is_saved=False
    )
    
    db.add(db_query)
    db.commit()
    db.refresh(db_query)
    
    return db_query


@router.get("/history", response_model=List[LegalQuerySchema])
async def get_query_history(
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    queries = db.query(LegalQuery).filter(
        LegalQuery.user_id == current_user.id
    ).order_by(LegalQuery.created_at.desc()).offset(skip).limit(limit).all()
    
    return queries


@router.get("/saved", response_model=List[LegalQuerySchema])
async def get_saved_queries(
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    queries = db.query(LegalQuery).filter(
        LegalQuery.user_id == current_user.id,
        LegalQuery.is_saved == True
    ).order_by(LegalQuery.created_at.desc()).offset(skip).limit(limit).all()
    
    return queries


@router.get("/{query_id}", response_model=LegalQuerySchema)
async def get_query_by_id(
    query_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    query = db.query(LegalQuery).filter(
        LegalQuery.id == query_id,
        LegalQuery.user_id == current_user.id
    ).first()
    
    if query is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Legal query not found"
        )
        
    return query


@router.put("/{query_id}", response_model=LegalQuerySchema)
async def update_query(
    query_id: int,
    query_update: LegalQueryUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_query = db.query(LegalQuery).filter(
        LegalQuery.id == query_id,
        LegalQuery.user_id == current_user.id
    ).first()
    
    if db_query is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Legal query not found"
        )
    
    # Update query fields
    update_data = query_update.dict(exclude_unset=True)
    
    # If the query text is changed, regenerate the response
    if "query" in update_data and update_data["query"] != db_query.query:
        result = llm_service.generate_response(update_data["query"])
        
        if result.get("error") and not result.get("response"):
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Failed to generate legal response"
            )
            
        update_data["response"] = result["response"]
        
        # Update category if not explicitly provided
        if "category" not in update_data:
            update_data["category"] = llm_service.categorize_query(update_data["query"])
    
    for key, value in update_data.items():
        setattr(db_query, key, value)
        
    db.commit()
    db.refresh(db_query)
    
    return db_query


@router.delete("/{query_id}", response_model=LegalQuerySchema)
async def delete_query(
    query_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_query = db.query(LegalQuery).filter(
        LegalQuery.id == query_id,
        LegalQuery.user_id == current_user.id
    ).first()
    
    if db_query is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Legal query not found"
        )
        
    db.delete(db_query)
    db.commit()
    
    return db_query