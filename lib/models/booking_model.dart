import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String testId;
  final String testName;
  final String patientName;
  final String? contactNo;
  final String? city;
  final DateTime bookingDate;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? invoiceUrl;
  final double price;

  BookingModel({
    required this.id,
    required this.userId,
    required this.testId,
    required this.testName,
    required this.patientName,
    this.contactNo,
    this.city,
    required this.bookingDate,
    required this.status,
    this.invoiceUrl,
    required this.price,
  });

  factory BookingModel.fromMap(Map<String, dynamic> data, String id) {
    return BookingModel(
      id: id,
      userId: data['userId'] ?? '',
      testId: data['testId'] ?? '',
      testName: data['testName'] ?? '',
      patientName: data['patientName'] ?? '',
      contactNo: data['contactNo'],
      city: data['city'],
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      invoiceUrl: data['invoiceUrl'],
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'testId': testId,
      'testName': testName,
      'patientName': patientName,
      'contactNo': contactNo,
      'city': city,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'status': status,
      'invoiceUrl': invoiceUrl,
      'price': price,
    };
  }
}