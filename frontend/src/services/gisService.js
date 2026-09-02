import api from './api';

// Demonstration Corridor Data (Pune Ring Road & Pune-Nashik Rail Corridor)
// Explicitly mapped to intersect the demo cadastral land parcels
const DEMO_PROJECT_CORRIDORS = [
  {
    id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    project_code: 'PRJ-MH-PUN-001',
    project_type: 'Highway',
    state: 'Maharashtra',
    district: 'Pune',
    start_point: 'Urse / Talegaon (Point A)',
    end_point: 'Theur / Khed Shivapur (Point B)',
    total_land_ha: 485.50,
    acquired_land_ha: 289.28,
    in_progress_land_ha: 96.20,
    pending_land_ha: 100.02,
    total_parcels: 18,
    acquired_parcels: 10,
    in_progress_parcels: 4,
    pending_parcels: 4,
    segments: [
      {
        id: 'PRR-SEG-01',
        name: 'Urse - Hinjawadi Sector',
        status: 'ACQUIRED',
        length_km: 14.2,
        land_area_ha: 165.50,
        coordinates: [
          [18.7240, 73.6540],
          [18.7150, 73.6550],
          [18.6870, 73.6820],
          [18.6520, 73.7085]
        ]
      },
      {
        id: 'PRR-SEG-02',
        name: 'Hinjawadi - Lavale Sector',
        status: 'ACQUIRED',
        length_km: 12.8,
        land_area_ha: 123.78,
        coordinates: [
          [18.6520, 73.7085],
          [18.6130, 73.7160],
          [18.5730, 73.7370],
          [18.5370, 73.7330]
        ]
      },
      {
        id: 'PRR-SEG-03',
        name: 'Lavale - Pirangut - Bhugaon Sector',
        status: 'IN_PROGRESS',
        length_km: 11.5,
        land_area_ha: 96.20,
        coordinates: [
          [18.5370, 73.7330],
          [18.5280, 73.7345],
          [18.4960, 73.7470],
          [18.4640, 73.7810]
        ]
      },
      {
        id: 'PRR-SEG-04',
        name: 'Dhayari - Khed Shivapur Sector',
        status: 'PENDING',
        length_km: 16.5,
        land_area_ha: 100.02,
        coordinates: [
          [18.4640, 73.7810],
          [18.4200, 73.8180],
          [18.3850, 73.8480],
          [18.3580, 73.8680]
        ]
      }
    ]
  },
  {
    id: 2,
    project_name: 'Pune-Nashik Semi-High Speed Rail Corridor',
    project_code: 'PRJ-MH-PUN-002',
    project_type: 'Railway',
    state: 'Maharashtra',
    district: 'Pune',
    start_point: 'Hadapsar Terminal (Pune)',
    end_point: 'Nashik Road Station',
    total_land_ha: 720.00,
    acquired_land_ha: 430.00,
    in_progress_land_ha: 140.00,
    pending_land_ha: 150.00,
    total_parcels: 24,
    acquired_parcels: 14,
    in_progress_parcels: 5,
    pending_parcels: 5,
    segments: [
      {
        id: 'PNR-SEG-01',
        name: 'Hadapsar - Bhosari Sector',
        status: 'ACQUIRED',
        length_km: 28.5,
        land_area_ha: 240.00,
        coordinates: [
          [18.5089, 73.9280],
          [18.5850, 73.8820],
          [18.6250, 73.8450]
        ]
      },
      {
        id: 'PNR-SEG-02',
        name: 'Chakan - Rajgurunagar Sector',
        status: 'ACQUIRED',
        length_km: 34.0,
        land_area_ha: 190.00,
        coordinates: [
          [18.6250, 73.8450],
          [18.7610, 73.8590],
          [18.8580, 73.8850]
        ]
      },
      {
        id: 'PNR-SEG-03',
        name: 'Manchar - Narayangaon Sector',
        status: 'IN_PROGRESS',
        length_km: 42.0,
        land_area_ha: 140.00,
        coordinates: [
          [18.8580, 73.8850],
          [19.0060, 73.9400],
          [19.1250, 73.9780]
        ]
      },
      {
        id: 'PNR-SEG-04',
        name: 'Sangamner - Sinnar - Nashik Sector',
        status: 'PENDING',
        length_km: 55.5,
        land_area_ha: 150.00,
        coordinates: [
          [19.1250, 73.9780],
          [19.5720, 74.2050],
          [19.8450, 73.9920],
          [19.9975, 73.7890]
        ]
      }
    ]
  }
];

