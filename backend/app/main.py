from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Query, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
import os

from app.config.settings import settings
from app.utils.jwt_util import decode_access_token
from app.websocket.connection_manager import manager
from app.routers import (
    auth_router,
    user_router,
    project_router,
    parcel_router,
    compensation_router,
    rr_router,
    field_router,
    document_router,
    geo_router,
    notification_router,
    dashboard_router,
    analytics_router,
    audit_router
)

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url="/api/v1/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Custom Exception Handlers for Standard Error Format
@app.exception_handler(HTTPException)
async def custom_http_exception_handler(request: Request, exc: HTTPException):
    code_map = {
        400: "BAD_REQUEST",
        401: "UNAUTHORIZED",
        403: "FORBIDDEN",
        404: "NOT_FOUND",
        409: "CONFLICT",
        422: "UNPROCESSABLE_ENTITY"
    }
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "message": str(exc.detail),
            "error_code": code_map.get(exc.status_code, "ERROR")
        }
    )

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = []
    for err in exc.errors():
        field = ".".join(str(loc) for loc in err["loc"])
        errors.append({"field": field, "message": err["msg"]})
    return JSONResponse(
        status_code=422,
        content={
            "success": False,
            "message": "Validation failed",
            "error_code": "VALIDATION_ERROR",
            "errors": errors
        }
    )

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global Health Endpoints
from app.database.session import check_database_health

@app.get("/health", tags=["Health"])
@app.get("/api/v1/health", tags=["Health"])
def health_check():
    is_healthy = check_database_health()
    if is_healthy:
        return {
            "status": "healthy",
            "database": "postgresql",
            "system": settings.PROJECT_NAME,
            "version": "1.0.0"
        }
    return JSONResponse(
        status_code=503,
        content={
            "status": "unhealthy",
            "database": "postgresql",
            "system": settings.PROJECT_NAME,
            "version": "1.0.0"
        }
    )

# Register Routers under /api/v1 and legacy /api
app.include_router(auth_router.router, prefix=settings.API_V1_STR)
app.include_router(user_router.router, prefix=settings.API_V1_STR)
app.include_router(project_router.router, prefix=settings.API_V1_STR)
app.include_router(parcel_router.router, prefix=settings.API_V1_STR)
app.include_router(compensation_router.router, prefix=settings.API_V1_STR)
app.include_router(rr_router.router, prefix=settings.API_V1_STR)
app.include_router(field_router.router, prefix=settings.API_V1_STR)
app.include_router(document_router.router, prefix=settings.API_V1_STR)
app.include_router(geo_router.router, prefix=settings.API_V1_STR)
app.include_router(notification_router.router, prefix=settings.API_V1_STR)
app.include_router(dashboard_router.router, prefix=settings.API_V1_STR)
app.include_router(analytics_router.router, prefix=settings.API_V1_STR)
app.include_router(audit_router.router, prefix=settings.API_V1_STR)

# Legacy /api router aliases
app.include_router(auth_router.router, prefix="/api")
app.include_router(project_router.router, prefix="/api")
app.include_router(dashboard_router.router, prefix="/api")
app.include_router(geo_router.router, prefix="/api")

# Real-Time WebSocket Endpoint
@app.websocket("/api/v1/ws")
@app.websocket("/api/ws")
async def websocket_endpoint(websocket: WebSocket, token: str = Query(...)):
    payload = decode_access_token(token)
    if not payload or "sub" not in payload:
        await websocket.close(code=4001)
        return
    
    user_id = payload.get("sub")
    role = payload.get("role", "FIELD_OFFICER")
    
    await manager.connect(websocket, user_id=user_id, role=role)
    try:
        while True:
            data = await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket)

os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
app.mount("/storage", StaticFiles(directory=os.path.dirname(settings.UPLOAD_DIR)), name="storage")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=5000, reload=True)
