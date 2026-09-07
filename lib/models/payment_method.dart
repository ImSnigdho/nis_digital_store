class PaymentMethod {
  final String id;
  final String name;
  final String accountNumber;
  final String? iconUrl;
  final String? instructions;
  final bool isActive;
  final int sortOrder;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.accountNumber,
    this.iconUrl,
    this.instructions,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      accountNumber: json['account_number'],
      iconUrl: json['icon_url'],
      instructions: json['instructions'],
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'account_number': accountNumber,
      'icon_url': iconUrl,
      'instructions': instructions,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}
