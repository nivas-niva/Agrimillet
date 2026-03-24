class Crop {
  final String id;
  final String farmerId;
  final String farmerState;
  final String farmerDistrict;
  final String milletType;
  final double quantity;
  final DateTime harvestDate;
  final String market;
  final double expectedPrice;
  final double? governmentPrice;
  final String status;
  final List<String>? images;
  final String? description;
  final DateTime createdAt;
  final FarmerInfo? farmerInfo;

  Crop({
    required this.id,
    required this.farmerId,
    required this.farmerState,
    required this.farmerDistrict,
    required this.milletType,
    required this.quantity,
    required this.harvestDate,
    required this.market,
    required this.expectedPrice,
    this.governmentPrice,
    this.status = 'available',
    this.images,
    this.description,
    required this.createdAt,
    this.farmerInfo,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    // Extract farmerId - can be either a string ID or a populated object
    String farmerId = '';
    if (json['farmerId'] is String) {
      farmerId = json['farmerId'];
    } else if (json['farmerId'] is Map) {
      farmerId = json['farmerId']['_id'] ?? '';
    }

    return Crop(
      id: json['_id'] ?? '',
      farmerId: farmerId,
      farmerState: json['farmerState'] ?? '',
      farmerDistrict: json['farmerDistrict'] ?? '',
      milletType: json['milletType'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      harvestDate: DateTime.parse(json['harvestDate'] ?? DateTime.now().toString()),
      market: json['market'] ?? '',
      expectedPrice: (json['expectedPrice'] ?? 0).toDouble(),
      governmentPrice: json['governmentPrice']?.toDouble(),
      status: json['status'] ?? 'available',
      images: List<String>.from(json['images'] ?? []),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      farmerInfo: json['farmerId'] is Map
          ? FarmerInfo.fromJson(json['farmerId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'farmerId': farmerId,
      'farmerState': farmerState,
      'farmerDistrict': farmerDistrict,
      'milletType': milletType,
      'quantity': quantity,
      'harvestDate': harvestDate.toIso8601String(),
      'market': market,
      'expectedPrice': expectedPrice,
      'governmentPrice': governmentPrice,
      'status': status,
      'images': images,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class FarmerInfo {
  final String id;
  final String name;
  final String mobileNo;
  final String state;
  final String district;

  FarmerInfo({
    required this.id,
    required this.name,
    required this.mobileNo,
    required this.state,
    required this.district,
  });

  factory FarmerInfo.fromJson(Map<String, dynamic> json) {
    return FarmerInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
    );
  }
}
