from typing import Optional

def mask_official_id(official_id: Optional[str]) -> Optional[str]:
    if not official_id:
        return None
    cleaned = official_id.strip()
    if len(cleaned) <= 4:
        return "****"
    if "-" in cleaned:
        parts = cleaned.split("-")
        if len(parts) >= 3:
            masked_parts = parts[:-1]
            # mask the middle or penultimate parts
            masked_middle = ["****" if idx > 0 else p for idx, p in enumerate(parts[:-1])]
            return "-".join(masked_middle + [parts[-1]])
    
    # Generic mask: keep last 4 chars
    return "X" * (len(cleaned) - 4) + cleaned[-4:]
