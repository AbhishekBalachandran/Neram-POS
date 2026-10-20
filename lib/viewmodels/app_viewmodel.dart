import 'package:neram_pos/viewmodels/base_viewmodel.dart';

/// App-level ViewModel handling POS terminal status, current outlet & shift information.
class AppViewModel extends BaseViewModel {
  String? _currentOutletId;
  String? _currentOutletName;
  bool _isOnline = true;
  DateTime? _shiftStartTime;

  String? get currentOutletId => _currentOutletId;
  String? get currentOutletName => _currentOutletName;
  bool get isOnline => _isOnline;
  DateTime? get shiftStartTime => _shiftStartTime;

  void setOutlet({required String id, required String name}) {
    _currentOutletId = id;
    _currentOutletName = name;
    notifyListeners();
  }

  void setNetworkStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      notifyListeners();
    }
  }

  void startShift() {
    _shiftStartTime = DateTime.now();
    notifyListeners();
  }

  void endShift() {
    _shiftStartTime = null;
    notifyListeners();
  }
}
