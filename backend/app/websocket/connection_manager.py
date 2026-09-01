from fastapi import WebSocket
from typing import List, Dict, Any

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[Dict[str, Any]] = []

    async def connect(self, websocket: WebSocket, user_id: int, role: str, state_id: int = None, district_id: int = None, agency_id: int = None):
        await websocket.accept()
        self.active_connections.append({
            "websocket": websocket,
            "user_id": user_id,
            "role": role,
            "state_id": state_id,
            "district_id": district_id,
            "agency_id": agency_id
        })

    def disconnect(self, websocket: WebSocket):
        self.active_connections = [c for c in self.active_connections if c["websocket"] != websocket]

    async def broadcast_event(self, event_type: str, data: Dict[str, Any], state_id: int = None, district_id: int = None, agency_id: int = None):
        payload = {
            "event": event_type,
            "data": data
        }

        for conn in self.active_connections:
            role = conn["role"]
            c_state = conn["state_id"]
            c_district = conn["district_id"]
            c_agency = conn["agency_id"]

            # Role & Jurisdiction scoping for WebSockets
            if role == "CENTRAL_MINISTRY":
                await conn["websocket"].send_json(payload)
            elif role == "STATE_GOVERNMENT" and state_id and c_state == state_id:
                await conn["websocket"].send_json(payload)
            elif role == "DISTRICT_AUTHORITY" and district_id and c_district == district_id:
                await conn["websocket"].send_json(payload)
            elif role == "PROJECT_AGENCY" and agency_id and c_agency == agency_id:
                await conn["websocket"].send_json(payload)
            elif role == "FIELD_OFFICER" and district_id and c_district == district_id:
                await conn["websocket"].send_json(payload)

manager = ConnectionManager()
