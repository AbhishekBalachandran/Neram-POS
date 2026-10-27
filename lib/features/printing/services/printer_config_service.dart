import 'dart:convert';
import 'package:neram_pos/core/constants/api_endpoints.dart';
import 'package:neram_pos/core/network/api_client.dart';
import 'package:neram_pos/core/services/logger_service.dart';
import 'package:neram_pos/features/printing/models/printer_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for fetching, caching, and routing printers by dish category.
class PrinterConfigService {
  PrinterConfigService({
    required this.prefs,
    required this.apiClient,
  }) {
    _loadCached();
  }

  final SharedPreferences prefs;
  final ApiClient apiClient;
  SharedPreferences get _prefs => prefs;
  ApiClient get _apiClient => apiClient;

  static const String _storageKey = 'neram_printer_configs_v1';
  List<PrinterConfig> _printers = [];

  List<PrinterConfig> get printers => List.unmodifiable(_printers);

  /// Default seed configuration used when offline or before initial fetch
  static const List<PrinterConfig> defaultPrinters = [
    PrinterConfig(
      id: 'prn_kitchen_01',
      name: 'Main Kitchen Thermal Printer',
      ip: '192.168.1.100',
      port: 9100,
      role: 'kitchen',
      isDefault: true,
      categories: [
        'Starters',
        'Egg Preparations',
        'Soups',
        'Main Course',
        'Breads & Rice',
      ],
    ),
    PrinterConfig(
      id: 'prn_bar_01',
      name: 'Beverage & Bar Thermal Printer',
      ip: '192.168.1.101',
      port: 9100,
      role: 'bar',
      categories: [
        'Beverages',
        'Desserts',
      ],
    ),
  ];

  void _loadCached() {
    final raw = _prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List<dynamic>)
            .map((e) => PrinterConfig.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          _printers = list;
          return;
        }
      } catch (e) {
        LoggerService.error('Failed to parse cached printer configs: $e');
      }
    }
    _printers = List.of(defaultPrinters);
  }

  Future<void> _saveCache(List<PrinterConfig> configs) async {
    final raw = jsonEncode(configs.map((c) => c.toJson()).toList());
    await _prefs.setString(_storageKey, raw);
  }

  /// Fetches printer configurations from `GET /printers`, scoped by outlet if available.
  /// Falls back to local cache gracefully when offline.
  Future<List<PrinterConfig>> fetchPrinters({String? outletId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (outletId != null && outletId.isNotEmpty) {
        queryParams['outletId'] = outletId;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.printers,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final body = response.data ?? <String, dynamic>{};
      final data = (body['data'] as Map<String, dynamic>?) ?? body;
      final rawList = data['printers'] as List<dynamic>?;

      if (rawList != null && rawList.isNotEmpty) {
        final fetched = rawList
            .map((e) => PrinterConfig.fromJson(e as Map<String, dynamic>))
            .toList();
        _printers = fetched;
        await _saveCache(fetched);
        LoggerService.info('Fetched and cached ${_printers.length} printers from server.');
      }
    } catch (e) {
      LoggerService.warning('Could not fetch printers from server ($e). Using local cached configs.');
    }

    return _printers;
  }

  /// Finds the responsible printer for a given dish category.
  /// Defaults to the primary kitchen printer if no explicit match is configured.
  PrinterConfig getPrinterForCategory(String category) {
    if (_printers.isEmpty) {
      return defaultPrinters.first;
    }

    final match = _printers.cast<PrinterConfig?>().firstWhere(
      (p) => p!.canPrintCategory(category),
      orElse: () => null,
    );

    if (match != null) return match;

    // Fallback to default printer
    return _printers.firstWhere(
      (p) => p.isDefault,
      orElse: () => _printers.first,
    );
  }
}
