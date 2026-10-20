/// Staff role in restaurant or cafe operations.
enum StaffRole {
  manager,
  cashier,
  waiter,
  kitchenStaff,
  admin;

  static StaffRole fromString(String role) {
    return switch (role.toLowerCase()) {
      'manager' => StaffRole.manager,
      'cashier' => StaffRole.cashier,
      'waiter' => StaffRole.waiter,
      'kitchen' || 'kitchen_staff' || 'chef' => StaffRole.kitchenStaff,
      'admin' => StaffRole.admin,
      _ => StaffRole.cashier,
    };
  }
}

/// Represents an authenticated staff user in the POS system.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.outletId,
    this.outletName,
  });

  final String id;
  final String name;
  final String email;
  final StaffRole role;
  final String? phone;
  final String? outletId;
  final String? outletName;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: StaffRole.fromString(json['role'] as String? ?? 'cashier'),
      phone: json['phone'] as String?,
      outletId: json['outlet_id'] as String?,
      outletName: json['outlet_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'outlet_id': outletId,
      'outlet_name': outletName,
    };
  }
}
