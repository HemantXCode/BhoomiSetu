import os
import uuid
from datetime import datetime
from fastapi import UploadFile, HTTPException, status
from app.config.settings import settings

def save_uploaded_file(file: UploadFile, related_entity: str = None, related_entity_id: int = None) -> dict:
    allowed_extensions = [".jpg", ".jpeg", ".png", ".pdf"]
    ext = os.path.splitext(file.filename)[1].lower()

    if ext not in allowed_extensions:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File extension '{ext}' not allowed. Must be one of {allowed_extensions}"
        )

    # Date-based folder structure: storage/documents/YYYY/MM/
    now = datetime.now()
    relative_subfolder = os.path.join(str(now.year), f"{now.month:02d}")
    target_folder = os.path.join(settings.UPLOAD_DIR, relative_subfolder)
    os.makedirs(target_folder, exist_ok=True)

    doc_id = f"doc-{uuid.uuid4().hex[:12]}"
    filename = f"{doc_id}{ext}"
    full_path = os.path.join(target_folder, filename)

    content = file.file.read()
    file_size = len(content)

    if file_size > 15 * 1024 * 1024:  # 15 MB limit
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File size exceeds maximum limit of 15MB."
        )

    with open(full_path, "wb") as f:
        f.write(content)

    return {
        "document_id": doc_id,
        "file_name": file.filename,
        "file_type": file.content_type or f"application/{ext[1:]}",
        "file_size": file_size,
        "storage_path": full_path,
        "url": f"/api/v1/documents/{doc_id}/download",
        "related_entity": related_entity,
        "related_entity_id": related_entity_id
    }

def get_file_path(storage_path: str) -> str:
    if os.path.isabs(storage_path):
        return storage_path
    return os.path.join(settings.UPLOAD_DIR, storage_path)
