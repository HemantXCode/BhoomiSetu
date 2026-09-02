import 'package:latlong2/latlong.dart';
import '../../models/project_corridor_model.dart';
import '../../models/land_parcel_model.dart';

class ProjectCorridorDemoData {
  /// Demo Project 1: Pune Ring Road Corridor (Highway)
  static ProjectCorridorModel get puneRingRoadCorridor {
    // Detailed polyline route from Talegaon/Urse (North-West) to Theur/Khed Shivapur (South-East)
    final routePoints = [
      const LatLng(18.7180, 73.6540), // Urse / Talegaon Interchange (Point A)
      const LatLng(18.6850, 73.6820), // Parandwadi
      const LatLng(18.6520, 73.7050), // Hinjawadi Phase 3
      const LatLng(18.6180, 73.7210), // Marunji
      const LatLng(18.5720, 73.7290), // Sus / Nande
      const LatLng(18.5362, 73.7314), // Lavale
      const LatLng(18.5124, 73.6845), // Pirangut
      const LatLng(18.4982, 73.7468), // Bhugaon
      const LatLng(18.4612, 73.7780), // NDA / Uttamnagar
      const LatLng(18.4230, 73.8120), // Dhayari / Khadakwasla
      const LatLng(18.3890, 73.8450), // Kondhanpur / Sinhagad Base
      const LatLng(18.3540, 73.8650), // Khed Shivapur / Theur Link (Point B)
    ];

    final segments = [
      // Segment 1: Urse to Hinjawadi (Acquired)
      CorridorSegmentModel(
        id: 'PRR-SEG-01',
        projectId: 'PRJ-MH-PUN-001',
        name: 'Urse - Hinjawadi Phase',
        status: AcquisitionStatus.acquired,
        lengthKm: 14.2,
        landAreaHa: 165.5,
        ulpins: ['PUN-PRR-01', 'PUN-PRR-02', 'PUN-PRR-03', 'PUN-PRR-04', 'PUN-PRR-05'],
        routeGeometry: [
          const LatLng(18.7180, 73.6540),
          const LatLng(18.6850, 73.6820),
          const LatLng(18.6520, 73.7050),
        ],
      ),
      // Segment 2: Hinjawadi to Sus/Lavale (Acquired)
      CorridorSegmentModel(
        id: 'PRR-SEG-02',
        projectId: 'PRJ-MH-PUN-001',
        name: 'Hinjawadi - Lavale Sector',
        status: AcquisitionStatus.acquired,
        lengthKm: 12.8,
        landAreaHa: 123.78,
        ulpins: ['PUN-PRR-06', 'PUN-PRR-07', 'PUN-PRR-08', 'PUN-PRR-09', 'PUN-PRR-10'],
        routeGeometry: [
          const LatLng(18.6520, 73.7050),
          const LatLng(18.6180, 73.7210),
          const LatLng(18.5720, 73.7290),
          const LatLng(18.5362, 73.7314),
        ],
      ),
      // Segment 3: Lavale to Bhugaon/Pirangut (In Progress)
      CorridorSegmentModel(
        id: 'PRR-SEG-03',
        projectId: 'PRJ-MH-PUN-001',
        name: 'Pirangut - Bhugaon Sector',
        status: AcquisitionStatus.inProgress,
        lengthKm: 11.5,
        landAreaHa: 96.20,
        ulpins: ['ULPIN-MH-PUN-1024', 'ULPIN-MH-PUN-1025', 'ULPIN-MH-PUN-1026', 'PUN-PRR-11'],
        routeGeometry: [
          const LatLng(18.5362, 73.7314),
          const LatLng(18.5124, 73.6845),
          const LatLng(18.4982, 73.7468),
          const LatLng(18.4612, 73.7780),
        ],
      ),
      // Segment 4: Dhayari to Khed Shivapur (Pending)
      CorridorSegmentModel(
        id: 'PRR-SEG-04',
        projectId: 'PRJ-MH-PUN-001',
        name: 'Dhayari - Khed Shivapur Sector',
        status: AcquisitionStatus.pending,
        lengthKm: 16.5,
        landAreaHa: 100.02,
        ulpins: ['ULPIN-MH-PUN-1027', 'PUN-PRR-12', 'PUN-PRR-13', 'PUN-PRR-14'],
        routeGeometry: [
          const LatLng(18.4612, 73.7780),
          const LatLng(18.4230, 73.8120),
          const LatLng(18.3890, 73.8450),
          const LatLng(18.3540, 73.8650),
        ],
      ),
    ];

    // 18 Parcels for Pune Ring Road: 10 Acquired, 4 In Progress, 4 Pending
    final parcels = [
      // Acquired Parcels (10)
      LandParcelModel(
        ulpin: 'PUN-PRR-01',
        surveyNumber: '12/1',
        village: 'Urse',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 32500.0,
        latitude: 18.7145,
        longitude: 73.6580,
        landType: 'Agricultural (Irrigated)',
        ownerName: 'Vasantrao B. Gade',
        status: 'ACQUIRED',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-02',
        surveyNumber: '28/4',
        village: 'Parandwadi',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 28400.0,
        latitude: 18.6820,
        longitude: 73.6850,
        landType: 'Agricultural',
        ownerName: 'Anandrao K. Shinde',
        status: 'ACQUIRED',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-03',
        surveyNumber: '95/2A',
        village: 'Marunji',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 19800.0,
        latitude: 18.6210,
        longitude: 73.7190,
        landType: 'Commercial Non-Agri',
        ownerName: 'Ganesh S. More',
        status: 'ACQUIRED',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-04',
        surveyNumber: '104/1',
        village: 'Hinjawadi',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 41200.0,
        latitude: 18.6490,
        longitude: 73.7080,
        landType: 'Industrial / Commercial',
        ownerName: 'Techzone Developers LLP',
        status: 'ACQUIRED',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-05',
        surveyNumber: '63/2',
        village: 'Sus',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 22600.0,
        latitude: 18.5750,
        longitude: 73.7270,
        landType: 'Agricultural',
        ownerName: 'Chandrakant M. Pawar',
        status: 'ACQUIRED',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-06',
        surveyNumber: '88/1B',
        village: 'Nande',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 31000.0,
        latitude: 18.5620,
        longitude: 73.7295,
        landType: 'Agricultural (Dry Crop)',
        ownerName: 'Rameshwar T. Jagtap',
        status: 'ACQUIRED',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-07',
        surveyNumber: '205/4',
        village: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 3100.0,
        latitude: 18.4612,
        longitude: 73.8621,
        landType: 'Agricultural',
        ownerName: 'CALA Approved Land Holder',
        status: 'ACQUIRED',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-08',
        surveyNumber: '14/3',
        village: 'Urse',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 18900.0,
        latitude: 18.7090,
        longitude: 73.6620,
        landType: 'Agricultural',
        ownerName: 'Sopan D. Jadhav',
        status: 'ACQUIRED',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-09',
        surveyNumber: '42/1',
        village: 'Marunji',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 24500.0,
        latitude: 18.6140,
        longitude: 73.7240,
        landType: 'Agricultural',
        ownerName: 'Bhikaji R. Gaikwad',
        status: 'ACQUIRED',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-10',
        surveyNumber: '51/2',
        village: 'Sus',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 27800.0,
        latitude: 18.5810,
        longitude: 73.7250,
        landType: 'Agricultural',
        ownerName: 'Kashinath V. Kadam',
        status: 'ACQUIRED',
      ),

      // In Progress Parcels (4)
      LandParcelModel(
        ulpin: 'ULPIN-MH-PUN-1024',
        surveyNumber: '48/2A',
        village: 'Bhugaon',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 4250.0,
        latitude: 18.498214,
        longitude: 73.746820,
        landType: 'Agricultural (Irrigated)',
        ownerName: 'Suresh Babanrao Patil',
        status: 'IN_PROGRESS',
      ),
      LandParcelModel(
        ulpin: 'ULPIN-MH-PUN-1025',
        surveyNumber: '112/1B',
        village: 'Lavale',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 8120.5,
        latitude: 18.536240,
        longitude: 73.731410,
        landType: 'Agricultural (Dry Crop)',
        ownerName: 'Sunita Dinkar Gholap',
        status: 'IN_PROGRESS',
      ),
      LandParcelModel(
        ulpin: 'ULPIN-MH-PUN-1026',
        surveyNumber: '74/3',
        village: 'Pirangut',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 6400.0,
        latitude: 18.512450,
        longitude: 73.684520,
        landType: 'Commercial / Warehouse',
        ownerName: 'Kishore Mahadev Jagtap',
        status: 'IN_PROGRESS',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-11',
        surveyNumber: '37/1',
        village: 'Uttamnagar',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 14200.0,
        latitude: 18.4680,
        longitude: 73.7720,
        landType: 'Residential Non-Agri',
        ownerName: 'Devidas N. Salunkhe',
        status: 'IN_PROGRESS',
      ),

      // Pending Parcels (4)
      LandParcelModel(
        ulpin: 'ULPIN-MH-PUN-1027',
        surveyNumber: '19/A',
        village: 'Mulshi',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 12800.0,
        latitude: 18.503410,
        longitude: 73.518730,
        landType: 'Fallow / Forest Fringe',
        ownerName: 'Dattatray Anandrao Deshmukh',
        status: 'PENDING',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-12',
        surveyNumber: '83/2',
        village: 'Dhayari',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 16500.0,
        latitude: 18.4280,
        longitude: 73.8080,
        landType: 'Agricultural (Irrigated)',
        ownerName: 'Manohar P. Joshi',
        status: 'PENDING',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-13',
        surveyNumber: '109/4',
        village: 'Kondhanpur',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 29000.0,
        latitude: 18.3910,
        longitude: 73.8410,
        landType: 'Hill Slope / Fallow',
        ownerName: 'Baban S. Ghule',
        status: 'PENDING',
      ),
      LandParcelModel(
        ulpin: 'PUN-PRR-14',
        surveyNumber: '55/1A',
        village: 'Khed Shivapur',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 38200.0,
        latitude: 18.3580,
        longitude: 73.8610,
        landType: 'Agricultural',
        ownerName: 'Pandurang G. Chavan',
        status: 'PENDING',
      ),
    ];

    return ProjectCorridorModel(
      id: 'PRJ-MH-PUN-001',
      name: 'Pune Ring Road Corridor',
      type: 'Highway',
      code: 'PRR-EC-2026',
      startPoint: 'Urse / Talegaon (Point A)',
      endPoint: 'Khed Shivapur / Theur (Point B)',
      startCoordinate: const LatLng(18.7180, 73.6540),
      endCoordinate: const LatLng(18.3540, 73.8650),
      totalLandRequired: 485.5,
      acquiredLand: 289.28,
      inProgressLand: 96.20,
      pendingLand: 100.02,
      totalParcels: 18,
      acquiredParcels: 10,
      inProgressParcels: 4,
      pendingParcels: 4,
      status: 'Ongoing',
      isDemo: true,
      lengthKm: 65.0,
      authority: 'Maharashtra State Road Development Corporation (MSRDC)',
      routeGeometry: routePoints,
      segments: segments,
      parcels: parcels,
    );
  }

