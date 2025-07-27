import 'package:cloud_firestore/cloud_firestore.dart';

class ResultModel {
  final String id;
  final String bookingId;
  final String userId;
  final String testName;
  final String patientName;
  final String? resultDocUrl;
  final DateTime resultDate;
  final String paymentStatus; // 'paid', 'pending', 'failed'
  final String? uploadedByAdminId;

  ResultModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.testName,
    required this.patientName,
    this.resultDocUrl,
    required this.resultDate,
    required this.paymentStatus,
    this.uploadedByAdminId,
  });

  factory ResultModel.fromMap(Map<String, dynamic> data, String id) {
    return ResultModel(
      id: id,
      bookingId: data['bookingId'] ?? '',
      userId: data['userId'] ?? '',
      testName: data['testName'] ?? '',
      patientName: data['patientName'] ?? '',
      resultDocUrl: data['resultDocUrl'],
      resultDate: (data['resultDate'] as Timestamp).toDate(),
      paymentStatus: data['paymentStatus'] ?? 'pending',
      uploadedByAdminId: data['uploadedByAdminId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'testName': testName,
      'patientName': patientName,
      'resultDocUrl': resultDocUrl,
      'resultDate': Timestamp.fromDate(resultDate),
      'paymentStatus': paymentStatus,
      'uploadedByAdminId': uploadedByAdminId,
    };
  }
}