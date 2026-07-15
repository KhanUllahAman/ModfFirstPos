class CustomerModel {
  final int id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? role;
  final String? image;
  final bool isActive;
  final bool isLocked;
  final String? lastLoginDate;
  final String? createdAt;
  final String? updatedAt;
  final bool emailVerified;

  CustomerModel({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.role,
    this.image,
    this.isActive = true,
    this.isLocked = false,
    this.lastLoginDate,
    this.createdAt,
    this.updatedAt,
    this.emailVerified = false,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      image: json['image'] as String?,
      isActive: json['is_active'] == true,
      isLocked: json['is_locked'] == true,
      lastLoginDate: json['last_login_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      emailVerified: json['email_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'image': image,
      'is_active': isActive,
      'is_locked': isLocked,
      'last_login_date': lastLoginDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'email_verified': emailVerified,
    };
  }
}

class CustomerPaginationModel {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;
  final bool? hasNext;
  final bool? hasPrev;

  CustomerPaginationModel({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.hasNext,
    this.hasPrev,
  });

  factory CustomerPaginationModel.fromJson(Map<String, dynamic> json) {
    return CustomerPaginationModel(
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      total: json['total'] as int?,
      totalPages: json['totalPages'] as int?,
      hasNext: json['hasNext'] as bool?,
      hasPrev: json['hasPrev'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }
}

class CustomerListResponse {
  final bool isSuccess;
  final int status;
  final String message;
  final List<CustomerModel> payload;
  final CustomerPaginationModel pagination;

  CustomerListResponse({
    required this.isSuccess,
    required this.status,
    required this.message,
    required this.payload,
    required this.pagination,
  });

  factory CustomerListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['payload'] as List<dynamic>? ?? [];
    final items = rawList
        .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return CustomerListResponse(
      isSuccess: json['success'] == true,
      status: json['status'] is int ? json['status'] as int : 200,
      message: json['message'] as String? ?? '',
      payload: items,
      pagination: CustomerPaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
