import 'package:flutter/foundation.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/data/models/dish_model.dart';
import 'package:neram_pos/data/models/order_model.dart';
import 'package:neram_pos/data/models/table_model.dart';

/// Dining mode selection: Indoor Tables, Outdoor (by customer name), Takeaway (by customer name).
enum DiningMode {
  dineIn,
  outdoor,
  takeaway;

  String get displayName => switch (this) {
    DiningMode.dineIn => 'Dine-In',
    DiningMode.outdoor => 'Outdoor',
    DiningMode.takeaway => 'Takeaway',
  };

  String get subtitle => switch (this) {
    DiningMode.dineIn => 'Indoor Table',
    DiningMode.outdoor => 'By Customer Name',
    DiningMode.takeaway => 'By Customer Name',
  };
}

/// State management for Table & Menu Workspace.
class TableViewModel extends ChangeNotifier {
  TableViewModel() {
    _initializeData();
  }

  // State
  late List<TableModel> _tables;
  late List<DishModel> _dishes;
  late List<OrderModel> _activeOrders;

  String _selectedTableId = 'T-01';
  String _selectedCategory = 'All (48)';
  String _searchQuery = '';
  final Map<String, int> _currentTableCart = {};
  DiningMode _diningMode = DiningMode.dineIn;
  String _customerName = '';
  final Map<String, String> _itemNotes = {
    'dish_1': 'Extra crunchy, less oil',
    'dish_2': 'Medium spice',
    'dish_3': 'Served with hot croutons',
  };

  // Getters
  List<TableModel> get tables => _tables;
  List<DishModel> get dishes => _dishes;
  List<OrderModel> get activeOrders => _activeOrders;
  String get selectedTableId => _selectedTableId;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  Map<String, int> get currentTableCart => _currentTableCart;
  DiningMode get diningMode => _diningMode;
  String get customerName => _customerName;
  Map<String, String> get itemNotes => _itemNotes;

  TableModel get selectedTable => _tables.firstWhere(
    (t) => t.id == _selectedTableId,
    orElse: () => _tables.first,
  );

  String get orderDestinationTitle => switch (_diningMode) {
    DiningMode.dineIn => selectedTable.name,
    DiningMode.outdoor => 'Outdoor Order',
    DiningMode.takeaway => 'Takeaway Order',
  };

  String get orderIdentifierSubtitle => switch (_diningMode) {
    DiningMode.dineIn => _customerName.isNotEmpty
        ? '${selectedTable.subtitle} • $_customerName'
        : selectedTable.subtitle,
    DiningMode.outdoor => _customerName.isNotEmpty
        ? 'Customer: $_customerName'
        : 'Outdoor Order',
    DiningMode.takeaway => _customerName.isNotEmpty
        ? 'Customer: $_customerName'
        : 'Takeaway Order',
  };

  int get totalCartItemCount =>
      _currentTableCart.values.fold(0, (sum, count) => sum + count);

  double get cartSubtotal {
    double sum = 0.0;
    for (final entry in _currentTableCart.entries) {
      final dish = _dishes.firstWhere(
        (d) => d.id == entry.key,
        orElse: () => _dishes.first,
      );
      sum += dish.price * entry.value;
    }
    return sum;
  }

  double get cartTax => cartSubtotal * 0.05; // 5% GST from Stitch
  double get cartServiceCharge => 0.0; // FREE
  double get cartTotalPayable => cartSubtotal + cartTax;

  double get currentTableCartTotal => cartTotalPayable;

  static const List<String> categories = [
    'All (48)',
    'Starters',
    'Egg Preparations',
    'Soups',
    'Main Course',
    'Breads & Rice',
    'Beverages',
    'Desserts',
  ];

