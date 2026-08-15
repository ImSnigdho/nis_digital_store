class Profile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final String country;
  final String currency;
  final String? discordUsername;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Profile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.country = 'BD',
    this.currency = 'BDT',
    this.discordUsername,
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
  });

  bool get isBangladesh => country == 'BD';

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      country: json['country'] as String? ?? 'BD',
      currency: json['currency'] as String? ?? 'BDT',
      discordUsername: json['discord_username'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'country': country,
      'currency': currency,
      'discord_username': discordUsername,
      'role': role,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Profile copyWith({
    String? fullName,
    String? avatarUrl,
    String? phone,
    String? country,
    String? currency,
    String? discordUsername,
    String? role,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      discordUsername: discordUsername ?? this.discordUsername,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
