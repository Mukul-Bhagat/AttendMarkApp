import '../core/auth/roles.dart';

/// User Model
/// Represents a user in the system
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? organizationId;
  final String? organizationName;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.organizationId,
    this.organizationName,
  });

  static String _toStringOrEmpty(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return text;
  }

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    final firstName = _toNullableString(
      profile is Map<String, dynamic> ? profile['firstName'] : null,
    );
    final lastName = _toNullableString(
      profile is Map<String, dynamic> ? profile['lastName'] : null,
    );
    final composedName = [
      firstName,
      lastName,
    ].where((part) => part != null && part.isNotEmpty).join(' ').trim();
    final directName = _toNullableString(json['name']);
    final email = _toStringOrEmpty(json['email']);

    final orgObj = json['organization'];
    final organizationName =
        _toNullableString(json['organizationName']) ??
        _toNullableString(json['orgName']) ??
        _toNullableString(
          orgObj is Map<String, dynamic> ? orgObj['name'] : null,
        ) ??
        _toNullableString(
          orgObj is Map<String, dynamic> ? orgObj['organizationName'] : null,
        );

    return UserModel(
      id: _toStringOrEmpty(json['_id'] ?? json['id']),
      name: directName ?? (composedName.isNotEmpty ? composedName : email),
      email: email,
      role: _toStringOrEmpty(json['role']),
      organizationId:
          _toNullableString(json['organizationId']) ??
          _toNullableString(
            orgObj is Map<String, dynamic> ? orgObj['_id'] : null,
          ) ??
          _toNullableString(json['collectionPrefix']),
      organizationName: organizationName,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'organizationId': organizationId,
      'organizationName': organizationName,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? organizationId,
    String? organizationName,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
    );
  }

  RoleResolution? get _resolvedRole => tryResolveRole(role);

  Role get canonicalRole => _resolvedRole?.role ?? Role.user;

  RoleProfile get roleProfile => _resolvedRole?.profile ?? RoleProfile.endUser;

  /// Check if user is Platform Owner (should be filtered out)
  bool get isPlatformOwner => canonicalRole == Role.platformOwner;

  /// Check if user is admin
  bool get isAdmin =>
      roleProfile == RoleProfile.superAdmin ||
      roleProfile == RoleProfile.companyAdmin;

  /// Check if user is manager
  bool get isManager =>
      roleProfile == RoleProfile.manager ||
      roleProfile == RoleProfile.sessionAdmin;

  /// Check if user is end user
  bool get isEndUser => roleProfile == RoleProfile.endUser;
}

/// Organization Model (for multi-organization login)
class OrganizationModel {
  final String name;
  final String prefix;
  final String? id;

  OrganizationModel({required this.name, required this.prefix, this.id});

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      name: json['name'] ?? json['orgName'] ?? json['organizationName'] ?? '',
      prefix: json['prefix'] ?? '',
      id: json['_id'] ?? json['id'] ?? json['organizationId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'prefix': prefix, '_id': id, 'id': id};
  }
}