  List<DishModel> get filteredDishes {
    return _dishes.where((dish) {
      final matchesCategory =
          _selectedCategory == 'All (48)' ||
          dish.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty ||
          dish.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dish.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void selectTable(String tableId) {
    if (_selectedTableId != tableId) {
      HapticService.selection();
      _selectedTableId = tableId;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory != category) {
      HapticService.selection();
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addDish(DishModel dish) {
    HapticService.selection();
    _currentTableCart[dish.id] = (_currentTableCart[dish.id] ?? 0) + 1;
    notifyListeners();
  }

  void removeDish(DishModel dish) {
    if (_currentTableCart.containsKey(dish.id)) {
      HapticService.selection();
      final current = _currentTableCart[dish.id]!;
      if (current <= 1) {
        _currentTableCart.remove(dish.id);
      } else {
        _currentTableCart[dish.id] = current - 1;
      }
      notifyListeners();
    }
  }

  void setDiningMode(DiningMode mode) {
    if (_diningMode != mode) {
      HapticService.selection();
      _diningMode = mode;
      notifyListeners();
    }
  }

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  void setItemNote(String dishId, String note) {
    _itemNotes[dishId] = note;
    notifyListeners();
  }

  void sendOrderToKitchen() {
    HapticService.success();
    // Update active orders and mark table as preparing
    final newOrder = OrderModel(
      id: '#ORD-${DateTime.now().millisecondsSinceEpoch % 10000}',
      tableId: _diningMode == DiningMode.dineIn ? _selectedTableId : '',
      tableName: switch (_diningMode) {
        DiningMode.dineIn => selectedTable.name,
        DiningMode.outdoor => 'Outdoor',
        DiningMode.takeaway => 'Takeaway',
      },
      customerName: _customerName,
      items: _currentTableCart.entries.map((e) {
        final dish = _dishes.firstWhere(
          (d) => d.id == e.key,
          orElse: () => _dishes.first,
        );
        return '${e.value}x ${dish.name}';
      }).toList(),
      total: cartTotalPayable,
      status: TableStatus.preparing,
      timeElapsed: 'Just now',
      zone: switch (_diningMode) {
        DiningMode.dineIn => TableZone.indoor,
        DiningMode.outdoor => TableZone.outdoor,
        DiningMode.takeaway => TableZone.takeaway,
      },
    );
    _activeOrders.insert(0, newOrder);
    _currentTableCart.clear();
    notifyListeners();
  }

  void clearCart() {
    HapticService.mediumImpact();
    _currentTableCart.clear();
    notifyListeners();
  }

  void _initializeData() {
    // 12 Indoor Dining Tables (Outdoor & Takeaway orders are taken by customer name)
    _tables = [
      // Indoor
      const TableModel(
        id: 'T-01',
        name: 'Table T-01',
        zone: TableZone.indoor,
        seats: 4,
        status: TableStatus.preparing,
        total: 48.50,
        timeElapsed: '12m ago',
        itemCount: 4,
      ),
      const TableModel(
        id: 'T-02',
        name: 'Table T-02',
        zone: TableZone.indoor,
        seats: 2,
        status: TableStatus.occupied,
        total: 26.00,
        customerName: 'Elena R.',
        timeElapsed: '24m ago',
        itemCount: 2,
      ),
      const TableModel(
        id: 'T-03',
        name: 'Table T-03',
        zone: TableZone.indoor,
        seats: 6,
        status: TableStatus.vacant,
        total: 0.00,
      ),
      const TableModel(
        id: 'T-04',
        name: 'Table T-04',
        zone: TableZone.indoor,
        seats: 4,
        status: TableStatus.billed,
        total: 74.20,
        customerName: 'Marco D.',
        timeElapsed: '45m ago',
        itemCount: 5,
      ),
      const TableModel(
        id: 'T-05',
        name: 'Table T-05',
        zone: TableZone.indoor,
        seats: 2,
        status: TableStatus.vacant,
        total: 0.00,
      ),
      const TableModel(
        id: 'T-06',
        name: 'Table T-06',
        zone: TableZone.indoor,
        seats: 4,
        status: TableStatus.occupied,
        total: 38.00,
        customerName: 'Kavita N.',
        timeElapsed: '18m ago',
        itemCount: 3,
      ),
      const TableModel(
        id: 'T-07',
        name: 'Table T-07',
        zone: TableZone.indoor,
        seats: 8,
        status: TableStatus.vacant,
        total: 0.00,
      ),
      const TableModel(
        id: 'T-08',
        name: 'Table T-08',
        zone: TableZone.indoor,
        seats: 4,
        status: TableStatus.occupied,
        total: 52.00,
        customerName: 'Priya S.',
        timeElapsed: '32m ago',
        itemCount: 4,
      ),
      const TableModel(
        id: 'T-09',
        name: 'Table T-09',
        zone: TableZone.indoor,
        seats: 2,
        status: TableStatus.vacant,
        total: 0.00,
      ),
      const TableModel(
        id: 'T-10',
        name: 'Table T-10',
        zone: TableZone.indoor,
        seats: 6,
        status: TableStatus.preparing,
        total: 62.50,
        customerName: 'Robert B.',
        timeElapsed: '15m ago',
        itemCount: 5,
      ),
      const TableModel(
        id: 'T-11',
        name: 'Table T-11',
        zone: TableZone.indoor,
        seats: 4,
        status: TableStatus.vacant,
        total: 0.00,
      ),
      const TableModel(
        id: 'T-12',
        name: 'Table T-12',
        zone: TableZone.indoor,
        seats: 4,
        status: TableStatus.vacant,
        total: 0.00,
      ),
    ];

    // Popular and Recommended Dishes from Stitch
    _dishes = [
      const DishModel(
        id: 'dish_1',
        name: 'Crispy Corn Pepper Fry',
        category: 'Starters',
        subtitle: 'Starters • Chef Special',
        price: 8.50,
        foodType: FoodType.veg,
      ),
      const DishModel(
        id: 'dish_2',
        name: 'Egg Roast Masala',
        category: 'Egg Preparations',
        subtitle: 'Egg Preparations • Medium Spice',
        price: 10.00,
        foodType: FoodType.egg,
      ),
      const DishModel(
        id: 'dish_3',
        name: 'Smoked Tomato Basil Soup',
        category: 'Soups',
        subtitle: 'Soups • Served with Croutons',
        price: 7.20,
        foodType: FoodType.veg,
      ),
      const DishModel(
        id: 'dish_4',
        name: 'Butter Chicken Handi',
        category: 'Main Course',
        subtitle: 'Main Course • Rich Makhani Gravy',
        price: 14.50,
        foodType: FoodType.nonVeg,
      ),
      const DishModel(
        id: 'dish_5',
        name: 'Garlic Butter Naan',
        category: 'Breads & Rice',
        subtitle: 'Breads & Rice • Clay Oven Tandoor',
        price: 3.80,
        foodType: FoodType.veg,
      ),
      const DishModel(
        id: 'dish_6',
        name: 'Paneer Tikka Angara',
        category: 'Starters',
        subtitle: 'Starters • Smoked Charcoal Grill',
        price: 9.50,
        foodType: FoodType.veg,
      ),
      const DishModel(
        id: 'dish_7',
        name: 'Chicken Dum Biryani',
        category: 'Main Course',
        subtitle: 'Main Course • Hyderabadi Aromatic Rice',
        price: 13.00,
        foodType: FoodType.nonVeg,
      ),
      const DishModel(
        id: 'dish_8',
        name: 'Cold Brew Coffee',
        category: 'Beverages',
        subtitle: 'Beverages • Single Origin Steeped',
        price: 4.50,
        foodType: FoodType.veg,
      ),
      const DishModel(
        id: 'dish_9',
        name: 'Mango Kulfi Falooda',
        category: 'Desserts',
        subtitle: 'Desserts • Royal Saffron & Rose',
        price: 6.00,
        foodType: FoodType.veg,
      ),
    ];

    // 6 Live Active Orders from Stitch
    _activeOrders = [
      const OrderModel(
        id: '#ORD-2849',
        tableId: 'T-01',
        tableName: 'Table T-01',
        customerName: 'Dine-In',
        items: [
          '2x Crispy Corn Pepper Fry',
          '1x Butter Chicken Handi',
          '2x Garlic Butter Naan',
        ],
        total: 48.50,
        status: TableStatus.preparing,
        timeElapsed: '12m ago',
        zone: TableZone.indoor,
      ),
      const OrderModel(
        id: '#ORD-2845',
        tableId: 'T-02',
        tableName: 'Table T-02',
        customerName: 'Elena R.',
        items: ['1x Smoked Tomato Basil Soup', '1x Egg Roast Masala'],
        total: 26.00,
        status: TableStatus.occupied,
        timeElapsed: '24m ago',
        zone: TableZone.indoor,
      ),
      const OrderModel(
        id: '#ORD-2838',
        tableId: 'T-04',
        tableName: 'Table T-04',
        customerName: 'Marco D.',
        items: [
          '2x Chicken Dum Biryani',
          '1x Paneer Tikka Angara',
          '2x Cold Brew Coffee',
        ],
        total: 74.20,
        status: TableStatus.billed,
        timeElapsed: '45m ago',
        zone: TableZone.indoor,
      ),
      const OrderModel(
        id: '#ORD-2851',
        tableId: '',
        tableName: 'Outdoor',
        customerName: 'Sarah K.',
        items: ['1x Crispy Corn Pepper Fry', '1x Mango Kulfi Falooda'],
        total: 35.50,
        status: TableStatus.preparing,
        timeElapsed: '8m ago',
        zone: TableZone.outdoor,
      ),
      const OrderModel(
        id: '#ORD-2854',
        tableId: '',
        tableName: 'Takeaway',
        customerName: 'David L.',
        items: ['1x Butter Chicken Handi', '2x Garlic Butter Naan'],
        total: 19.00,
        status: TableStatus.preparing,
        timeElapsed: '5m ago',
        zone: TableZone.takeaway,
      ),
      const OrderModel(
        id: '#ORD-2840',
        tableId: 'T-08',
        tableName: 'Table T-08',
        customerName: 'Priya S.',
        items: ['1x Chicken Dum Biryani', '2x Garlic Butter Naan'],
        total: 52.00,
        status: TableStatus.occupied,
        timeElapsed: '32m ago',
        zone: TableZone.indoor,
      ),
    ];

    // Pre-staged order items matching Stitch "Animated Order Sheet" spec (3 items • ₹26.98)
    _currentTableCart['dish_1'] = 1;
    _currentTableCart['dish_2'] = 1;
    _currentTableCart['dish_3'] = 1;
  }
}
