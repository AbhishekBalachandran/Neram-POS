import 'package:neram_pos/data/models/stock_item_model.dart';
import 'package:neram_pos/viewmodels/base_viewmodel.dart';

enum StockSortOption {
  nameAsc,
  stockLevelAsc,
  stockLevelDesc,
  valueDesc;

  String get displayName {
    switch (this) {
      case StockSortOption.nameAsc:
        return 'Name (A to Z)';
      case StockSortOption.stockLevelAsc:
        return 'Stock Level (Lowest First)';
      case StockSortOption.stockLevelDesc:
        return 'Stock Level (Highest First)';
      case StockSortOption.valueDesc:
        return 'Total Valuation (Highest First)';
    }
  }
}

/// ViewModel for NERAM POS Stocks & Inventory Management.
/// Matches the official Stitch specification with live search, category filtering,
/// priority restock toggling, restocking adjustments, usage logs, and weekly audits.
class StockViewModel extends BaseViewModel {
  StockViewModel() {
    _initializeSeedCatalog();
  }

  final List<StockItemModel> _items = [];
  String _selectedCategoryCode = 'all';
  bool _isLowStockOnly = false;
  String _searchQuery = '';
  StockSortOption _sortOption = StockSortOption.stockLevelAsc;

  DateTime _lastKitchenAudit = DateTime.now().subtract(const Duration(days: 1));
  String _lastAuditedBy = 'Barista Lead (Abhishek)';

  // Getters
  List<StockItemModel> get allItems => List.unmodifiable(_items);
  String get selectedCategoryCode => _selectedCategoryCode;
  bool get isLowStockOnly => _isLowStockOnly;
  String get searchQuery => _searchQuery;
  StockSortOption get sortOption => _sortOption;
  DateTime get lastKitchenAudit => _lastKitchenAudit;
  String get lastAuditedBy => _lastAuditedBy;

  /// Total count of catalog items.
  int get totalItemsCount => _items.length;

  /// Count of items requiring immediate restock attention.
  int get lowAlertCount =>
      _items.where((item) => item.isLowStock).length;

  /// Count of zero-stock items.
  int get outOfStockCount =>
      _items.where((item) => item.status == StockStatus.outOfStock).length;

  /// Aggregate catalog inventory value in Indian Rupees.
  double get totalStockValue =>
      _items.fold(0.0, (acc, item) => acc + item.totalValue);

