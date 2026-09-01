from sqlalchemy.orm import Session
from typing import Optional, Dict, Any
from datetime import datetime, timezone
from app.models.audit import AuditLog

def log_audit_event(
    db: Session,
    action: str,
    user_id: Optional[int] = None,
    user_role: Optional[str] = None,
    entity_type: Optional[str] = None,
    entity_id: Optional[str] = None,
    request_ip: Optional[str] = None,
    old_value: Optional[Dict[str, Any]] = None,
    new_value: Optional[Dict[str, Any]] = None
) -> AuditLog:
    # Ensure sensitive fields (passwords, tokens, raw govt IDs) are never stored in audit logs
    sanitized_new = None
    if new_value:
        sanitized_new = {k: ("***" if "password" in k.lower() or "token" in k.lower() or "secret" in k.lower() else v) for k, v in new_value.items()}

    audit_entry = AuditLog(
        user_id=user_id,
        user_role=user_role,
        action=action,
        entity_type=entity_type,
        entity_id=str(entity_id) if entity_id is not None else None,
        request_ip=request_ip,
        old_value=old_value,
        new_value=sanitized_new,
        timestamp=datetime.now(timezone.utc)
    )
    db.add(audit_entry)
    # Note: caller commits with enclosing transaction or db.flush()
    return audit_entry
