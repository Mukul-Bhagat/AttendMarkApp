enum Role {
  platformOwner,
  companyAdmin,
  staff,
  user,
}

enum RoleProfile {
  platformOwner,
  superAdmin,
  companyAdmin,
  manager,
  sessionAdmin,
  endUser,
}

class RoleResolution {
  final Role role;
  final RoleProfile profile;
  final String rawNormalized;

  const RoleResolution({
    required this.role,
    required this.profile,
    required this.rawNormalized,
  });
}

String _normalizeToken(String input) {
  return input.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
}

RoleResolution resolveRole(String input) {
  final trimmed = input.trim();
  final token = _normalizeToken(trimmed);

  if (token.isEmpty) {
    throw FormatException('Unknown role: "$input"');
  }

  if (token == _normalizeToken('PLATFORM_OWNER') || token == 'platformowner') {
    return const RoleResolution(
      role: Role.platformOwner,
      profile: RoleProfile.platformOwner,
      rawNormalized: 'PLATFORM_OWNER',
    );
  }

  if (token == _normalizeToken('COMPANY_ADMIN') || token == 'companyadmin') {
    return const RoleResolution(
      role: Role.companyAdmin,
      profile: RoleProfile.companyAdmin,
      rawNormalized: 'COMPANY_ADMIN',
    );
  }

  if (token == _normalizeToken('STAFF') || token == 'staff') {
    return const RoleResolution(
      role: Role.staff,
      profile: RoleProfile.sessionAdmin,
      rawNormalized: 'STAFF',
    );
  }

  if (token == _normalizeToken('USER') || token == 'user') {
    return const RoleResolution(
      role: Role.user,
      profile: RoleProfile.endUser,
      rawNormalized: 'USER',
    );
  }

  if (token == 'superadmin') {
    return const RoleResolution(
      role: Role.companyAdmin,
      profile: RoleProfile.superAdmin,
      rawNormalized: 'SuperAdmin',
    );
  }

  if (token == 'manager') {
    return const RoleResolution(
      role: Role.staff,
      profile: RoleProfile.manager,
      rawNormalized: 'Manager',
    );
  }

  if (token == 'sessionadmin') {
    return const RoleResolution(
      role: Role.staff,
      profile: RoleProfile.sessionAdmin,
      rawNormalized: 'SessionAdmin',
    );
  }

  if (token == 'enduser') {
    return const RoleResolution(
      role: Role.user,
      profile: RoleProfile.endUser,
      rawNormalized: 'EndUser',
    );
  }

  throw FormatException('Unknown role: "$input"');
}

Role normalizeRole(String input) {
  return resolveRole(input).role;
}

RoleResolution? tryResolveRole(String input) {
  try {
    return resolveRole(input);
  } catch (_) {
    return null;
  }
}
