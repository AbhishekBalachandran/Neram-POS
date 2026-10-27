/// API Endpoints for NERAM POS server communication.
abstract final class ApiEndpoints {
  // Auth & Profile endpoints
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';
  static const String staffProfile = '/auth/profile';
  static const String staffStatus = '/staff/profile/status';

  // Restaurant & Cafe management
  static const String outlets = '/outlets';
  static const String tables = '/tables';
  static const String tableTransfer = '/tables/transfer';
  static const String categories = '/menu/categories';
  static const String menuItems = '/menu/items';
  static const String orders = '/orders';
  static const String ordersSync = '/orders/sync';
  static const String activeOrders = '/orders/active';
  static String orderBill(String id) => '/orders/$id/bill';
  static String orderSettle(String id) => '/orders/$id/settle';
  static String orderCancel(String id) => '/orders/$id';
  static const String kitchenOrders = '/kds/orders';
  static const String printers = '/printers';
  static const String payments = '/payments';

  // Stocks & Inventory endpoints
  static const String inventoryItems = '/inventory/items';
  static String inventoryRestock(String id) => '/inventory/items/$id/restock';
  static String inventoryIssue(String id) => '/inventory/items/$id/issue';
  static String inventoryAlert(String id) => '/inventory/items/$id/alert-manager';
  static const String inventoryAudit = '/inventory/audit';

  // Attendance & Leaves endpoints
  static const String attendanceMonthlySummary = '/attendance/monthly-summary';
  static const String attendanceCheckIn = '/attendance/check-in';
  static const String attendanceCheckOut = '/attendance/check-out';
  static const String leaves = '/leaves';
  static String leaveCancel(String id) => '/leaves/$id';
}