  /// Demo Project 2: Pune-Nashik Rail Corridor (Railway)
  static ProjectCorridorModel get puneNashikRailCorridor {
    final routePoints = [
      const LatLng(18.5089, 73.9260), // Hadapsar (Point A)
      const LatLng(18.5670, 73.9120), // Pune Airport North / Vishrantwadi
      const LatLng(18.6250, 73.8430), // Bhosari Industrial Sector
      const LatLng(18.7540, 73.8540), // Chakan Auto Hub
      const LatLng(18.9430, 73.8920), // Rajgurunagar
      const LatLng(19.1230, 73.9780), // Narayangaon
      const LatLng(19.3450, 74.0210), // Alephata
      const LatLng(19.5740, 74.2140), // Sangamner
      const LatLng(19.8450, 73.9870), // Sinnar
      const LatLng(19.9540, 73.8340), // Nashik Road Terminal (Point B)
    ];

    final segments = [
      // Segment 1: Hadapsar to Bhosari (Acquired)
      CorridorSegmentModel(
        id: 'PNR-SEG-01',
        projectId: 'PRJ-MH-PUN-002',
        name: 'Hadapsar - Bhosari Sector',
        status: AcquisitionStatus.acquired,
        lengthKm: 18.4,
        landAreaHa: 220.0,
        ulpins: ['PUN-PNR-01', 'PUN-PNR-02', 'PUN-PNR-03', 'PUN-PNR-04', 'PUN-PNR-05', 'PUN-PNR-06', 'PUN-PNR-07'],
        routeGeometry: [
          const LatLng(18.5089, 73.9260),
          const LatLng(18.5670, 73.9120),
          const LatLng(18.6250, 73.8430),
        ],
      ),
      // Segment 2: Bhosari to Chakan & Rajgurunagar (Acquired)
      CorridorSegmentModel(
        id: 'PNR-SEG-02',
        projectId: 'PRJ-MH-PUN-002',
        name: 'Chakan - Rajgurunagar Sector',
        status: AcquisitionStatus.acquired,
        lengthKm: 32.0,
        landAreaHa: 210.0,
        ulpins: ['PUN-PNR-08', 'PUN-PNR-09', 'PUN-PNR-10', 'PUN-PNR-11', 'PUN-PNR-12', 'PUN-PNR-13', 'PUN-PNR-14'],
        routeGeometry: [
          const LatLng(18.6250, 73.8430),
          const LatLng(18.7540, 73.8540),
          const LatLng(18.9430, 73.8920),
        ],
      ),
      // Segment 3: Narayangaon to Sangamner (In Progress)
      CorridorSegmentModel(
        id: 'PNR-SEG-03',
        projectId: 'PRJ-MH-PUN-002',
        name: 'Narayangaon - Sangamner Sector',
        status: AcquisitionStatus.inProgress,
        lengthKm: 48.5,
        landAreaHa: 140.0,
        ulpins: ['PUN-PNR-15', 'PUN-PNR-16', 'PUN-PNR-17', 'PUN-PNR-18', 'PUN-PNR-19'],
        routeGeometry: [
          const LatLng(18.9430, 73.8920),
          const LatLng(19.1230, 73.9780),
          const LatLng(19.3450, 74.0210),
          const LatLng(19.5740, 74.2140),
        ],
      ),
      // Segment 4: Sangamner to Nashik Road (Pending)
      CorridorSegmentModel(
        id: 'PNR-SEG-04',
        projectId: 'PRJ-MH-PUN-002',
        name: 'Sinnar - Nashik Road Terminal',
        status: AcquisitionStatus.pending,
        lengthKm: 45.0,
        landAreaHa: 150.0,
        ulpins: ['PUN-PNR-20', 'PUN-PNR-21', 'PUN-PNR-22', 'PUN-PNR-23', 'PUN-PNR-24'],
        routeGeometry: [
          const LatLng(19.5740, 74.2140),
          const LatLng(19.8450, 73.9870),
          const LatLng(19.9540, 73.8340),
        ],
      ),
    ];

    // 24 Parcels for Pune-Nashik Rail: 14 Acquired, 5 In Progress, 5 Pending
    final parcels = [
      // Acquired Parcels (14)
      for (int i = 1; i <= 14; i++)
        LandParcelModel(
          ulpin: 'PUN-PNR-${i.toString().padLeft(2, '0')}',
          surveyNumber: '${30 + i * 3}/${i % 4 + 1}',
          village: i <= 5 ? 'Hadapsar' : (i <= 9 ? 'Bhosari' : 'Chakan'),
          district: 'Pune',
          state: 'Maharashtra',
          landAreaSqM: 25000.0 + (i * 2100.0),
          latitude: 18.5200 + (i * 0.025),
          longitude: 73.9100 - (i * 0.005),
          landType: 'Railway ROW / Agri',
          ownerName: 'Landowner PN-$i',
          status: 'ACQUIRED',
        ),

      // In Progress Parcels (5)
      for (int i = 15; i <= 19; i++)
        LandParcelModel(
          ulpin: 'PUN-PNR-$i',
          surveyNumber: '${80 + i * 2}/${i % 3 + 1}',
          village: i <= 17 ? 'Narayangaon' : 'Sangamner',
          district: i <= 17 ? 'Pune' : 'Ahmednagar',
          state: 'Maharashtra',
          landAreaSqM: 32000.0 + (i * 1500.0),
          latitude: 19.0500 + ((i - 15) * 0.12),
          longitude: 73.9500 + ((i - 15) * 0.05),
          landType: 'Agricultural (Irrigated)',
          ownerName: 'Landowner PN-$i',
          status: 'IN_PROGRESS',
        ),

      // Pending Parcels (5)
      for (int i = 20; i <= 24; i++)
        LandParcelModel(
          ulpin: 'PUN-PNR-$i',
          surveyNumber: '${120 + i}/${i % 2 + 1}',
          village: i <= 22 ? 'Sinnar' : 'Nashik Road',
          district: 'Nashik',
          state: 'Maharashtra',
          landAreaSqM: 28000.0 + (i * 1800.0),
          latitude: 19.6500 + ((i - 20) * 0.08),
          longitude: 74.0500 - ((i - 20) * 0.05),
          landType: 'Commercial / Residential Fringe',
          ownerName: 'Landowner PN-$i',
          status: 'PENDING',
        ),
    ];

    return ProjectCorridorModel(
      id: 'PRJ-MH-PUN-002',
      name: 'Pune-Nashik Rail Corridor',
      type: 'Railway',
      code: 'PNR-SHT-2026',
      startPoint: 'Hadapsar / Pune (Point A)',
      endPoint: 'Nashik Road Terminal (Point B)',
      startCoordinate: const LatLng(18.5089, 73.9260),
      endCoordinate: const LatLng(19.9540, 73.8340),
      totalLandRequired: 720.0,
      acquiredLand: 430.0,
      inProgressLand: 140.0,
      pendingLand: 150.0,
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
