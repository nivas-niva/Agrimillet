class GovernmentPrice {
  final String id;
  final String milletType;
  final String state;
  final double pricePerKg;
  final DateTime lastUpdated;

  GovernmentPrice({
    required this.id,
    required this.milletType,
    required this.state,
    required this.pricePerKg,
    required this.lastUpdated,
  });

  factory GovernmentPrice.fromJson(Map<String, dynamic> json) {
    return GovernmentPrice(
      id: json['_id'] ?? '',
      milletType: json['milletType'] ?? '',
      state: json['state'] ?? '',
      pricePerKg: (json['pricePerKg'] ?? 0).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toString()),
    );
  }
}
