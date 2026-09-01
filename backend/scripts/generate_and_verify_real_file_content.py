import hashlib
import os
import io
import httpx
from datetime import datetime, timezone
from app.database.session import SessionLocal
from app.models.user import User
from app.models.field import FieldTask, FieldVisit, FieldVerification
from app.models.document import Document
from app.models.audit import AuditLog

BASE_URL = "http://127.0.0.1:5000/api/v1"

def get_real_image_bytes() -> tuple[bytes, str, str]:
    """Reads a real 481 KB high-resolution image asset from frontend/src/assets/emblem.png."""
    emblem_path = r"c:\Users\adity\OneDrive\Documents\BhoomiSetu\frontend\src\assets\emblem.png"
    with open(emblem_path, "rb") as f:
        data = f.read()
    return data, "ground_survey_boundary_evidence.png", "image/png"

def create_real_pdf_bytes() -> tuple[bytes, str, str]:
    """Generates a valid compliant PDF document containing official land record metadata."""
    content = f"""%PDF-1.4
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
<< /Length 520 >>
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
(GNSS Ground Calibration: Lat 18.520433 N, Lng 73.856744 E | Accuracy: 4.2m) Tj
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
0000000796 00000 n 
trailer
<< /Size 6 /Root 1 0 R >>
startxref
865
%%EOF
"""
    return content.encode("utf-8"), "official_7_12_extract_wagholi.pdf", "application/pdf"

