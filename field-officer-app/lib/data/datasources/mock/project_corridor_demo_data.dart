import 'package:latlong2/latlong.dart';
import '../../models/project_corridor_model.dart';
import '../../models/land_parcel_model.dart';

class ProjectCorridorDemoData {
  /// Demo Project 1: Pune Ring Road Express Corridor (Phase-I)
  /// Matches Web GIS DEMO_PROJECT_CORRIDORS[0]
  static ProjectCorridorModel get puneRingRoadCorridor {
    final routePoints = [
      const LatLng(18.7240, 73.6540), // Urse / Talegaon (Point A)
      const LatLng(18.7150, 73.6550),
      const LatLng(18.6870, 73.6820),
      const LatLng(18.6520, 73.7085), // Hinjawadi
      const LatLng(18.6130, 73.7160), // Marunji
      const LatLng(18.5730, 73.7370), // Sus
      const LatLng(18.5370, 73.7330), // Lavale
      const LatLng(18.5280, 73.7345),
      const LatLng(18.4960, 73.7470), // Pirangut / Bhugaon
      const LatLng(18.4640, 73.7810), // Dhayari
      const LatLng(18.4200, 73.8180),
      const LatLng(18.3850, 73.8480),
      const LatLng(18.3580, 73.8680), // Theur / Khed Shivapur (Point B)
    ];

    final segments = [
      // Segment 1: Urse - Hinjawadi Sector (Acquired)
      CorridorSegmentModel(
        id: 'PRR-SEG-01',
        projectId: 'PRJ-MH-PUN-001',
        name: 'Urse - Hinjawadi Sector',
        status: AcquisitionStatus.acquired,
        lengthKm: 14.2,
        landAreaHa: 165.50,
        ulpins: ['PUN-PRR-01', 'PUN-PRR-02', 'PUN-PRR-03', 'PUN-PRR-04', 'PUN-PRR-05', 'PUN-PRR-06'],
        routeGeometry: [
          const LatLng(18.7240, 73.6540),
          const LatLng(18.7150, 73.6550),
          const LatLng(18.6870, 73.6820),
          const LatLng(18.6520, 73.7085),
        ],
      ),
      // Segment 2: Hinjawadi - Lavale Sector (Acquired)
      CorridorSegmentModel(
        id: 'PRR-SEG-02',
        projectId: 'PRJ-MH-PUN-001',
        name: 'Hinjawadi - Lavale Sector',
        status: AcquisitionStatus.acquired,
        lengthKm: 12.8,
        landAreaHa: 123.78,
        ulpins: ['PUN-PRR-07', 'PUN-PRR-08', 'PUN-PRR-09', 'PUN-PRR-10'],
        routeGeometry: [
          const LatLng(18.6520, 73.7085),
          const LatLng(18.6130, 73.7160),
          const LatLng(18.5730, 73.7370),
          const LatLng(18.5370, 73.7330),
        ],
      ),
      // Segment 3: Lavale - Pirangut - Bhugaon Sector (In Progress)
      CorridorSegmentModel(
        id: 'PRR-SEG-03',
        projectId: 'PRJ-MH-PUN-001',
        name: 'Lavale - Pirangut - Bhugaon Sector',
        status: AcquisitionStatus.inProgress,
        lengthKm: 11.5,
        landAreaHa: 96.20,
        ulpins: ['ULPIN-MH-PUN-1024', 'ULPIN-MH-PUN-1025', 'ULPIN-MH-PUN-1026', 'PUN-PRR-14'],
        routeGeometry: [
          const LatLng(18.5370, 73.7330),
          const LatLng(18.5280, 73.7345),
          const LatLng(18.4960, 73.7470),
          const LatLng(18.4640, 73.7810),
        ],
      ),
      // Segment 4: Dhayari - Khed Shivapur Sector (Pending)
      CorridorSegmentModel(
        id: 'PRR-SEG-04',
        projectId: 'PRJ-MH-PUN-001',
        name: 'Dhayari - Khed Shivapur Sector',
        status: AcquisitionStatus.pending,
        lengthKm: 16.5,
        landAreaHa: 100.02,
        ulpins: ['ULPIN-MH-PUN-1027', 'PUN-PRR-16', 'PUN-PRR-17', 'PUN-PRR-18'],
        routeGeometry: [
          const LatLng(18.4640, 73.7810),
          const LatLng(18.4200, 73.8180),
          const LatLng(18.3850, 73.8480),
          const LatLng(18.3580, 73.8680),
        ],
      ),
    ];

    // 18 Cadastral Parcels for Pune Ring Road Express Corridor (Phase-I)
    // Synchronized with Web GIS DEMO_PARCELS (Polygons bisected / intersected by corridor)
    final parcels = [
      // 1. Urse - Gat 142/1 (Acquired 🟢, Center Bisected by Highway)
      LandParcelModel(
        ulpin: 'PUN-PRR-01',
        surveyNumber: 'Gat No. 142/1',
        village: 'Urse',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 12.50,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural (Irrigated)',
        ownerName: 'Ramesh Chandra Patil',
        status: 'ACQUIRED',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'VERIFIED',
        isAffected: true,
        polygon: [
          const LatLng(18.7250, 73.6490),
          const LatLng(18.7270, 73.6590),
          const LatLng(18.7190, 73.6600),
          const LatLng(18.7170, 73.6500),
        ],
      ),
      // 2. Urse - Gat 142/2 (Acquired 🟢, Left Side)
      LandParcelModel(
        ulpin: 'PUN-PRR-02',
        surveyNumber: 'Gat No. 142/2',
        village: 'Urse',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 8.20,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural',
        ownerName: 'Sunita Deshmukh',
        status: 'ACQUIRED',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'VERIFIED',
        isAffected: true,
        polygon: [
          const LatLng(18.7170, 73.6480),
          const LatLng(18.7180, 73.6540),
          const LatLng(18.7090, 73.6560),
          const LatLng(18.7080, 73.6500),
        ],
      ),
      // 3. Gahunje - Gat 89/1A (Acquired 🟢, Right Side)
      LandParcelModel(
        ulpin: 'PUN-PRR-03',
        surveyNumber: 'Gat No. 89/1A',
        village: 'Gahunje',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 6.40,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural',
        ownerName: 'Vasantrao Gaikwad',
        status: 'ACQUIRED',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'VERIFIED',
        isAffected: true,
        polygon: [
          const LatLng(18.7180, 73.6540),
          const LatLng(18.7190, 73.6620),
          const LatLng(18.7100, 73.6640),
          const LatLng(18.7090, 73.6560),
        ],
      ),
      // 4. Gahunje - Gat 89/2B (Acquired 🟢, Center Bisected by Highway)
      LandParcelModel(
        ulpin: 'PUN-PRR-04',
        surveyNumber: 'Gat No. 89/2B',
        village: 'Gahunje',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 9.80,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural',
        ownerName: 'Pandurang S. Shinde',
        status: 'ACQUIRED',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'VERIFIED',
        isAffected: true,
        polygon: [
          const LatLng(18.6930, 73.6760),
          const LatLng(18.6950, 73.6880),
          const LatLng(18.6810, 73.6900),
          const LatLng(18.6790, 73.6780),
        ],
      ),
      // 5. Hinjawadi - Gat 44/1 (Acquired 🟢, Left Side)
      LandParcelModel(
        ulpin: 'PUN-PRR-05',
        surveyNumber: 'Gat No. 44/1',
        village: 'Hinjawadi',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 7.50,
        classification: 'COMMERCIAL',
        landType: 'Commercial Non-Agri',
        ownerName: 'Rajendra P. Sutar',
        status: 'ACQUIRED',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'VERIFIED',
        isAffected: true,
        polygon: [
          const LatLng(18.6570, 73.6990),
          const LatLng(18.6590, 73.7055),
          const LatLng(18.6480, 73.7070),
          const LatLng(18.6460, 73.7005),
        ],
      ),
      // 6. Hinjawadi - Gat 44/2 (Acquired 🟢, Right Side)
      LandParcelModel(
        ulpin: 'PUN-PRR-06',
        surveyNumber: 'Gat No. 44/2',
        village: 'Hinjawadi',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 5.20,
        classification: 'COMMERCIAL',
        landType: 'Commercial Non-Agri',
        ownerName: 'Pravin Maruti Jadhav',
        status: 'ACQUIRED',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'VERIFIED',
        isAffected: true,
        polygon: [
          const LatLng(18.6590, 73.7055),
          const LatLng(18.6610, 73.7120),
          const LatLng(18.6500, 73.7135),
          const LatLng(18.6480, 73.7070),
        ],
      ),
      // 7. Wakad - Gat 102/1 (Acquired 🟢, Center Bisected by Highway)
      LandParcelModel(
        ulpin: 'PUN-PRR-07',
        surveyNumber: 'Gat No. 102/1',
        village: 'Wakad',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 11.20,
        classification: 'RESIDENTIAL',
        landType: 'Residential Non-Agri',
        ownerName: 'Babanrao Kadam',
        status: 'ACQUIRED',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'VERIFIED',
        isAffected: true,
        polygon: [
          const LatLng(18.6260, 73.7150),
          const LatLng(18.6280, 73.7270),
          const LatLng(18.6120, 73.7290),
          const LatLng(18.6100, 73.7170),
        ],
      ),
      // 8. Marunji - Gat 105/1 (Acquired 🟢, Left Side)
      LandParcelModel(
        ulpin: 'PUN-PRR-08',
        surveyNumber: 'Gat No. 105/1',
        village: 'Marunji',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 4.80,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural',
        ownerName: 'Anil Narayan Deshmukh',
        status: 'ACQUIRED',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'VERIFIED',
        isAffected: true,
        polygon: [
          const LatLng(18.6100, 73.7150),
          const LatLng(18.6110, 73.7215),
          const LatLng(18.5990, 73.7230),
          const LatLng(18.5980, 73.7165),
        ],
      ),
      // 9. Marunji - Gat 105/2 (Acquired 🟢, Right Side)
      LandParcelModel(
        ulpin: 'PUN-PRR-09',
        surveyNumber: 'Gat No. 105/2',
        village: 'Marunji',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 6.30,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural',
        ownerName: 'Vijay D. Thorat',
        status: 'ACQUIRED',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'VERIFIED',
        isAffected: true,
        polygon: [
          const LatLng(18.6110, 73.7215),
          const LatLng(18.6120, 73.7280),
          const LatLng(18.6000, 73.7295),
          const LatLng(18.5990, 73.7230),
        ],
      ),
      // 10. Sus - Gat 16/3 (Acquired 🟢, Center Bisected by Highway)
      LandParcelModel(
        ulpin: 'PUN-PRR-10',
        surveyNumber: 'Gat No. 16/3',
        village: 'Sus',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 8.90,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural',
        ownerName: 'Sambhaji More',
        status: 'ACQUIRED',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'VERIFIED',
        isAffected: true,
        polygon: [
          const LatLng(18.5800, 73.7230),
          const LatLng(18.5820, 73.7350),
          const LatLng(18.5660, 73.7370),
          const LatLng(18.5640, 73.7250),
        ],
      ),
      // 11. Lavale - Gat 204/1A (In Progress 🟠, Center Bisected by Highway)
      LandParcelModel(
        ulpin: 'ULPIN-MH-PUN-1024',
        surveyNumber: 'Gat No. 204/1A',
        village: 'Lavale',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 3.25,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural (Irrigated)',
        ownerName: 'Baburao Ramchandra Shinde',
        status: 'IN_PROGRESS',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'PENDING_REVIEW',
        isAffected: true,
        polygon: [
          const LatLng(18.5440, 73.7250),
          const LatLng(18.5460, 73.7380),
          const LatLng(18.5310, 73.7400),
          const LatLng(18.5290, 73.7270),
        ],
      ),
      // 12. Lavale - Gat 205/2B (In Progress 🟠, Left Side)
      LandParcelModel(
        ulpin: 'ULPIN-MH-PUN-1025',
        surveyNumber: 'Gat No. 205/2B',
        village: 'Lavale',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 2.80,
        classification: 'RESIDENTIAL',
        landType: 'Residential',
        ownerName: 'Kashinath G. Jadhav',
        status: 'IN_PROGRESS',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'SURVEYED',
        isAffected: true,
        polygon: [
          const LatLng(18.5290, 73.7260),
          const LatLng(18.5300, 73.7335),
          const LatLng(18.5180, 73.7350),
          const LatLng(18.5170, 73.7275),
        ],
      ),
      // 13. Pirangut - Gat 312/4 (In Progress 🟠, Right Side)
      LandParcelModel(
        ulpin: 'ULPIN-MH-PUN-1026',
        surveyNumber: 'Gat No. 312/4',
        village: 'Pirangut',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 4.10,
        classification: 'COMMERCIAL',
        landType: 'Commercial / Warehouse',
        ownerName: 'Shankar Mahadev Kadam',
        status: 'IN_PROGRESS',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'IN_PROGRESS',
        isAffected: true,
        polygon: [
          const LatLng(18.5300, 73.7335),
          const LatLng(18.5310, 73.7410),
          const LatLng(18.5190, 73.7425),
          const LatLng(18.5180, 73.7350),
        ],
      ),
      // 14. Bhugaon - Gat 318/1 (In Progress 🟠, Center Bisected by Highway)
      LandParcelModel(
        ulpin: 'PUN-PRR-14',
        surveyNumber: 'Gat No. 318/1',
        village: 'Bhugaon',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 5.40,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural',
        ownerName: 'Narayan S. Tapkir',
        status: 'IN_PROGRESS',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'IN_PROGRESS',
        isAffected: true,
        polygon: [
          const LatLng(18.4990, 73.7480),
          const LatLng(18.5010, 73.7620),
          const LatLng(18.4840, 73.7640),
          const LatLng(18.4820, 73.7500),
        ],
      ),
      // 15. Dhayari - Gat 401/1 (Pending 🔴, Left Side)
      LandParcelModel(
        ulpin: 'ULPIN-MH-PUN-1027',
        surveyNumber: 'Gat No. 401/1',
        village: 'Dhayari',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 5.60,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural',
        ownerName: 'Ananda Tukaram More',
        status: 'PENDING',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'NOT_STARTED',
        isAffected: true,
        polygon: [
          const LatLng(18.4690, 73.7710),
          const LatLng(18.4700, 73.7785),
          const LatLng(18.4560, 73.7800),
          const LatLng(18.4550, 73.7725),
        ],
      ),
      // 16. Dhayari - Gat 401/2 (Pending 🔴, Right Side)
      LandParcelModel(
        ulpin: 'PUN-PRR-16',
        surveyNumber: 'Gat No. 401/2',
        village: 'Dhayari',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 6.20,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural',
        ownerName: 'Santosh Vitthal Pokale',
        status: 'PENDING',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'NOT_STARTED',
        isAffected: true,
        polygon: [
          const LatLng(18.4700, 73.7785),
          const LatLng(18.4710, 73.7860),
          const LatLng(18.4570, 73.7875),
          const LatLng(18.4560, 73.7800),
        ],
      ),
      // 17. Khed Shivapur - Gat 78/1 (Pending 🔴, Left Side)
      LandParcelModel(
        ulpin: 'PUN-PRR-17',
        surveyNumber: 'Gat No. 78/1',
        village: 'Khed Shivapur',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 4.20,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural',
        ownerName: 'Dattatray B. Jagtap',
        status: 'PENDING',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'NOT_STARTED',
        isAffected: true,
        polygon: [
          const LatLng(18.3630, 73.8580),
          const LatLng(18.3640, 73.8655),
          const LatLng(18.3480, 73.8670),
          const LatLng(18.3470, 73.8595),
        ],
      ),
      // 18. Khed Shivapur - Gat 78/2 (Pending 🔴, Right Side)
      LandParcelModel(
        ulpin: 'PUN-PRR-18',
        surveyNumber: 'Gat No. 78/2',
        village: 'Khed Shivapur',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-001',
        projectName: 'Pune Ring Road Express Corridor (Phase-I)',
        areaHectares: 4.80,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural',
        ownerName: 'Vilas B. Jagtap',
        status: 'PENDING',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'NOT_STARTED',
        isAffected: true,
        polygon: [
          const LatLng(18.3640, 73.8655),
          const LatLng(18.3650, 73.8730),
          const LatLng(18.3490, 73.8745),
          const LatLng(18.3480, 73.8670),
        ],
      ),
    ];

    return ProjectCorridorModel(
      id: 'PRJ-MH-PUN-001',
      name: 'Pune Ring Road Express Corridor (Phase-I)',
      type: 'Highway',
      code: 'PRJ-MH-PUN-001',
      startPoint: 'Urse / Talegaon (Point A)',
      endPoint: 'Theur / Khed Shivapur (Point B)',
      startCoordinate: const LatLng(18.7240, 73.6540),
      endCoordinate: const LatLng(18.3580, 73.8680),
      totalLandRequired: 485.50,
      acquiredLand: 289.28,
      inProgressLand: 96.20,
      pendingLand: 100.02,
      totalParcels: 18,
      acquiredParcels: 10,
      inProgressParcels: 4,
      pendingParcels: 4,
      status: 'Ongoing',
      isDemo: true,
      lengthKm: 55.0,
      authority: 'Maharashtra State Road Development Corporation (MSRDC)',
      routeGeometry: routePoints,
      segments: segments,
      parcels: parcels,
    );
  }

