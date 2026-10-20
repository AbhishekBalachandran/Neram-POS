import 'package:flutter/foundation.dart';
import 'package:neram_pos/core/errors/app_exception.dart';

enum ViewState { idle, busy, error, success }

/// Base ViewModel that standardizes busy/error states across all MVVM components.
/// Easily migratable to Cubit / Bloc states in the future.
abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  bool _isDisposed = false;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  bool get isIdle => _state == ViewState.idle;
  bool get isBusy => _state == ViewState.busy;
  bool get hasError => _state == ViewState.error;
  bool get isSuccess => _state == ViewState.success;
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  void setBusy(bool value) {
    _state = value ? ViewState.busy : ViewState.idle;
    if (value) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _state = ViewState.error;
    notifyListeners();
  }

  void setException(AppException exception) {
    _errorMessage = exception.message;
    _state = ViewState.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == ViewState.error) {
      _state = ViewState.idle;
    }
    notifyListeners();
  }

  /// Helper to run an async operation with automated busy/error handling.
  Future<T?> runBusyFuture<T>(
    Future<T> Function() future, {
    void Function(AppException exception)? onError,
  }) async {
    setBusy(true);
    try {
      final result = await future();
      _state = ViewState.success;
      notifyListeners();
      return result;
    } on AppException catch (e) {
      setException(e);
      onError?.call(e);
      return null;
    } catch (e) {
      final unexpected = UnexpectedException(message: e.toString());
      setException(unexpected);
      onError?.call(unexpected);
      return null;
    } finally {
      if (_state == ViewState.busy) {
        _state = ViewState.idle;
        notifyListeners();
      }
    }
  }
}
