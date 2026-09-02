import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bhoomisetu_field.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tasks Table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        ulpin TEXT NOT NULL,
        parcelId TEXT,
        project TEXT NOT NULL,
        village TEXT NOT NULL,
        district TEXT NOT NULL,
        state TEXT NOT NULL,
        surveyNumber TEXT NOT NULL,
        landAreaSqM REAL NOT NULL,
        taskType TEXT NOT NULL,
        assignedDate TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        status TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        instructions TEXT,
        remarks TEXT,
        syncStatus TEXT NOT NULL DEFAULT 'SYNCED'
      )
    ''');

    // 2. Field Visits Table
    await db.execute('''
      CREATE TABLE field_visits (
        visitId TEXT PRIMARY KEY,
        taskId TEXT NOT NULL,
        ulpin TEXT NOT NULL,
        parcelId TEXT,
        officerId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        latitude REAL,
        longitude REAL,
        gpsAccuracy REAL,
        altitude REAL,
        status TEXT NOT NULL,
        remarks TEXT,
        isConfirmed INTEGER NOT NULL DEFAULT 0,
        syncStatus TEXT NOT NULL DEFAULT 'PENDING'
      )
    ''');

    // 3. Inspections Table
    await db.execute('''
      CREATE TABLE inspections (
        visitId TEXT PRIMARY KEY,
        parcelMatchesRecord TEXT NOT NULL,
        boundaryIdentified TEXT NOT NULL,
        boundaryMarkersAvailable TEXT NOT NULL,
        boundaryMatchesCadastral TEXT NOT NULL,
        landUseVerified TEXT NOT NULL,
        physicalConditionVerified TEXT NOT NULL,
        encroachmentChecked TEXT NOT NULL,
        ownershipChecked TEXT NOT NULL,
        documentsReviewed TEXT NOT NULL,
        objectionReceived TEXT NOT NULL,
        disputeObserved TEXT NOT NULL,
        encroachmentObserved TEXT NOT NULL,
        otherIssues TEXT NOT NULL,
        remarks TEXT,
        additionalObservations TEXT,
        syncStatus TEXT NOT NULL DEFAULT 'PENDING'
      )
    ''');

    // 4. Evidence Photos Table (Storing local file paths & metadata, no binary bloat)
    await db.execute('''
      CREATE TABLE evidence (
        photoId TEXT PRIMARY KEY,
        visitId TEXT NOT NULL,
        ulpin TEXT NOT NULL,
        parcelId TEXT,
        officerId TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        gpsAccuracy REAL,
        category TEXT NOT NULL,
        description TEXT,
        localFilePath TEXT NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'PENDING'
      )
    ''');

    // 5. Documents Table
    await db.execute('''
      CREATE TABLE documents (
        documentId TEXT PRIMARY KEY,
        visitId TEXT NOT NULL,
        ulpin TEXT NOT NULL,
        parcelId TEXT,
        fileName TEXT NOT NULL,
        fileType TEXT NOT NULL,
        fileSizeBytes INTEGER NOT NULL,
        localFilePath TEXT NOT NULL,
        uploadStatus TEXT NOT NULL DEFAULT 'PENDING_UPLOAD',
        syncStatus TEXT NOT NULL DEFAULT 'PENDING'
      )
    ''');

    // 6. Sync Queue Table (Idempotent offline operations)
    await db.execute('''
      CREATE TABLE sync_queue (
        localId TEXT PRIMARY KEY,
        clientEventId TEXT UNIQUE NOT NULL,
        entityType TEXT NOT NULL,
        entityId TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        retryCount INTEGER NOT NULL DEFAULT 0,
        syncStatus TEXT NOT NULL DEFAULT 'PENDING',
        lastError TEXT
      )
    ''');

    // 7. Notifications Table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        relatedId TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Migration handling for future database schema iterations
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