// 18 Cadastral Parcels for Pune Ring Road Express Corridor (Phase-I)
// Positioned directly around/intersected by the corridor highway alignment
const DEMO_PARCELS = [
  // 1. Urse - Gat 142/1 (Acquired 🟢, Center Bisected by Highway)
  {
    id: 1,
    ulpin: 'PUN-PRR-01',
    survey_number: 'Gat No. 142/1',
    village: 'Urse',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 12.50,
    classification: 'AGRICULTURAL',
    owner_name: 'Ramesh Chandra Patil',
    status: 'ACQUIRED',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'VERIFIED',
    last_updated: '2026-08-28',
    polygon: [
      [18.7250, 73.6490],
      [18.7270, 73.6590],
      [18.7190, 73.6600],
      [18.7170, 73.6500]
    ]
  },
  // 2. Urse - Gat 142/2 (Acquired 🟢, Left Side)
  {
    id: 2,
    ulpin: 'PUN-PRR-02',
    survey_number: 'Gat No. 142/2',
    village: 'Urse',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 8.20,
    classification: 'AGRICULTURAL',
    owner_name: 'Sunita Deshmukh',
    status: 'ACQUIRED',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'VERIFIED',
    last_updated: '2026-08-29',
    polygon: [
      [18.7170, 73.6480],
      [18.7180, 73.6540],
      [18.7090, 73.6560],
      [18.7080, 73.6500]
    ]
  },
  // 3. Gahunje - Gat 89/1A (Acquired 🟢, Right Side)
  {
    id: 3,
    ulpin: 'PUN-PRR-03',
    survey_number: 'Gat No. 89/1A',
    village: 'Gahunje',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 6.40,
    classification: 'AGRICULTURAL',
    owner_name: 'Vasantrao Gaikwad',
    status: 'ACQUIRED',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'VERIFIED',
    last_updated: '2026-08-20',
    polygon: [
      [18.7180, 73.6540],
      [18.7190, 73.6620],
      [18.7100, 73.6640],
      [18.7090, 73.6560]
    ]
  },
  // 4. Gahunje - Gat 89/2B (Acquired 🟢, Center Bisected by Highway)
  {
    id: 4,
    ulpin: 'PUN-PRR-04',
    survey_number: 'Gat No. 89/2B',
    village: 'Gahunje',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 9.80,
    classification: 'AGRICULTURAL',
    owner_name: 'Pandurang S. Shinde',
    status: 'ACQUIRED',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'VERIFIED',
    last_updated: '2026-08-21',
    polygon: [
      [18.6930, 73.6760],
      [18.6950, 73.6880],
      [18.6810, 73.6900],
      [18.6790, 73.6780]
    ]
  },
  // 5. Hinjawadi - Gat 44/1 (Acquired 🟢, Left Side)
  {
    id: 5,
    ulpin: 'PUN-PRR-05',
    survey_number: 'Gat No. 44/1',
    village: 'Hinjawadi',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 7.50,
    classification: 'COMMERCIAL',
    owner_name: 'Rajendra P. Sutar',
    status: 'ACQUIRED',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'VERIFIED',
    last_updated: '2026-08-22',
    polygon: [
      [18.6570, 73.6990],
      [18.6590, 73.7055],
      [18.6480, 73.7070],
      [18.6460, 73.7005]
    ]
  },
  // 6. Hinjawadi - Gat 44/2 (Acquired 🟢, Right Side)
  {
    id: 6,
    ulpin: 'PUN-PRR-06',
    survey_number: 'Gat No. 44/2',
    village: 'Hinjawadi',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 5.20,
    classification: 'COMMERCIAL',
    owner_name: 'Pravin Maruti Jadhav',
    status: 'ACQUIRED',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'VERIFIED',
    last_updated: '2026-08-23',
    polygon: [
      [18.6590, 73.7055],
      [18.6610, 73.7120],
      [18.6500, 73.7135],
      [18.6480, 73.7070]
    ]
  },
  // 7. Wakad - Gat 102/1 (Acquired 🟢, Center Bisected by Highway)
  {
    id: 7,
    ulpin: 'PUN-PRR-07',
    survey_number: 'Gat No. 102/1',
    village: 'Wakad',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 11.20,
    classification: 'RESIDENTIAL',
    owner_name: 'Babanrao Kadam',
    status: 'ACQUIRED',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'VERIFIED',
    last_updated: '2026-08-24',
    polygon: [
      [18.6260, 73.7150],
      [18.6280, 73.7270],
      [18.6120, 73.7290],
      [18.6100, 73.7170]
    ]
  },
  // 8. Marunji - Gat 105/1 (Acquired 🟢, Left Side)
  {
    id: 8,
    ulpin: 'PUN-PRR-08',
    survey_number: 'Gat No. 105/1',
    village: 'Marunji',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 4.80,
    classification: 'AGRICULTURAL',
    owner_name: 'Anil Narayan Deshmukh',
    status: 'ACQUIRED',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'VERIFIED',
    last_updated: '2026-08-25',
    polygon: [
      [18.6100, 73.7150],
      [18.6110, 73.7215],
      [18.5990, 73.7230],
      [18.5980, 73.7165]
    ]
  },
  // 9. Marunji - Gat 105/2 (Acquired 🟢, Right Side)
  {
    id: 9,
    ulpin: 'PUN-PRR-09',
    survey_number: 'Gat No. 105/2',
    village: 'Marunji',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 6.30,
    classification: 'AGRICULTURAL',
    owner_name: 'Vijay D. Thorat',
    status: 'ACQUIRED',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'VERIFIED',
    last_updated: '2026-08-26',
    polygon: [
      [18.6110, 73.7215],
      [18.6120, 73.7280],
      [18.6000, 73.7295],
      [18.5990, 73.7230]
    ]
  },
  // 10. Sus - Gat 16/3 (Acquired 🟢, Center Bisected by Highway)
  {
    id: 10,
    ulpin: 'PUN-PRR-10',
    survey_number: 'Gat No. 16/3',
    village: 'Sus',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 8.90,
    classification: 'AGRICULTURAL',
    owner_name: 'Sambhaji More',
    status: 'ACQUIRED',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'VERIFIED',
    last_updated: '2026-08-27',
    polygon: [
      [18.5800, 73.7230],
      [18.5820, 73.7350],
      [18.5660, 73.7370],
      [18.5640, 73.7250]
    ]
  },
  // 11. Lavale - Gat 204/1A (In Progress 🟠, Center Bisected by Highway)
  {
    id: 11,
    ulpin: 'ULPIN-MH-PUN-1024',
    survey_number: 'Gat No. 204/1A',
    village: 'Lavale',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 3.25,
    classification: 'AGRICULTURAL',
    owner_name: 'Baburao Ramchandra Shinde',
    status: 'IN_PROGRESS',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'PENDING_REVIEW',
    last_updated: '2026-09-01',
    polygon: [
      [18.5440, 73.7250],
      [18.5460, 73.7380],
      [18.5310, 73.7400],
      [18.5290, 73.7270]
    ]
  },
  // 12. Lavale - Gat 205/2B (In Progress 🟠, Left Side)
  {
    id: 12,
    ulpin: 'ULPIN-MH-PUN-1025',
    survey_number: 'Gat No. 205/2B',
    village: 'Lavale',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 2.80,
    classification: 'RESIDENTIAL',
    owner_name: 'Kashinath G. Jadhav',
    status: 'IN_PROGRESS',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'SURVEYED',
    last_updated: '2026-09-02',
    polygon: [
      [18.5290, 73.7260],
      [18.5300, 73.7335],
      [18.5180, 73.7350],
      [18.5170, 73.7275]
    ]
  },
  // 13. Pirangut - Gat 312/4 (In Progress 🟠, Right Side)
  {
    id: 13,
    ulpin: 'ULPIN-MH-PUN-1026',
    survey_number: 'Gat No. 312/4',
    village: 'Pirangut',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 4.10,
    classification: 'COMMERCIAL',
    owner_name: 'Shankar Mahadev Kadam',
    status: 'IN_PROGRESS',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'IN_PROGRESS',
    last_updated: '2026-08-30',
    polygon: [
      [18.5300, 73.7335],
      [18.5310, 73.7410],
      [18.5190, 73.7425],
      [18.5180, 73.7350]
    ]
  },
  // 14. Bhugaon - Gat 318/1 (In Progress 🟠, Center Bisected by Highway)
  {
    id: 14,
    ulpin: 'PUN-PRR-14',
    survey_number: 'Gat No. 318/1',
    village: 'Bhugaon',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 5.40,
    classification: 'AGRICULTURAL',
    owner_name: 'Narayan S. Tapkir',
    status: 'IN_PROGRESS',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'IN_PROGRESS',
    last_updated: '2026-08-31',
    polygon: [
      [18.4990, 73.7480],
      [18.5010, 73.7620],
      [18.4840, 73.7640],
      [18.4820, 73.7500]
    ]
  },
  // 15. Dhayari - Gat 401/1 (Pending 🔴, Left Side)
  {
    id: 15,
    ulpin: 'ULPIN-MH-PUN-1027',
    survey_number: 'Gat No. 401/1',
    village: 'Dhayari',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 5.60,
    classification: 'AGRICULTURAL',
    owner_name: 'Ananda Tukaram More',
    status: 'PENDING',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'NOT_STARTED',
    last_updated: '2026-08-25',
    polygon: [
      [18.4690, 73.7710],
      [18.4700, 73.7785],
      [18.4560, 73.7800],
      [18.4550, 73.7725]
    ]
  },
  // 16. Dhayari - Gat 401/2 (Pending 🔴, Right Side)
  {
    id: 16,
    ulpin: 'PUN-PRR-16',
    survey_number: 'Gat No. 401/2',
    village: 'Dhayari',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 6.20,
    classification: 'AGRICULTURAL',
    owner_name: 'Santosh Vitthal Pokale',
    status: 'PENDING',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'NOT_STARTED',
    last_updated: '2026-08-26',
    polygon: [
      [18.4700, 73.7785],
      [18.4710, 73.7860],
      [18.4570, 73.7875],
      [18.4560, 73.7800]
    ]
  },
  // 17. Khed Shivapur - Gat 78/1 (Pending 🔴, Left Side)
  {
    id: 17,
    ulpin: 'PUN-PRR-17',
    survey_number: 'Gat No. 78/1',
    village: 'Khed Shivapur',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 4.20,
    classification: 'AGRICULTURAL',
    owner_name: 'Dattatray B. Jagtap',
    status: 'PENDING',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'NOT_STARTED',
    last_updated: '2026-08-14',
    polygon: [
      [18.3630, 73.8580],
      [18.3640, 73.8655],
      [18.3480, 73.8670],
      [18.3470, 73.8595]
    ]
  },
  // 18. Khed Shivapur - Gat 78/2 (Pending 🔴, Right Side)
  {
    id: 18,
    ulpin: 'PUN-PRR-18',
    survey_number: 'Gat No. 78/2',
    village: 'Khed Shivapur',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 1,
    project_name: 'Pune Ring Road Express Corridor (Phase-I)',
    area_hectares: 4.80,
    classification: 'AGRICULTURAL',
    owner_name: 'Vilas B. Jagtap',
    status: 'PENDING',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'NOT_STARTED',
    last_updated: '2026-08-15',
    polygon: [
      [18.3640, 73.8655],
      [18.3650, 73.8730],
      [18.3490, 73.8745],
      [18.3480, 73.8670]
    ]
  },
  // 24 Parcels for Pune-Nashik Rail Corridor (PRJ-MH-PUN-002)
  {
    id: 19,
    ulpin: 'PNR-HAD-01',
    survey_number: 'Gat No. 51/1',
    village: 'Hadapsar',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 2,
    project_name: 'Pune-Nashik Semi-High Speed Rail Corridor',
    area_hectares: 18.50,
    classification: 'COMMERCIAL',
    owner_name: 'Maharashtra Industrial Corp',
    status: 'ACQUIRED',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'VERIFIED',
    last_updated: '2026-08-18',
    polygon: [
      [18.5130, 73.9240],
      [18.5150, 73.9340],
      [18.5030, 73.9360],
      [18.5010, 73.9260]
    ]
  },
  {
    id: 20,
    ulpin: 'PNR-CHK-01',
    survey_number: 'Gat No. 110/3',
    village: 'Chakan',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 2,
    project_name: 'Pune-Nashik Semi-High Speed Rail Corridor',
    area_hectares: 14.20,
    classification: 'INDUSTRIAL',
    owner_name: 'Kirloskar Heavy Engineering',
    status: 'ACQUIRED',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'VERIFIED',
    last_updated: '2026-08-19',
    polygon: [
      [18.7650, 73.8540],
      [18.7670, 73.8640],
      [18.7550, 73.8660],
      [18.7530, 73.8560]
    ]
  },
  {
    id: 21,
    ulpin: 'PNR-MCH-01',
    survey_number: 'Gat No. 88/2',
    village: 'Manchar',
    district: 'Pune',
    state: 'Maharashtra',
    project_id: 2,
    project_name: 'Pune-Nashik Semi-High Speed Rail Corridor',
    area_hectares: 9.60,
    classification: 'AGRICULTURAL',
    owner_name: 'Dattatray Balu Thorat',
    status: 'IN_PROGRESS',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'IN_PROGRESS',
    last_updated: '2026-09-01',
    polygon: [
      [19.0100, 73.9350],
      [19.0120, 73.9450],
      [19.0000, 73.9470],
      [18.9980, 73.9370]
    ]
  },
  {
    id: 22,
    ulpin: 'PNR-SNG-01',
    survey_number: 'Gat No. 302/1',
    village: 'Sangamner',
    district: 'Ahmednagar',
    state: 'Maharashtra',
    project_id: 2,
    project_name: 'Pune-Nashik Semi-High Speed Rail Corridor',
    area_hectares: 22.00,
    classification: 'AGRICULTURAL',
    owner_name: 'Shrikant Vitthalrao Deshmukh',
    status: 'PENDING',
    row_status: 'Corridor Intersects This Parcel',
    verification_status: 'NOT_STARTED',
    last_updated: '2026-08-10',
    polygon: [
      [19.5760, 74.2000],
      [19.5780, 74.2100],
      [19.5660, 74.2120],
      [19.5640, 74.2020]
    ]
  }
];