  /// Filtered and sorted items list presented in the UI.
  List<StockItemModel> get filteredItems {
    var result = List<StockItemModel>.from(_items);

    // 1. Category Filter
    if (_selectedCategoryCode != 'all') {
      result = result
          .where((item) => item.category.code == _selectedCategoryCode)
          .toList();
    }

    // 2. Low Stock Priority Filter
    if (_isLowStockOnly) {
      result = result.where((item) => item.isLowStock).toList();
    }

    // 3. Search Query Filter
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.supplier.toLowerCase().contains(query) ||
            item.category.displayName.toLowerCase().contains(query) ||
            item.unit.toLowerCase().contains(query);
      }).toList();
    }

    // 4. Sorting
    switch (_sortOption) {
      case StockSortOption.nameAsc:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case StockSortOption.stockLevelAsc:
        result.sort((a, b) => a.stockRatio.compareTo(b.stockRatio));
        break;
      case StockSortOption.stockLevelDesc:
        result.sort((a, b) => b.stockRatio.compareTo(a.stockRatio));
        break;
      case StockSortOption.valueDesc:
        result.sort((a, b) => b.totalValue.compareTo(a.totalValue));
        break;
    }

    return result;
  }

  // State Modifiers
  void setCategory(String categoryCode) {
    if (_selectedCategoryCode != categoryCode) {
      _selectedCategoryCode = categoryCode;
      notifyListeners();
    }
  }

  void toggleLowStockFilter() {
    _isLowStockOnly = !_isLowStockOnly;
    notifyListeners();
  }

  void setLowStockFilter(bool value) {
    if (_isLowStockOnly != value) {
      _isLowStockOnly = value;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(StockSortOption option) {
    if (_sortOption != option) {
      _sortOption = option;
      notifyListeners();
    }
  }

  /// Restock an existing inventory item with incoming batch quantity.
  Future<bool> restockItem({
    required String itemId,
    required double addedQuantity,
    String? invoiceNumber,
    String? supplierName,
    String staffName = 'Abhishek (Manager)',
  }) async {
    final index = _items.indexWhere((element) => element.id == itemId);
    if (index == -1 || addedQuantity <= 0) return false;

    final target = _items[index];
    final newStock = target.currentStock + addedQuantity;
    final log = StockLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      action: 'Restock Batch',
      quantityChange: addedQuantity,
      balanceAfter: newStock,
      staffName: staffName,
      notes: invoiceNumber != null ? 'Invoice/PO: $invoiceNumber' : null,
    );

    _items[index] = target.copyWith(
      currentStock: newStock,
      logs: [log, ...target.logs],
      supplier: supplierName ?? target.supplier,
    );

    notifyListeners();
    return true;
  }

  /// Deduct consumed stock (kitchen use, bar prep, waste/spoilage).
  Future<bool> recordUsage({
    required String itemId,
    required double usedQuantity,
    required String reason,
    String staffName = 'Abhishek (Manager)',
  }) async {
    final index = _items.indexWhere((element) => element.id == itemId);
    if (index == -1 || usedQuantity <= 0) return false;

    final target = _items[index];
    final newStock = (target.currentStock - usedQuantity).clamp(0.0, 999999.0);
    final log = StockLogEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      action: 'Kitchen Usage',
      quantityChange: -usedQuantity,
      balanceAfter: newStock,
      staffName: staffName,
      notes: reason,
    );

    _items[index] = target.copyWith(
      currentStock: newStock,
      logs: [log, ...target.logs],
    );

    notifyListeners();
    return true;
  }

  /// Create and register a brand new item in the catalog.
  Future<bool> addNewItem({
    required String name,
    required StockCategory category,
    required String unit,
    required double initialStock,
    required double minLevel,
    required double costPerUnit,
    required String supplier,
    String staffName = 'Abhishek (Manager)',
  }) async {
    final newItem = StockItemModel(
      id: 'stk_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      category: category,
      unit: unit.trim(),
      currentStock: initialStock,
      minLevel: minLevel,
      costPerUnit: costPerUnit,
      supplier: supplier.trim(),
      logs: [
        StockLogEntry(
          id: 'log_${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          action: 'Initial Inward',
          quantityChange: initialStock,
          balanceAfter: initialStock,
          staffName: staffName,
          notes: 'Added to catalog',
        ),
      ],
      lastAudited: DateTime.now(),
    );

    _items.insert(0, newItem);
    notifyListeners();
    return true;
  }

  /// Complete a physical stocktake/audit and update records.
  Future<void> completeAudit({
    required String staffName,
    String notes = 'Routine kitchen & bar stocktake',
  }) async {
    _lastKitchenAudit = DateTime.now();
    _lastAuditedBy = staffName;
    notifyListeners();
  }

  /// Seeds catalog precisely matching the Stitch "NERAM POS - Stocks & Inventory Management" screen.
  void _initializeSeedCatalog() {
    _items.addAll([
      // 1. Arabica Coffee Beans (Dark Roast) - Priority Low Stock
      StockItemModel(
        id: 'stk_01',
        name: 'Arabica Coffee Beans (Dark Roast)',
        category: StockCategory.foodRaw,
        unit: '1 kg bag',
        currentStock: 3.5,
        minLevel: 10.0,
        costPerUnit: 880.00,
        supplier: 'Nilgiri Roasters',
        logs: [
          StockLogEntry(
            id: 'l_1',
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
            action: 'Usage',
            quantityChange: -1.5,
            balanceAfter: 3.5,
            staffName: 'Barista 01',
            notes: 'Morning shift espresso prep',
          ),
        ],
      ),

      // 2. Full Cream Cow Milk - Critical Low Stock
      StockItemModel(
        id: 'stk_02',
        name: 'Full Cream Cow Milk',
        category: StockCategory.foodRaw,
        unit: 'Litre',
        currentStock: 6.0,
        minLevel: 20.0,
        costPerUnit: 68.00,
        supplier: 'Heritage Dairy Direct',
        logs: [
          StockLogEntry(
            id: 'l_2',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            action: 'Usage',
            quantityChange: -8.0,
            balanceAfter: 6.0,
            staffName: 'Barista 02',
            notes: 'Beverage steaming consumption',
          ),
        ],
      ),

      // 3. Takeaway Ripple Cups (250ml) - Low Stock
      StockItemModel(
        id: 'stk_03',
        name: 'Takeaway Ripple Cups (250ml)',
        category: StockCategory.consumables,
        unit: 'Pieces',
        currentStock: 140.0,
        minLevel: 500.0,
        costPerUnit: 4.20,
        supplier: 'GreenPack Supplies Ltd',
        logs: [
          StockLogEntry(
            id: 'l_3',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            action: 'Dispense',
            quantityChange: -100.0,
            balanceAfter: 140.0,
            staffName: 'Cashier 01',
            notes: 'Front counter supply refill',
          ),
        ],
      ),

      // 4. Madagascar Vanilla Syrup (750ml) - Optimal
      StockItemModel(
        id: 'stk_04',
        name: 'Madagascar Vanilla Syrup (750ml)',
        category: StockCategory.foodRaw,
        unit: 'Bottle',
        currentStock: 8.0,
        minLevel: 3.0,
        costPerUnit: 540.00,
        supplier: 'Monin Direct India',
      ),

      // 5. Stainless Milk Pitcher 600ml - Small Equipment (Optimal)
      StockItemModel(
        id: 'stk_05',
        name: 'Stainless Milk Pitcher 600ml',
        category: StockCategory.smallEquipment,
        unit: 'Unit / Pc',
        currentStock: 6.0,
        minLevel: 2.0,
        costPerUnit: 620.00,
        supplier: 'Barista Pro Gear & Tools',
      ),

      // 6. Eco Paper Napkins (Pack of 500) - Consumables (Optimal)
      StockItemModel(
        id: 'stk_06',
        name: 'Eco Paper Napkins (Pack of 500)',
        category: StockCategory.consumables,
        unit: 'Pack',
        currentStock: 18.0,
        minLevel: 5.0,
        costPerUnit: 120.00,
        supplier: 'CleanWell Hospitality Co.',
      ),

      // 7. Organic Matcha Powder (Ceremonial Grade) - Food & Raw
      StockItemModel(
        id: 'stk_07',
        name: 'Organic Matcha Powder (Ceremonial)',
        category: StockCategory.foodRaw,
        unit: '500g tin',
        currentStock: 4.0,
        minLevel: 2.0,
        costPerUnit: 1850.00,
        supplier: 'Kyoto Imports Co.',
      ),

      // 8. Single Origin Cold Brew Blend - Food & Raw
      StockItemModel(
        id: 'stk_08',
        name: 'Single Origin Cold Brew Blend',
        category: StockCategory.foodRaw,
        unit: '1 kg bag',
        currentStock: 12.0,
        minLevel: 5.0,
        costPerUnit: 920.00,
        supplier: 'Blue Tokai Roasters',
      ),

      // 9. Caramel Drizzle Sauce (1kg) - Food & Raw
      StockItemModel(
        id: 'stk_09',
        name: 'Caramel Drizzle Sauce (1kg)',
        category: StockCategory.foodRaw,
        unit: 'Bottle',
        currentStock: 7.0,
        minLevel: 3.0,
        costPerUnit: 460.00,
        supplier: 'Monin Direct India',
      ),

      // 10. Oat Milk Barista Edition (1L) - Food & Raw
      StockItemModel(
        id: 'stk_10',
        name: 'Oat Milk Barista Edition (1L)',
        category: StockCategory.foodRaw,
        unit: 'Carton',
        currentStock: 24.0,
        minLevel: 12.0,
        costPerUnit: 240.00,
        supplier: 'Oatly Distributor India',
      ),

      // 11. Biodegradable Straws (Pack of 250) - Consumables
      StockItemModel(
        id: 'stk_11',
        name: 'Biodegradable Straws (Pack of 250)',
        category: StockCategory.consumables,
        unit: 'Pack',
        currentStock: 15.0,
        minLevel: 5.0,
        costPerUnit: 160.00,
        supplier: 'GreenPack Supplies Ltd',
      ),

      // 12. Thermal Receipt Rolls (80mm x 50m) - Consumables
      StockItemModel(
        id: 'stk_12',
        name: 'Thermal Receipt Rolls (80mm)',
        category: StockCategory.consumables,
        unit: 'Box (50 rolls)',
        currentStock: 8.0,
        minLevel: 2.0,
        costPerUnit: 950.00,
        supplier: 'POS Hardware Depot',
      ),

      // 13. Double Walled Espresso Glasses (80ml) - Small Equipment
      StockItemModel(
        id: 'stk_13',
        name: 'Double Walled Espresso Glasses',
        category: StockCategory.smallEquipment,
        unit: 'Set of 6',
        currentStock: 10.0,
        minLevel: 3.0,
        costPerUnit: 850.00,
        supplier: 'Barista Pro Gear & Tools',
      ),

      // 14. Heavy Duty Coffee Tamper (58.5mm) - Small Equipment
      StockItemModel(
        id: 'stk_14',
        name: 'Heavy Duty Precision Tamper 58.5mm',
        category: StockCategory.smallEquipment,
        unit: 'Unit / Pc',
        currentStock: 4.0,
        minLevel: 2.0,
        costPerUnit: 1450.00,
        supplier: 'Barista Pro Gear & Tools',
      ),

      // 15. Commercial Burr Set (64mm Titanium) - Fixed Assets
      StockItemModel(
        id: 'stk_15',
        name: 'Titanium Burr Set 64mm',
        category: StockCategory.fixedAssets,
        unit: 'Pair',
        currentStock: 2.0,
        minLevel: 1.0,
        costPerUnit: 7800.00,
        supplier: 'Mahlkönig Partner India',
      ),

      // 16. Digital Precision Brewing Scale - Fixed Assets
      StockItemModel(
        id: 'stk_16',
        name: 'Acaia Lunar Precision Scale',
        category: StockCategory.fixedAssets,
        unit: 'Unit',
        currentStock: 3.0,
        minLevel: 1.0,
        costPerUnit: 18500.00,
        supplier: 'Specialty Brew Hub',
      ),

      // 17. Commercial Water Filter Cartridge - Fixed Assets
      StockItemModel(
        id: 'stk_17',
        name: 'Everpure Water Filtration Cartridge',
        category: StockCategory.fixedAssets,
        unit: 'Unit',
        currentStock: 2.0,
        minLevel: 1.0,
        costPerUnit: 11200.00,
        supplier: 'Pentair India Commercial',
      ),

      // 18. Artisanal Sourdough Bread Loaves - Food & Raw
      StockItemModel(
        id: 'stk_18',
        name: 'Artisanal Sourdough Loaves',
        category: StockCategory.foodRaw,
        unit: 'Loaf (800g)',
        currentStock: 14.0,
        minLevel: 6.0,
        costPerUnit: 180.00,
        supplier: 'Crust & Crumb Bakery',
      ),
    ]);
  }
}
