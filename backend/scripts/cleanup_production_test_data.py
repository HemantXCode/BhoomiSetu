import os
import sys
from sqlalchemy import text
from app.database.session import SessionLocal
from app.models.user import User
from app.models.field import FieldTask, FieldVisit, FieldVerification, SyncEvent
from app.models.document import Document
from app.models.audit import AuditLog
from app.storage import file_storage

def generate_classification_report(db):
    print("================================================================================")
    print("LIVE SUPABASE POSTGRESQL -- PRE-CLEANUP CLASSIFICATION REPORT")
    print("================================================================================")
    
    all_users = db.query(User).order_by(User.id.asc()).all()
    demo_users = [u for u in all_users if u.is_demo]
    operational_users = [u for u in all_users if not u.is_demo and "@test.gov.in" not in u.email]
    test_users = [u for u in all_users if "@test.gov.in" in u.email]

    print(f"Total Users in Database: {len(all_users)}")
    print(f"  |-- Demo Seed Users (is_demo=True): {len(demo_users)}")
    for u in demo_users:
        print(f"  |    [ID {u.id:2d}] {u.email:<35} | Role: {u.role:<18} | Status: {u.identity_status}")
    print(f"  |-- Operational Personnel (is_demo=False): {len(operational_users)}")
    for u in operational_users:
        print(f"  |    [ID {u.id:2d}] {u.email:<40} | Role: {u.role:<18} | Status: {u.identity_status}")
    print(f"  +-- Automated Test Accounts (@test.gov.in): {len(test_users)}")
    for u in test_users:
        print(f"       [ID {u.id:2d}] {u.email:<40} | Status: {u.identity_status}")

    test_user_ids = [u.id for u in test_users]

    # Dependent test records
    test_tasks = db.query(FieldTask).filter(FieldTask.assigned_to_user_id.in_(test_user_ids)).all() if test_user_ids else []
    test_task_ids = [t.id for t in test_tasks]

    test_visits = db.query(FieldVisit).filter(
        (FieldVisit.field_officer_id.in_(test_user_ids)) | 
        (FieldVisit.task_id.in_(test_task_ids))
    ).all() if (test_user_ids or test_task_ids) else []
    test_visit_ids = [v.id for v in test_visits]

    test_verifs = db.query(FieldVerification).filter(
        (FieldVerification.visit_id.in_(test_visit_ids)) | 
        (FieldVerification.task_id.in_(test_task_ids))
    ).all() if (test_visit_ids or test_task_ids) else []

    test_docs = db.query(Document).filter(
        (Document.uploaded_by.in_(test_user_ids)) |
        ((Document.related_entity == "FIELD_TASK") & (Document.related_entity_id.in_(test_task_ids)))
    ).all() if (test_user_ids or test_task_ids) else []

    test_syncs = db.query(SyncEvent).filter(
        (SyncEvent.user_id.in_(test_user_ids)) |
        (SyncEvent.client_event_id.like("EVT_TEST_%")) |
        (SyncEvent.client_event_id.like("EVT_VERIF_%"))
    ).all()

    test_audits = db.query(AuditLog).filter(
        (AuditLog.user_id.in_(test_user_ids)) |
        ((AuditLog.entity_type == "USER") & (AuditLog.entity_id.in_([str(uid) for uid in test_user_ids]))) |
        ((AuditLog.entity_type == "FIELD_TASK") & (AuditLog.entity_id.in_([str(tid) for tid in test_task_ids]))) |
        ((AuditLog.entity_type == "FIELD_VISIT") & (AuditLog.entity_id.in_([str(vid) for vid in test_visit_ids]))) |
        ((AuditLog.entity_type == "DOCUMENT") & (AuditLog.entity_id.in_([d.id for d in test_docs])))
    ).all()

    print("\nDependent Test Artifacts to be Removed:")
    print(f"  |-- Test Field Tasks:         {len(test_tasks)} (IDs: {test_task_ids})")
    print(f"  |-- Test Field Visits:        {len(test_visits)} (IDs: {test_visit_ids})")
    print(f"  |-- Test Field Verifications: {len(test_verifs)} (IDs: {[v.id for v in test_verifs]})")
    print(f"  |-- Test Uploaded Documents:  {len(test_docs)} (IDs: {[d.id for d in test_docs]})")
    print(f"  |-- Test Sync Events:         {len(test_syncs)} (IDs: {[s.client_event_id for s in test_syncs]})")
    print(f"  +-- Test Audit Log Records:   {len(test_audits)} rows")
    print("================================================================================\n")

    return {
        "test_users": test_users,
        "test_tasks": test_tasks,
        "test_visits": test_visits,
        "test_verifs": test_verifs,
        "test_docs": test_docs,
        "test_syncs": test_syncs,
        "test_audits": test_audits,
        "demo_users": demo_users
    }

