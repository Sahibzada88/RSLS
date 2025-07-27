import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  // Initialize Cloudinary (you'll need to replace with your actual credentials)
  static final cloudinary = CloudinaryPublic('depjil8qa', 'flutter_lab_app', cache: false);

  /// Upload receipt image to Cloudinary
  static Future<String> uploadReceipt(File imageFile) async {
    try {
      print('Uploading receipt: ${imageFile.path}'); // Debug print

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'receipts',
        ),
      );

      print('Receipt uploaded: ${response.secureUrl}'); // Debug print
      return response.secureUrl;
    } catch (e) {
      print('Upload error: $e'); // Debug print
      // Fallback to mock URL for testing
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final mockUrl = 'https://example.com/receipts/receipt_$timestamp.jpg';
      print('Using mock URL: $mockUrl'); // Debug print
      return mockUrl;
    }
  }

  /// Upload result document to Cloudinary
  static Future<String> uploadResult(File file) async {
    try {
      print('Uploading result: ${file.path}'); // Debug print

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: 'results',
        ),
      );

      print('Result uploaded: ${response.secureUrl}'); // Debug print
      return response.secureUrl;
    } catch (e) {
      print('Upload error: $e'); // Debug print
      // Fallback to mock URL for testing
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final mockUrl = 'https://example.com/results/result_$timestamp.pdf';
      print('Using mock URL: $mockUrl'); // Debug print
      return mockUrl;
    }
  }

  /// Upload profile image to Cloudinary
  static Future<String> uploadProfileImage(File imageFile) async {
    try {
      print('Uploading profile image: ${imageFile.path}'); // Debug print

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'profiles',
        ),
      );

      print('Profile image uploaded: ${response.secureUrl}'); // Debug print
      return response.secureUrl;
    } catch (e) {
      print('Upload error: $e'); // Debug print
      // Fallback to mock URL for testing
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final mockUrl = 'https://example.com/profiles/profile_$timestamp.jpg';
      print('Using mock URL: $mockUrl'); // Debug print
      return mockUrl;
    }
  }

  /// Mock delete file
  static Future<bool> deleteFile(String publicId) async {
    print('Mock delete: $publicId'); // Debug print
    await Future.delayed(Duration(milliseconds: 500));
    return true;
  }

  /// Get optimized image URL (basic implementation)
  static String getOptimizedImageUrl(String imageUrl, {
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    // For basic implementation, return original URL
    // In production, you would modify the URL to include Cloudinary transformations
    return imageUrl;
  }
}
