class Transaction {
  final String id;
  final String cropId;
  final String farmerId;
  final String buyerId;
  final double quantity;
  final double pricePerKg;
  final double totalAmount;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String paymentStatus;
  final String deliveryStatus;
  final List<GpsCoordinate> gpsCoordinates;
  final DateTime createdAt;
  final CropInfo? crop;
  final FarmerTransactionInfo? farmer;
  final BuyerInfo? buyer;

  Transaction({
    required this.id,
    required this.cropId,
    required this.farmerId,
    required this.buyerId,
    required this.quantity,
    required this.pricePerKg,
    required this.totalAmount,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.paymentStatus = 'pending',
    this.deliveryStatus = 'pending',
    this.gpsCoordinates = const [],
    required this.createdAt,
    this.crop,
    this.farmer,
    this.buyer,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Extract IDs - can be either string IDs or populated objects
    String cropId = '';
    if (json['cropId'] is String) {
      cropId = json['cropId'];
    } else if (json['cropId'] is Map) {
      cropId = json['cropId']['_id'] ?? '';
    }

    String farmerId = '';
    if (json['farmerId'] is String) {
      farmerId = json['farmerId'];
    } else if (json['farmerId'] is Map) {
      farmerId = json['farmerId']['_id'] ?? '';
    }

    String buyerId = '';
    if (json['buyerId'] is String) {
      buyerId = json['buyerId'];
    } else if (json['buyerId'] is Map) {
      buyerId = json['buyerId']['_id'] ?? '';
    }

    return Transaction(
      id: json['_id'] ?? '',
      cropId: cropId,
      farmerId: farmerId,
      buyerId: buyerId,
      quantity: (json['quantity'] ?? 0).toDouble(),
      pricePerKg: (json['pricePerKg'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      razorpayOrderId: json['razorpayOrderId'],
      razorpayPaymentId: json['razorpayPaymentId'],
      paymentStatus: json['paymentStatus'] ?? 'pending',
      deliveryStatus: json['deliveryStatus'] ?? 'pending',
      gpsCoordinates: (json['gpsCordinates'] as List?)
              ?.map((e) => GpsCoordinate.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      crop: json['cropId'] is Map ? CropInfo.fromJson(json['cropId']) : null,
      farmer: json['farmerId'] is Map
          ? FarmerTransactionInfo.fromJson(json['farmerId'])
          : null,
      buyer: json['buyerId'] is Map ? BuyerInfo.fromJson(json['buyerId']) : null,
    );
  }
}

class GpsCoordinate {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? address;

  GpsCoordinate({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.address,
  });

  factory GpsCoordinate.fromJson(Map<String, dynamic> json) {
    return GpsCoordinate(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
    };
  }
}

class CropInfo {
  final String id;
  final String milletType;
  final double quantity;
  final double expectedPrice;

  CropInfo({
    required this.id,
    required this.milletType,
    required this.quantity,
    required this.expectedPrice,
  });

  factory CropInfo.fromJson(Map<String, dynamic> json) {
    return CropInfo(
      id: json['_id'] ?? '',
      milletType: json['milletType'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      expectedPrice: (json['expectedPrice'] ?? 0).toDouble(),
    );
  }
}

class FarmerTransactionInfo {
  final String id;
  final String name;
  final String mobileNo;
  final BankingInfo? bankingDetails;

  FarmerTransactionInfo({
    required this.id,
    required this.name,
    required this.mobileNo,
    this.bankingDetails,
  });

  factory FarmerTransactionInfo.fromJson(Map<String, dynamic> json) {
    return FarmerTransactionInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      bankingDetails: json['bankingDetails'] != null
          ? BankingInfo.fromJson(json['bankingDetails'])
          : null,
    );
  }
}

class BankingInfo {
  final String? accountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? upiId;

  BankingInfo({
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.upiId,
  });

  factory BankingInfo.fromJson(Map<String, dynamic> json) {
    return BankingInfo(
      accountNumber: json['accountNumber'],
      ifscCode: json['ifscCode'],
      bankName: json['bankName'],
      upiId: json['upiId'],
    );
  }
}

class BuyerInfo {
  final String id;
  final String name;
  final String mobileNo;

  BuyerInfo({
    required this.id,
    required this.name,
    required this.mobileNo,
  });

  factory BuyerInfo.fromJson(Map<String, dynamic> json) {
    return BuyerInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
    );
  }
}
