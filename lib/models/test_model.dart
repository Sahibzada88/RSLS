class TestModel {
  final String id;
  final String testName;
  final String? description;
  final double price;
  final String? labId;
  final String? labName;
  final String? location;
  final String? contactInfo;

  TestModel({
    required this.id,
    required this.testName,
    this.description,
    required this.price,
    this.labId,
    this.labName,
    this.location,
    this.contactInfo,
  });

  factory TestModel.fromMap(Map<String, dynamic> data, String id) {
    return TestModel(
      id: id,
      testName: data['testName'] ?? '',
      description: data['description'],
      price: (data['price'] ?? 0).toDouble(),
      labId: data['labId'],
      labName: data['labName'],
      location: data['location'],
      contactInfo: data['contactInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'testName': testName,
      'description': description,
      'price': price,
      'labId': labId,
      'labName': labName,
      'location': location,
      'contactInfo': contactInfo,
    };
  }
}