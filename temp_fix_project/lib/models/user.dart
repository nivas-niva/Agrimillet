class User {
  final String id;
  final String name;
  final String email;
  final String mobileNo;
  final String userType; // 'farmer' or 'buyer'
  final String state;
  final String district;
  final BankingDetails? bankingDetails;
  final bool profileComplete;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNo,
    required this.userType,
    required this.state,
    required this.district,
    this.bankingDetails,
    this.profileComplete = false,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      userType: json['userType'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      bankingDetails: json['bankingDetails'] != null
          ? BankingDetails.fromJson(json['bankingDetails'])
          : null,
      profileComplete: json['profileComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'mobileNo': mobileNo,
      'userType': userType,
      'state': state,
      'district': district,
      'bankingDetails': bankingDetails?.toJson(),
      'profileComplete': profileComplete,
    };
  }
}

class BankingDetails {
  final String? accountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? accountHolderName;
  final String? upiId;

  BankingDetails({
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.accountHolderName,
    this.upiId,
  });

  factory BankingDetails.fromJson(Map<String, dynamic> json) {
    return BankingDetails(
      accountNumber: json['accountNumber'],
      ifscCode: json['ifscCode'],
      bankName: json['bankName'],
      accountHolderName: json['accountHolderName'],
      upiId: json['upiId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'accountHolderName': accountHolderName,
      'upiId': upiId,
    };
  }
}
