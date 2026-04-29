import 'package:flutter/material.dart';

import '../models/organization.dart';

/// Mock catalogue of organizations users can apply to. Mirrors how cars and
/// drivers are seeded — feature-local list, easily swappable for an API later.
const kMockOrganizations = <Organization>[
  Organization(
    id: 'mwasalat',
    name: 'Mwasalat',
    logoUrl: 'https://placehold.co/120x120/0C2485/FFFFFF/png?text=MW',
    industry: 'Transport',
    domain: '@mwasalat.om',
    accentColor: Color(0xFF0C2485),
  ),
  Organization(
    id: 'oq',
    name: 'OQ Group',
    logoUrl: 'https://placehold.co/120x120/E53935/FFFFFF/png?text=OQ',
    industry: 'Energy',
    domain: '@oq.com',
    accentColor: Color(0xFFE53935),
  ),
  Organization(
    id: 'omantel',
    name: 'Omantel',
    logoUrl: 'https://placehold.co/120x120/7C4DFF/FFFFFF/png?text=OT',
    industry: 'Telecom',
    domain: '@omantel.om',
    accentColor: Color(0xFF7C4DFF),
  ),
  Organization(
    id: 'bank-muscat',
    name: 'Bank Muscat',
    logoUrl: 'https://placehold.co/120x120/3D5AFE/FFFFFF/png?text=BM',
    industry: 'Banking',
    domain: '@bankmuscat.com',
    accentColor: Color(0xFF3D5AFE),
  ),
  Organization(
    id: 'pdo',
    name: 'Petroleum Development Oman',
    logoUrl: 'https://placehold.co/120x120/4CAF50/FFFFFF/png?text=PDO',
    industry: 'Energy',
    domain: '@pdo.co.om',
    accentColor: Color(0xFF4CAF50),
  ),
  Organization(
    id: 'asyad',
    name: 'Asyad Group',
    logoUrl: 'https://placehold.co/120x120/00BCD4/FFFFFF/png?text=AS',
    industry: 'Logistics',
    domain: '@asyadgroup.com',
    accentColor: Color(0xFF00BCD4),
  ),
  Organization(
    id: 'oman-air',
    name: 'Oman Air',
    logoUrl: 'https://placehold.co/120x120/FFA726/FFFFFF/png?text=OA',
    industry: 'Aviation',
    domain: '@omanair.com',
    accentColor: Color(0xFFFFA726),
  ),
];