export const gisService = {
  // 1. Get GIS Projects List
  async getGISProjects() {
    return DEMO_PROJECT_CORRIDORS;
  },

  // 2. Get Project Corridor Geometry & Segments
  async getProjectCorridor(projectId = null) {
    const filtered = projectId 
      ? DEMO_PROJECT_CORRIDORS.filter(p => p.id === Number(projectId))
      : DEMO_PROJECT_CORRIDORS;

    const features = [];
    filtered.forEach(proj => {
      proj.segments.forEach(seg => {
        features.push({
          type: 'Feature',
          geometry: {
            type: 'LineString',
            coordinates: seg.coordinates
          },
          properties: {
            segment_id: seg.id,
            project_id: proj.id,
            project_name: proj.project_name,
            segment_name: seg.name,
            status: seg.status,
            length_km: seg.length_km,
            land_area_ha: seg.land_area_ha
          }
        });
      });
    });

    return {
      type: 'FeatureCollection',
      features
    };
  },

  // 3. Get Land Parcels with Geometry & ULPIN metadata
  async getGISParcels(params = {}) {
    const { projectId, ulpin } = params;
    let list = DEMO_PARCELS;
    if (projectId) {
      list = list.filter(p => p.project_id === Number(projectId));
    }
    if (ulpin) {
      const q = ulpin.trim().toUpperCase();
      list = list.filter(p => p.ulpin.toUpperCase().includes(q) || p.survey_number.toUpperCase().includes(q));
    }
    return list;
  },

  // 4. Search Parcel by ULPIN
  async searchByULPIN(ulpinQuery) {
    if (!ulpinQuery || !ulpinQuery.trim()) return [];
    const q = ulpinQuery.trim().toUpperCase();
    return DEMO_PARCELS.filter(p => 
      p.ulpin.toUpperCase().includes(q) || 
      p.survey_number.toUpperCase().includes(q) ||
      p.village.toUpperCase().includes(q)
    );
  },

  // 5. Cascading Geographic Filters
  async getStates() {
    return [{ id: 1, name: 'Maharashtra', code: 'MH' }];
  },

  async getDistricts(stateId = 1) {
    return [
      { id: 1, state_id: 1, name: 'Pune', code: 'PUN' },
      { id: 2, state_id: 1, name: 'Nashik', code: 'NSK' },
      { id: 3, state_id: 1, name: 'Ahmednagar', code: 'AHM' }
    ];
  },

  // 6. Field Officers Layer
  async getGISFieldOfficers() {
    return [
      {
        id: 5,
        name: 'Suresh Patil',
        officer_code: 'FO-MH-PUN-0842',
        role: 'Sub-Divisional Revenue Officer',
        assigned_project: 'Pune Ring Road Express Corridor (Phase-I)',
        status: 'ON_DUTY',
        last_known_location: [18.5362, 73.7314], // Lavale sector
        last_visit_time: '2026-09-02 11:30 AM',
        completed_tasks: 8,
        pending_tasks: 2
      },
      {
        id: 6,
        name: 'Amit Deshmukh',
        officer_code: 'FO-MH-PUN-0843',
        role: 'Land Cadastral Surveyor',
        assigned_project: 'Pune-Nashik Semi-High Speed Rail Corridor',
        status: 'ON_DUTY',
        last_known_location: [18.7610, 73.8590], // Chakan sector
        last_visit_time: '2026-09-02 10:15 AM',
        completed_tasks: 12,
        pending_tasks: 3
      }
    ];
  }
};
