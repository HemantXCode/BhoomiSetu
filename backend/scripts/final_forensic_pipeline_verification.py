import hashlib
import os
import httpx
from datetime import datetime, timezone
from app.database.session import SessionLocal
from app.models.user import User
from app.models.field import FieldTask, FieldVisit, FieldVerification
from app.models.document import Document
from app.models.audit import AuditLog

BASE_URL = "http://127.0.0.1:5000/api/v1"

def run_final_pipeline_verification():
    print("================================================================================")
    print("BHOOMISETU FINAL FORENSIC PIPELINE & SHA-256 VERIFICATION")
    print("================================================================================")

    # 1. Source files
    img_path = r"c:\Users\adity\OneDrive\Documents\BhoomiSetu\frontend\src\assets\emblem.png"
    with open(img_path, "rb") as f:
        real_img_bytes = f.read()

    real_pdf_bytes = f"""%PDF-1.4
1 0 obj
<< /Type /Catalog /Pages 2 0 R >>
endobj
2 0 obj
<< /Type /Pages /Kids [3 0 R] /Count 1 >>
endobj
3 0 obj
<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>
endobj
4 0 obj
<< /Length 530 >>
stream
BT
/F1 16 Tf
50 720 Td
(GOVERNMENT OF MAHARASHTRA - REVENUE DEPARTMENT) Tj
0 -25 Td
/F1 12 Tf
(FORM VII-XII (7/12 EXTRACT) - VILLAGE RECORD OF RIGHTS) Tj
0 -30 Td
/F1 10 Tf
(District: Pune | Taluka: Haveli | Village: Wagholi) Tj
0 -20 Td
(Gat / Survey Number: 142/3A | Sub-Division: 01) Tj
0 -20 Td
(Total Area: 2.4500 Hectares | Land Class: Jirayat / Agricultural) Tj
0 -20 Td
(Cultivator Name: Arun B. Shinde & Joint Holders) Tj
0 -20 Td
(Acquisition Project: Pune Ring Road Corridor Package II) Tj
0 -20 Td
(Certified On: {datetime.now(timezone.utc).strftime('%d-%b-%Y %H:%M:%S UTC')}) Tj
ET
endstream
endobj
5 0 obj
<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>
endobj
xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000224 00000 n 
0000000806 00000 n 
trailer
<< /Size 6 /Root 1 0 R >>
startxref
875
%%EOF
""".encode("utf-8")

    src_img_sha256 = hashlib.sha256(real_img_bytes).hexdigest()
    src_pdf_sha256 = hashlib.sha256(real_pdf_bytes).hexdigest()

    print(f"[1. SOURCE IMAGES]")
    print(f"  Photo:   emblem_boundary_survey.png | {len(real_img_bytes):,} bytes | SHA-256: {src_img_sha256}")
    print(f"  PDF:     wagholi_7_12_extract.pdf   | {len(real_pdf_bytes):,} bytes | SHA-256: {src_pdf_sha256}")

    # 2. Authentication
    client = httpx.Client(timeout=20.0)
    auth_res = client.post(f"{BASE_URL}/auth/login", json={
        "email": "arun.shinde.01508f@maharashtra.gov.in",
        "password": "OperationalPass@2026"
    })
    assert auth_res.status_code == 200, f"Authentication failed: {auth_res.text}"
    token = auth_res.json()["data"]["access_token"]
    user_data = auth_res.json()["data"]["user"]
    headers = {"Authorization": f"Bearer {token}"}
    print(f"\n[2. REAL AUTHENTICATION] PASS | User: {user_data['name']} (ID {user_data['id']}) | Masked ID: {user_data['official_id_masked']}")

    # 3. Security / Impersonation Test
    # Attempt to spoof uploaded_by = 999 and field_officer_id = 999
    spoof_photo_res = client.post(
        f"{BASE_URL}/field/photos",
        headers=headers,
        files={"file": ("emblem_boundary_survey.png", real_img_bytes, "image/png")},
        data={"related_entity_id": 104, "uploaded_by": 999, "field_officer_id": 999}
    )
    assert spoof_photo_res.status_code == 201
    photo_doc_id = spoof_photo_res.json()["data"]["document_id"]
    photo_url = spoof_photo_res.json()["data"]["url"]

    spoof_doc_res = client.post(
        f"{BASE_URL}/documents/upload",
        headers=headers,
        files={"file": ("wagholi_7_12_extract.pdf", real_pdf_bytes, "application/pdf")},
        data={"related_entity": "FIELD_TASK", "related_entity_id": 104, "uploaded_by": 999}
    )
    assert spoof_doc_res.status_code == 201
    pdf_doc_id = spoof_doc_res.json()["data"]["document_id"]
    pdf_url = spoof_doc_res.json()["data"]["url"]

    # 4. Direct Supabase PostgreSQL Verification
    db = SessionLocal()
    try:
        db_photo = db.query(Document).filter(Document.id == photo_doc_id).first()
        db_pdf = db.query(Document).filter(Document.id == pdf_doc_id).first()

        assert db_photo is not None
        assert db_pdf is not None

        print(f"\n[3. POSTGRESQL METADATA & OWNERSHIP ENFORCEMENT]")
        print(f"  Photo Row: ID {db_photo.id} | Size {db_photo.file_size:,} B | UploadedBy: {db_photo.uploaded_by} | Path: {db_photo.storage_path}")
        print(f"  PDF Row:   ID {db_pdf.id} | Size {db_pdf.file_size:,} B | UploadedBy: {db_pdf.uploaded_by} | Path: {db_pdf.storage_path}")
        
        # Verify server ignored client-supplied 999 and bound user_data['id'] (6)
        assert db_photo.uploaded_by == user_data["id"], "Security violation: Server did not enforce JWT uploader ID!"
        assert db_pdf.uploaded_by == user_data["id"], "Security violation: Server did not enforce JWT uploader ID!"

        # 5. Physical Storage on Filesystem
        assert os.path.exists(db_photo.storage_path), f"File missing at {db_photo.storage_path}"
        assert os.path.exists(db_pdf.storage_path), f"File missing at {db_pdf.storage_path}"

        with open(db_photo.storage_path, "rb") as f:
            stored_photo_bytes = f.read()
        with open(db_pdf.storage_path, "rb") as f:
            stored_pdf_bytes = f.read()

        stored_img_sha256 = hashlib.sha256(stored_photo_bytes).hexdigest()
        stored_pdf_sha256 = hashlib.sha256(stored_pdf_bytes).hexdigest()

        print(f"\n[4. BACKEND STORAGE INTEGRITY]")
        print(f"  Stored Photo SHA-256: {stored_img_sha256} (Matches Source: {stored_img_sha256 == src_img_sha256})")
        print(f"  Stored PDF SHA-256:   {stored_pdf_sha256} (Matches Source: {stored_pdf_sha256 == src_pdf_sha256})")

        assert stored_img_sha256 == src_img_sha256
        assert stored_pdf_sha256 == src_pdf_sha256
    finally:
        db.close()

    # 6. Web Dashboard Download Endpoint Verification
    dl_photo_res = client.get(f"http://127.0.0.1:5000{photo_url}", headers=headers)
    assert dl_photo_res.status_code == 200
    dl_photo_sha256 = hashlib.sha256(dl_photo_res.content).hexdigest()

    dl_pdf_res = client.get(f"http://127.0.0.1:5000{pdf_url}", headers=headers)
    assert dl_pdf_res.status_code == 200
    dl_pdf_sha256 = hashlib.sha256(dl_pdf_res.content).hexdigest()

    print(f"\n[5. WEB DASHBOARD DOWNLOAD INTEGRITY]")
    print(f"  Downloaded Photo SHA-256: {dl_photo_sha256} (Matches Source: {dl_photo_sha256 == src_img_sha256})")
    print(f"  Downloaded PDF SHA-256:   {dl_pdf_sha256} (Matches Source: {dl_pdf_sha256 == src_pdf_sha256})")

    assert dl_photo_sha256 == src_img_sha256
    assert dl_pdf_sha256 == src_pdf_sha256

    # 7. Web Dashboard Live Feed Retrieval
    stats_res = client.get(f"{BASE_URL}/dashboard/stats", headers=headers)
    assert stats_res.status_code == 200
    uploads_feed = stats_res.json()["data"]["mobile_uploads"]
    
    matching_photo_ui = [u for u in uploads_feed if u["document_id"] == photo_doc_id]
    matching_pdf_ui = [u for u in uploads_feed if u["document_id"] == pdf_doc_id]

    print(f"\n[6. WEB DASHBOARD DYNAMIC PRESENTATION]")
    print(f"  Rendered Photo in UI: {matching_photo_ui[0]['file_name']} | ID: {matching_photo_ui[0]['document_id']} | Size: {matching_photo_ui[0]['file_size']:,} B | URL: {matching_photo_ui[0]['url']}")
    print(f"  Rendered PDF in UI:   {matching_pdf_ui[0]['file_name']} | ID: {matching_pdf_ui[0]['document_id']} | Size: {matching_pdf_ui[0]['file_size']:,} B | URL: {matching_pdf_ui[0]['url']}")

    assert len(matching_photo_ui) == 1
    assert len(matching_pdf_ui) == 1

    print("\n================================================================================")
    print("FORENSIC PIPELINE & BIT-FOR-BIT MATCH COMPLETED SUCCESSFULLY!")
    print("================================================================================")

if __name__ == "__main__":
    run_final_pipeline_verification()