def perform_cleanup(db, artifacts):
    allow_cleanup = os.getenv("ALLOW_PRODUCTION_TEST_DATA_CLEANUP", "").lower() == "true"
    if not allow_cleanup:
        print("[SAFETY CHECK] DESTRUCTIVE CLEANUP BLOCKED: Environment variable ALLOW_PRODUCTION_TEST_DATA_CLEANUP=true is not set.")
        print("   Run with: $env:ALLOW_PRODUCTION_TEST_DATA_CLEANUP=\"true\"; python -m scripts.cleanup_production_test_data")
        return False

    print("[CLEANUP] Executing Safe Production Test Data Cleanup...\n")

    # 1. Clean test physical files
    for doc in artifacts["test_docs"]:
        try:
            p = file_storage.get_file_path(doc.storage_path)
            if os.path.exists(p):
                os.remove(p)
                print(f"   [Storage] Removed test file: {p}")
        except Exception as e:
            print(f"   [Storage Warning] Could not remove {doc.storage_path}: {e}")

    # 2. Delete test audit logs
    test_audit_ids = [a.id for a in artifacts["test_audits"]]
    if test_audit_ids:
        db.query(AuditLog).filter(AuditLog.id.in_(test_audit_ids)).delete(synchronize_session=False)
        print(f"   [PostgreSQL] Deleted {len(test_audit_ids)} test audit logs.")

    # 3. Delete test sync events
    test_sync_ids = [s.client_event_id for s in artifacts["test_syncs"]]
    if test_sync_ids:
        db.query(SyncEvent).filter(SyncEvent.client_event_id.in_(test_sync_ids)).delete(synchronize_session=False)
        print(f"   [PostgreSQL] Deleted {len(test_sync_ids)} test sync events.")

    # 4. Delete test documents metadata
    test_doc_ids = [d.id for d in artifacts["test_docs"]]
    if test_doc_ids:
        db.query(Document).filter(Document.id.in_(test_doc_ids)).delete(synchronize_session=False)
        print(f"   [PostgreSQL] Deleted {len(test_doc_ids)} test document records.")

    # 5. Delete test field verifications
    test_verif_ids = [v.id for v in artifacts["test_verifs"]]
    if test_verif_ids:
        db.query(FieldVerification).filter(FieldVerification.id.in_(test_verif_ids)).delete(synchronize_session=False)
        print(f"   [PostgreSQL] Deleted {len(test_verif_ids)} test verification records.")

    # 6. Delete test field visits
    test_visit_ids = [v.id for v in artifacts["test_visits"]]
    if test_visit_ids:
        db.query(FieldVisit).filter(FieldVisit.id.in_(test_visit_ids)).delete(synchronize_session=False)
        print(f"   [PostgreSQL] Deleted {len(test_visit_ids)} test visit records.")

    # 7. Delete test field tasks
    test_task_ids = [t.id for t in artifacts["test_tasks"]]
    if test_task_ids:
        db.query(FieldTask).filter(FieldTask.id.in_(test_task_ids)).delete(synchronize_session=False)
        print(f"   [PostgreSQL] Deleted {len(test_task_ids)} test task records.")

    # 8. Delete test users
    test_user_ids = [u.id for u in artifacts["test_users"]]
    if test_user_ids:
        db.query(User).filter(User.id.in_(test_user_ids)).delete(synchronize_session=False)
        print(f"   [PostgreSQL] Deleted {len(test_user_ids)} test users.")

    # 9. Decommission Demo Accounts from Operational Runtime
    # Deactivate demo users so they cannot be authenticated in operational runtime
    for d in artifacts["demo_users"]:
        d.is_active = False
        d.suspension_reason = "Demo account decommissioned from production operational runtime."
        print(f"   [PostgreSQL] Decommissioned demo user ID {d.id} ({d.email}) [is_active=False].")

    db.commit()
    print("\n[SUCCESS] PRODUCTION CLEANUP TRANSACTION COMMITTED SUCCESSFULLY.")
    return True

def print_post_cleanup_summary(db):
    print("\n================================================================================")
    print("LIVE SUPABASE POSTGRESQL -- POST-CLEANUP OPERATIONAL STATUS")
    print("================================================================================")
    users = db.query(User).order_by(User.id.asc()).all()
    print(f"Remaining Users: {len(users)}")
    for u in users:
        print(f"  ID: {u.id:2d} | Email: {u.email:<40} | Role: {u.role:<18} | is_demo: {u.is_demo} | Active: {u.is_active} | Status: {u.identity_status}")

    print(f"\nRemaining Operational Field Tasks:        {db.query(FieldTask).count()}")
    print(f"Remaining Operational Field Visits:       {db.query(FieldVisit).count()}")
    print(f"Remaining Operational Field Verifications:{db.query(FieldVerification).count()}")
    print(f"Remaining Operational Documents:          {db.query(Document).count()}")
    print(f"Remaining Operational Sync Events:        {db.query(SyncEvent).count()}")
    print(f"Remaining Operational Audit Logs:         {db.query(AuditLog).count()}")
    print("================================================================================\n")

if __name__ == "__main__":
    db = SessionLocal()
    artifacts = generate_classification_report(db)
    success = perform_cleanup(db, artifacts)
    if success:
        print_post_cleanup_summary(db)
    db.close()
