from fastapi.responses import JSONResponse
from typing import Any, Optional, Dict, List

def api_response(
    status_code: int = 200,
    success: bool = True,
    message: str = "Success",
    data: Any = None,
    error_code: Optional[str] = None,
    errors: Optional[List[Dict[str, Any]]] = None
) -> JSONResponse:
    content = {
        "success": success,
        "message": message
    }
    if data is not None:
        content["data"] = data
    if error_code is not None:
        content["error_code"] = error_code
    if errors is not None:
        content["errors"] = errors

    return JSONResponse(status_code=status_code, content=content)
