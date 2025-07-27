import 'package:cloud_firestore/cloud_firestore.dart';

class LabModel {
  final String id;
  final String labName;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String contactNumber;
  final String? email;
  final String? website;
  final List<String> services;
  final Map<String, dynamic> operatingHours;
  final bool isActive;
  final double? rating;
  final int? reviewCount;
  final GeoPoint? location;
  final DateTime createdAt;

  LabModel({
    required this.id,
    required this.labName,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.contactNumber,
    this.email,
    this.website,
    required this.services,
    required this.operatingHours,
    required this.isActive,
    this.rating,
    this.reviewCount,
    this.location,
    required this.createdAt,
  });

  factory LabModel.fromMap(Map<String, dynamic> data, String id) {
    return LabModel(
      id: id,
      labName: data['labName'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      pincode: data['pincode'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      email: data['email'],
      website: data['website'],
      services: List<String>.from(data['services'] ?? []),
      operatingHours: data['operatingHours'] ?? {},
      isActive: data['isActive'] ?? true,
      rating: data['rating']?.toDouble(),
      reviewCount: data['reviewCount'],
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'labName': labName,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'contactNumber': contactNumber,
      'email': email,
      'website': website,
      'services': services,
      'operatingHours': operatingHours,
      'isActive': isActive,
      'rating': rating,
      'reviewCount': reviewCount,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}