/// API Endpoints for NERAM POS server communication.
abstract final class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String staffProfile = '/auth/profile';

  // Restaurant & Cafe management
  static const String outlets = '/outlets';
  static const String tables = '/tables';
  static const String categories = '/menu/categories';
  static const String menuItems = '/menu/items';
  static const String orders = '/orders';
  static const String kitchenOrders = '/kds/orders';
  static const String payments = '/payments';
}
