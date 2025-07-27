from fastapi import APIRouter, FastAPI, HTTPException, Path
from typing import List, Dict, Any
from mangum import Mangum
import boto3
import os
from boto3.dynamodb.conditions import Key
from fastapi.middleware.cors import CORSMiddleware




app = FastAPI(title="Pet Shop API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

lambda_handler = Mangum(app)


dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('dynamodb-table-modernizacion')

router = APIRouter(prefix="/shop")

@router.get("/ping")
async def ping():
    return {"message": "Pet Shop API is up and running!"}

@router.get("/{category}")
async def get_products_by_category(category: str = Path(..., description="Category of pets")):
    """
    Get all products by category
    Available categories: dogs, cats, fish, birds, reptiles
    """
    try:

        category_formatted = category.capitalize()
        
        response = table.query(
            KeyConditionExpression=Key('PK').eq(f'CATEGORY#{category_formatted}')
        )
        
        if not response['Items']:
            raise HTTPException(
                status_code=404, 
                detail=f"No products found for category: {category}"
            )
        
        products = []
        for item in response['Items']:
            products.append({
                "product_id": item['product_id'],
                "name": item['name'],
                "category": item['category']
            })
        
        return {
            "category": category_formatted,
            "count": len(products),
            "products": products
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

app.include_router(router)