  /// Demo Project 2: Pune-Nashik Semi-High Speed Rail Corridor
  /// Matches Web GIS DEMO_PROJECT_CORRIDORS[1]
  static ProjectCorridorModel get puneNashikRailCorridor {
    final routePoints = [
      const LatLng(18.5089, 73.9280), // Hadapsar Terminal (Point A)
      const LatLng(18.5850, 73.8820),
      const LatLng(18.6250, 73.8450), // Bhosari
      const LatLng(18.7610, 73.8590), // Chakan
      const LatLng(18.8580, 73.8850), // Rajgurunagar
      const LatLng(19.0060, 73.9400), // Manchar
      const LatLng(19.1250, 73.9780), // Narayangaon
      const LatLng(19.5720, 74.2050), // Sangamner
      const LatLng(19.8450, 73.9920), // Sinnar
      const LatLng(19.9975, 73.7890), // Nashik Road Station (Point B)
    ];

    final segments = [
      // Segment 1: Hadapsar - Bhosari Sector (Acquired)
      CorridorSegmentModel(
        id: 'PNR-SEG-01',
        projectId: 'PRJ-MH-PUN-002',
        name: 'Hadapsar - Bhosari Sector',
        status: AcquisitionStatus.acquired,
        lengthKm: 28.5,
        landAreaHa: 240.0,
        ulpins: [for (int i = 1; i <= 6; i++) 'PNR-HAD-0$i'],
        routeGeometry: [
          const LatLng(18.5089, 73.9280),
          const LatLng(18.5850, 73.8820),
          const LatLng(18.6250, 73.8450),
        ],
      ),
      // Segment 2: Chakan - Rajgurunagar Sector (Acquired)
      CorridorSegmentModel(
        id: 'PNR-SEG-02',
        projectId: 'PRJ-MH-PUN-002',
        name: 'Chakan - Rajgurunagar Sector',
        status: AcquisitionStatus.acquired,
        lengthKm: 34.0,
        landAreaHa: 190.0,
        ulpins: [for (int i = 1; i <= 8; i++) 'PNR-CHK-0$i'],
        routeGeometry: [
          const LatLng(18.6250, 73.8450),
          const LatLng(18.7610, 73.8590),
          const LatLng(18.8580, 73.8850),
        ],
      ),
      // Segment 3: Manchar - Narayangaon Sector (In Progress)
      CorridorSegmentModel(
        id: 'PNR-SEG-03',
        projectId: 'PRJ-MH-PUN-002',
        name: 'Manchar - Narayangaon Sector',
        status: AcquisitionStatus.inProgress,
        lengthKm: 42.0,
        landAreaHa: 140.0,
        ulpins: [for (int i = 1; i <= 5; i++) 'PNR-MCH-0$i'],
        routeGeometry: [
          const LatLng(18.8580, 73.8850),
          const LatLng(19.0060, 73.9400),
          const LatLng(19.1250, 73.9780),
        ],
      ),
      // Segment 4: Sangamner - Sinnar - Nashik Sector (Pending)
      CorridorSegmentModel(
        id: 'PNR-SEG-04',
        projectId: 'PRJ-MH-PUN-002',
        name: 'Sangamner - Sinnar - Nashik Sector',
        status: AcquisitionStatus.pending,
        lengthKm: 55.5,
        landAreaHa: 150.0,
        ulpins: [for (int i = 1; i <= 5; i++) 'PNR-SNG-0$i'],
        routeGeometry: [
          const LatLng(19.1250, 73.9780),
          const LatLng(19.5720, 74.2050),
          const LatLng(19.8450, 73.9920),
          const LatLng(19.9975, 73.7890),
        ],
      ),
    ];

    // 24 Parcels for Pune-Nashik Rail Corridor (14 Acquired, 5 In Progress, 5 Pending)
    final parcels = <LandParcelModel>[
      // Key Web GIS Parcels
      LandParcelModel(
        ulpin: 'PNR-HAD-01',
        surveyNumber: 'Gat No. 51/1',
        village: 'Hadapsar',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-002',
        projectName: 'Pune-Nashik Semi-High Speed Rail Corridor',
        areaHectares: 18.50,
        classification: 'COMMERCIAL',
        landType: 'Commercial / Station Yard',
        ownerName: 'Maharashtra Industrial Corp',
        status: 'ACQUIRED',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'VERIFIED',
        isAffected: true,
        polygon: [
          const LatLng(18.5130, 73.9240),
          const LatLng(18.5150, 73.9340),
          const LatLng(18.5030, 73.9360),
          const LatLng(18.5010, 73.9260),
        ],
      ),
      LandParcelModel(
        ulpin: 'PNR-CHK-01',
        surveyNumber: 'Gat No. 110/3',
        village: 'Chakan',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-002',
        projectName: 'Pune-Nashik Semi-High Speed Rail Corridor',
        areaHectares: 14.20,
        classification: 'INDUSTRIAL',
        landType: 'Industrial RoW',
        ownerName: 'Kirloskar Heavy Engineering',
        status: 'ACQUIRED',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'VERIFIED',
        isAffected: true,
        polygon: [
          const LatLng(18.7650, 73.8540),
          const LatLng(18.7670, 73.8640),
          const LatLng(18.7550, 73.8660),
          const LatLng(18.7530, 73.8560),
        ],
      ),
      LandParcelModel(
        ulpin: 'PNR-MCH-01',
        surveyNumber: 'Gat No. 88/2',
        village: 'Manchar',
        district: 'Pune',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-002',
        projectName: 'Pune-Nashik Semi-High Speed Rail Corridor',
        areaHectares: 9.60,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural (Irrigated)',
        ownerName: 'Dattatray Balu Thorat',
        status: 'IN_PROGRESS',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'IN_PROGRESS',
        isAffected: true,
        polygon: [
          const LatLng(19.0100, 73.9350),
          const LatLng(19.0120, 73.9450),
          const LatLng(19.0000, 73.9470),
          const LatLng(18.9980, 73.9370),
        ],
      ),
      LandParcelModel(
        ulpin: 'PNR-SNG-01',
        surveyNumber: 'Gat No. 302/1',
        village: 'Sangamner',
        district: 'Ahmednagar',
        state: 'Maharashtra',
        projectId: 'PRJ-MH-PUN-002',
        projectName: 'Pune-Nashik Semi-High Speed Rail Corridor',
        areaHectares: 22.00,
        classification: 'AGRICULTURAL',
        landType: 'Agricultural',
        ownerName: 'Shrikant Vitthalrao Deshmukh',
        status: 'PENDING',
        rowStatus: 'Corridor Intersects This Parcel',
        verificationStatus: 'NOT_STARTED',
        isAffected: true,
        polygon: [
          const LatLng(19.5760, 74.2000),
          const LatLng(19.5780, 74.2100),
          const LatLng(19.5660, 74.2120),
          const LatLng(19.5640, 74.2020),
        ],
      ),
    ];

    // Generate remaining parcels around the rail line
    // Remaining Acquired Parcels (12)
    for (int i = 2; i <= 13; i++) {
      final lat = 18.5200 + (i * 0.024);
      final lng = 73.9100 - (i * 0.005);
      parcels.add(
        LandParcelModel(
          ulpin: 'PNR-HAD-${i.toString().padLeft(2, '0')}',
          surveyNumber: 'Gat No. ${30 + i * 2}/${i % 3 + 1}',
          village: i <= 5 ? 'Hadapsar' : (i <= 9 ? 'Bhosari' : 'Chakan'),
          district: 'Pune',
          state: 'Maharashtra',
          projectId: 'PRJ-MH-PUN-002',
          projectName: 'Pune-Nashik Semi-High Speed Rail Corridor',
          areaHectares: 8.50 + (i * 0.8),
          classification: 'AGRICULTURAL',
          landType: 'Railway RoW / Agri',
          ownerName: 'Landholder PN-0$i',
          status: 'ACQUIRED',
          rowStatus: 'Corridor Intersects This Parcel',
          verificationStatus: 'VERIFIED',
          isAffected: true,
          polygon: [
            LatLng(lat + 0.005, lng - 0.004),
            LatLng(lat + 0.007, lng + 0.005),
            LatLng(lat - 0.005, lng + 0.006),
            LatLng(lat - 0.006, lng - 0.003),
          ],
        ),
      );
    }

    // Remaining In-Progress Parcels (4)
    for (int i = 2; i <= 5; i++) {
      final lat = 18.8800 + (i * 0.05);
      final lng = 73.8900 + (i * 0.02);
      parcels.add(
        LandParcelModel(
          ulpin: 'PNR-MCH-0$i',
          surveyNumber: 'Gat No. ${70 + i * 3}/${i % 2 + 1}',
          village: i <= 3 ? 'Manchar' : 'Narayangaon',
          district: 'Pune',
          state: 'Maharashtra',
          projectId: 'PRJ-MH-PUN-002',
          projectName: 'Pune-Nashik Semi-High Speed Rail Corridor',
          areaHectares: 7.20 + (i * 1.1),
          classification: 'AGRICULTURAL',
          landType: 'Agricultural (Irrigated)',
          ownerName: 'Landholder PN-IN-0$i',
          status: 'IN_PROGRESS',
          rowStatus: 'Corridor Intersects This Parcel',
          verificationStatus: 'IN_PROGRESS',
          isAffected: true,
          polygon: [
            LatLng(lat + 0.006, lng - 0.004),
            LatLng(lat + 0.007, lng + 0.005),
            LatLng(lat - 0.005, lng + 0.006),
            LatLng(lat - 0.006, lng - 0.003),
          ],
        ),
      );
    }

    // Remaining Pending Parcels (4)
    for (int i = 2; i <= 5; i++) {
      final lat = 19.6000 + (i * 0.08);
      final lng = 74.1500 - (i * 0.05);
      parcels.add(
        LandParcelModel(
          ulpin: 'PNR-SNG-0$i',
          surveyNumber: 'Gat No. ${110 + i * 4}/${i % 2 + 1}',
          village: i <= 3 ? 'Sinnar' : 'Nashik Road',
          district: 'Nashik',
          state: 'Maharashtra',
          projectId: 'PRJ-MH-PUN-002',
          projectName: 'Pune-Nashik Semi-High Speed Rail Corridor',
          areaHectares: 11.50 + (i * 1.4),
          classification: 'AGRICULTURAL',
          landType: 'Agricultural / Mixed',
          ownerName: 'Landholder PN-PEN-0$i',
          status: 'PENDING',
          rowStatus: 'Corridor Intersects This Parcel',
          verificationStatus: 'NOT_STARTED',
          isAffected: true,
          polygon: [
            LatLng(lat + 0.006, lng - 0.004),
            LatLng(lat + 0.007, lng + 0.005),
            LatLng(lat - 0.005, lng + 0.006),
            LatLng(lat - 0.006, lng - 0.003),
          ],
        ),
      );
    }

    return ProjectCorridorModel(
      id: 'PRJ-MH-PUN-002',
      name: 'Pune-Nashik Semi-High Speed Rail Corridor',
      type: 'Railway',
      code: 'PRJ-MH-PUN-002',
      startPoint: 'Hadapsar Terminal (Pune)',
      endPoint: 'Nashik Road Station',
      startCoordinate: const LatLng(18.5089, 73.9280),
      endCoordinate: const LatLng(19.9975, 73.7890),
      totalLandRequired: 720.00,
      acquiredLand: 430.00,
      inProgressLand: 140.00,
      pendingLand: 150.00,
      totalParcels: 24,
      acquiredParcels: 14,
      inProgressParcels: 5,
      pendingParcels: 5,
      status: 'Ongoing',
      isDemo: true,
      lengthKm: 235.0,
      authority: 'Maharashtra Rail Infrastructure Development Corp (MAHARIL)',
      routeGeometry: routePoints,
      segments: segments,
      parcels: parcels,
    );
  }

  static List<ProjectCorridorModel> getAllProjects() {
    return [puneRingRoadCorridor, puneNashikRailCorridor];
  }
}