def run_real_file_content_test():
    print("================================================================================")
    print("REAL FILE CONTENT & SHA-256 END-TO-END INTEGRITY VERIFICATION")
    print("================================================================================")

    # 1. Load Real Source Files and compute source SHA-256
    real_img_bytes, img_filename, img_mime = get_real_image_bytes()
    real_pdf_bytes, pdf_filename, pdf_mime = create_real_pdf_bytes()

    img_source_sha256 = hashlib.sha256(real_img_bytes).hexdigest()
    pdf_source_sha256 = hashlib.sha256(real_pdf_bytes).hexdigest()

    print(f"[SOURCE PHOTO] File: {img_filename} | Bytes: {len(real_img_bytes):,} bytes | SHA-256: {img_source_sha256}")
    print(f"[SOURCE PDF]   File: {pdf_filename} | Bytes: {len(real_pdf_bytes):,} bytes | SHA-256: {pdf_source_sha256}")
    assert len(real_img_bytes) > 100000, f"Image file too small: {len(real_img_bytes)}"
    assert len(real_pdf_bytes) > 500, f"PDF file too small: {len(real_pdf_bytes)}"

    # 2. Login as verified Field Officer
    client = httpx.Client(timeout=20.0)
    login_res = client.post(f"{BASE_URL}/auth/login", json={
        "email": "arun.shinde.01508f@maharashtra.gov.in",
        "password": "OperationalPass@2026"
    })
    assert login_res.status_code == 200
    token = login_res.json()["data"]["access_token"]
    user_id = login_res.json()["data"]["user"]["id"]
    headers = {"Authorization": f"Bearer {token}"}
    print(f"\n[AUTH] Logged in as Field Officer User ID {user_id} ({login_res.json()['data']['user']['name']})")

    # 3. Upload Real Camera Photo
    photo_res = client.post(
        f"{BASE_URL}/field/photos",
        headers=headers,
        files={"file": (img_filename, real_img_bytes, img_mime)},
        data={"related_entity_id": 104}
    )
    assert photo_res.status_code == 201, f"Photo upload failed: {photo_res.text}"
    photo_doc_id = photo_res.json()["data"]["document_id"]
    photo_url = photo_res.json()["data"]["url"]
    print(f"[UPLOAD PHOTO] PASS | Doc ID: {photo_doc_id} | Server Size: {photo_res.json()['data']['file_size']:,} bytes | URL: {photo_url}")

    # 4. Upload Real Land Record PDF
    doc_res = client.post(
        f"{BASE_URL}/documents/upload",
        headers=headers,
        files={"file": (pdf_filename, real_pdf_bytes, pdf_mime)},
        data={"related_entity": "FIELD_TASK", "related_entity_id": 104}
    )
    assert doc_res.status_code == 201, f"Document upload failed: {doc_res.text}"
    pdf_doc_id = doc_res.json()["data"]["document_id"]
    pdf_url = doc_res.json()["data"]["url"]
    print(f"[UPLOAD PDF]   PASS | Doc ID: {pdf_doc_id} | Server Size: {doc_res.json()['data']['file_size']:,} bytes | URL: {pdf_url}")

    # 5. Direct Supabase PostgreSQL Metadata & Storage File Check
    db = SessionLocal()
    try:
        pg_photo = db.query(Document).filter(Document.id == photo_doc_id).first()
        pg_pdf = db.query(Document).filter(Document.id == pdf_doc_id).first()

        assert pg_photo is not None
        assert pg_pdf is not None

        print("\n================================================================================")
        print("POSTGRESQL METADATA & PHYSICAL DISK STORAGE PROOF")
        print("================================================================================")
        print(f"Photo DB Record: ID: {pg_photo.id} | Name: {pg_photo.document_name} | Size: {pg_photo.file_size:,} bytes | Uploader: User #{pg_photo.uploaded_by} | Path: {pg_photo.storage_path}")
        print(f"PDF DB Record:   ID: {pg_pdf.id} | Name: {pg_pdf.document_name} | Size: {pg_pdf.file_size:,} bytes | Uploader: User #{pg_pdf.uploaded_by} | Path: {pg_pdf.storage_path}")

        # Check physical files on disk
        assert os.path.exists(pg_photo.storage_path), f"Stored photo missing at {pg_photo.storage_path}"
        assert os.path.exists(pg_pdf.storage_path), f"Stored PDF missing at {pg_pdf.storage_path}"

        with open(pg_photo.storage_path, "rb") as f:
            stored_photo_bytes = f.read()
        with open(pg_pdf.storage_path, "rb") as f:
            stored_pdf_bytes = f.read()

        img_stored_sha256 = hashlib.sha256(stored_photo_bytes).hexdigest()
        pdf_stored_sha256 = hashlib.sha256(stored_pdf_bytes).hexdigest()

        print(f"\n[STORAGE PHOTO CHECK] Stored Bytes: {len(stored_photo_bytes):,} | SHA-256: {img_stored_sha256}")
        print(f"[STORAGE PDF CHECK]   Stored Bytes: {len(stored_pdf_bytes):,} | SHA-256: {pdf_stored_sha256}")

        assert img_stored_sha256 == img_source_sha256, "Photo SHA-256 mismatch between source and stored file!"
        assert pdf_stored_sha256 == pdf_source_sha256, "PDF SHA-256 mismatch between source and stored file!"
    finally:
        db.close()

    # 6. Web Dashboard / API Download Endpoint Integrity
    print("\n================================================================================")
    print("WEB DASHBOARD DOWNLOAD & SHA-256 INTEGRITY PROOF")
    print("================================================================================")
    
    download_photo_res = client.get(f"http://127.0.0.1:5000{photo_url}", headers=headers)
    assert download_photo_res.status_code == 200
    downloaded_photo_bytes = download_photo_res.content
    img_download_sha256 = hashlib.sha256(downloaded_photo_bytes).hexdigest()

    download_pdf_res = client.get(f"http://127.0.0.1:5000{pdf_url}", headers=headers)
    assert download_pdf_res.status_code == 200
    downloaded_pdf_bytes = download_pdf_res.content
    pdf_download_sha256 = hashlib.sha256(downloaded_pdf_bytes).hexdigest()

    print(f"[DOWNLOAD PHOTO] Downloaded: {len(downloaded_photo_bytes):,} bytes | SHA-256: {img_download_sha256}")
    print(f"[DOWNLOAD PDF]   Downloaded: {len(downloaded_pdf_bytes):,} bytes | SHA-256: {pdf_download_sha256}")

    assert img_download_sha256 == img_source_sha256, "Photo SHA-256 mismatch on download!"
    assert pdf_download_sha256 == pdf_source_sha256, "PDF SHA-256 mismatch on download!"

    # 7. Field Officer Web Dashboard API Content Verification
    stats_res = client.get(f"{BASE_URL}/dashboard/stats", headers=headers)
    assert stats_res.status_code == 200
    mobile_uploads = stats_res.json()["data"]["mobile_uploads"]
    
    matched_photo = [u for u in mobile_uploads if u["document_id"] == photo_doc_id]
    matched_pdf = [u for u in mobile_uploads if u["document_id"] == pdf_doc_id]

    print("\n================================================================================")
    print("FIELD OFFICER WEB DASHBOARD DATA CONFIRMATION")
    print("================================================================================")
    print(f"Matched Photo in Dashboard Feed: {matched_photo[0]['file_name']} (ID {matched_photo[0]['document_id']}, Size {matched_photo[0]['file_size']:,} bytes)")
    print(f"Matched PDF in Dashboard Feed:   {matched_pdf[0]['file_name']} (ID {matched_pdf[0]['document_id']}, Size {matched_pdf[0]['file_size']:,} bytes)")
    
    assert len(matched_photo) == 1
    assert len(matched_pdf) == 1

    print("\n================================================================================")
    print("SUCCESS: 100% BIT-FOR-BIT SHA-256 INTEGRITY MATCH ACROSS ALL LAYERS!")
    print("================================================================================")

if __name__ == "__main__":
    run_real_file_content_test()
