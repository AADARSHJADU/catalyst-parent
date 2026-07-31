/// User model that maps to the actual API response.
/// All nullable fields are optional to handle partial responses safely.
class ApiUserModel {
  const ApiUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
    this.phone,
    this.mobile,
    this.address,
    this.city,
    this.postcode,
    this.country,
    this.isActive,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? mobile;
  final String? address;
  final String? city;
  final String? postcode;
  final String? country;
  final bool? isActive;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ApiUserModel.fromJson(Map<String, dynamic> json) {
    // role can come as a String or as a List (e.g. ["parent"])
    final rawRole = json['role'];
    final String parsedRole;
    if (rawRole is List && rawRole.isNotEmpty) {
      parsedRole = rawRole.first as String;
    } else {
      parsedRole = (rawRole as String?) ?? 'parent';
    }

    // name may come as a combined field or as firstName + lastName
    final rawName = json['name'] as String?;
    final firstName = json['firstName'] as String?;
    final lastName = json['lastName'] as String?;
    final resolvedName = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');

    return ApiUserModel(
      id: json['id'] as int,
      name: resolvedName,
      email: json['email'] as String,
      role: parsedRole,
      firstName: firstName,
      lastName: lastName,
      phone: json['phone'] as String?,
      mobile: json['mobile'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postcode: json['postcode'] as String?,
      country: json['country'] as String?,
      isActive: json['isActive'] as bool?,
      isVerified: json['isVerified'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'mobile': mobile,
        'address': address,
        'city': city,
        'postcode': postcode,
        'country': country,
        'isActive': isActive,
        'isVerified': isVerified,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  ApiUserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? firstName,
    String? lastName,
    String? phone,
    String? mobile,
    String? address,
    String? city,
    String? postcode,
    String? country,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApiUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      city: city ?? this.city,
      postcode: postcode ?? this.postcode,
      country: country ?? this.country,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Wrapper returned by auth endpoints that include a token.
class AuthResponseModel {
  const AuthResponseModel({required this.user, required this.token});

  final ApiUserModel user;
  final String token;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: ApiUserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}
