class UserResponse {
  final int status;
  final UserDetails data;
  final String message;

  UserResponse({required this.status, required this.data, required this.message});

  factory UserResponse.fromJson(Map<dynamic, dynamic> json) {
    return UserResponse(status: json['status'] ?? 0, data: UserDetails.fromJson(json['data'] ?? {}), message: json['message'] ?? '');
  }
}

class UserDetails {
  final String? wlId;
  final String accountId;
  final String userId;
  final String? wlName;
  final String userName;
  final String firstName;
  final String lastName;
  final String role;
  final double distributedPoint;
  final double receivedPoint;
  final double depositPoint;
  final double withdrawalPoint;
  final double exposure;
  final double creditRef;
  final double pnl;
  final double commissionRate;
  final double childCount;
  final double commission;
  final double pointValue;
  final double soldPoint;
  final double netPoint;
  final double balancePoint;
  final List<User> users;
  final List<History> history;

  UserDetails({
    required this.accountId,
    required this.userId,
    this.wlId,
    this.wlName,
    required this.role,
    required this.userName,
    required this.distributedPoint,
    required this.receivedPoint,
    required this.depositPoint,
    required this.withdrawalPoint,
    required this.exposure,
    required this.creditRef,
    required this.pnl,
    required this.commissionRate,
    required this.commission,
    required this.pointValue,
    required this.soldPoint,
    required this.netPoint,
    required this.balancePoint,
    required this.users,
    required this.history,
    required this.firstName,
    required this.lastName,
    required this.childCount,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      accountId: json['accountId'] ?? "",
      userId: json['userId'] ?? "",
      wlId: json['wlId'] ?? "",
      wlName: json['wlName'] ?? "",
      userName: json['userName'] ?? "",
      firstName: json['firstName'] ?? "",
      lastName: json['lastName'] ?? "",
      role: json['role'] ?? "",
      distributedPoint: json['distributedPoint'] ?? 0.0,
      childCount: json['childCount'] ?? 0.0,
      receivedPoint: json['receivedPoint'] ?? 0.0,
      depositPoint: json['depositPoint'] ?? 0.0,
      withdrawalPoint: json['withdrawalPoint'] ?? 0.0,
      exposure: json['exposure'] ?? 0.0,
      creditRef: json['creditRef'] ?? 0.0,
      pnl: json['pnl'] ?? 0.0,
      commissionRate: json['commissionRate'] ?? 0.0,
      commission: json['commission'] ?? 0.0,
      pointValue: json['pointValue'] ?? 0.0,
      soldPoint: json['soldPoint'] ?? 0.0,
      netPoint: json['netPoint'] ?? 0.0,
      balancePoint: json['balancePoint'] ?? 0.0,
      users: (json['users'] as List).map((e) => User.fromJson(e)).toList(),
      history: (json['history'] as List<dynamic>? ?? []).map((e) => History.fromJson(e)).toList(),
    );
  }
}

class User {
  final String firstName;
  final String lastName;
  final String timezone;
  final bool enabled;
  final String role;
  final int childCount;
  final String accountId;
  final String id;
  final String userName;
  final String normalizedUserName;
  final String? email;
  final bool emailConfirmed;
  final String passwordHash;
  final String securityStamp;
  final String concurrencyStamp;
  final String? phoneNumber;
  final bool phoneNumberConfirmed;
  final bool twoFactorEnabled;
  final bool lockoutEnabled;
  final int accessFailedCount;

  User({
    required this.firstName,
    required this.lastName,
    required this.timezone,
    required this.enabled,
    required this.role,
    required this.childCount,
    required this.accountId,
    required this.id,
    required this.userName,
    required this.normalizedUserName,
    this.email,
    required this.emailConfirmed,
    required this.passwordHash,
    required this.securityStamp,
    required this.concurrencyStamp,
    this.phoneNumber,
    required this.phoneNumberConfirmed,
    required this.twoFactorEnabled,
    required this.lockoutEnabled,
    required this.accessFailedCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'],
      lastName: json['lastName'],
      timezone: json['timezone'] ?? '',
      enabled: json['enabled'],
      role: json['role'],
      childCount: json['childCount'],
      accountId: json['accountId'],
      id: json['Id'],
      userName: json['UserName'],
      normalizedUserName: json['NormalizedUserName'],
      email: json['Email'],
      emailConfirmed: json['EmailConfirmed'],
      passwordHash: json['PasswordHash'],
      securityStamp: json['SecurityStamp'],
      concurrencyStamp: json['ConcurrencyStamp'],
      phoneNumber: json['PhoneNumber'],
      phoneNumberConfirmed: json['PhoneNumberConfirmed'],
      twoFactorEnabled: json['TwoFactorEnabled'],
      lockoutEnabled: json['LockoutEnabled'],
      accessFailedCount: json['AccessFailedCount'],
    );
  }
}

class History {
  final int id;
  final String transType;
  final double amount;
  final String date;
  final String comment;
  final String userId;

  History({required this.id, required this.transType, required this.amount, required this.date, required this.comment, required this.userId});

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'] ?? 0,
      transType: json['transType'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      comment: json['comment'] ?? '',
      userId: json['UserId'] ?? '',
    );
  }
}

enum UserRole { alphaAdmin, fancyAdmin, admin, ghostAdmin, superSuperAdmin, superAdmin, master, client }
