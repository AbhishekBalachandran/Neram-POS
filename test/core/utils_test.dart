import 'package:flutter_test/flutter_test.dart';
import 'package:neram_pos/core/utils/currency_formatter.dart';
import 'package:neram_pos/viewmodels/app_viewmodel.dart';

void main() {
  group('Utility & ViewModel Tests', () {
    test('CurrencyFormatter formats currency correctly', () {
      expect(CurrencyFormatter.format(150), '₹150.00');
      expect(CurrencyFormatter.format(99.5), '₹99.50');
      expect(CurrencyFormatter.formatCompact(250), '₹250');
    });

    test('AppViewModel updates outlet and shift state correctly', () {
      final viewModel = AppViewModel();

      expect(viewModel.currentOutletId, isNull);
      expect(viewModel.isOnline, isTrue);

      viewModel.setOutlet(id: 'outlet_1', name: 'Downtown Branch');
      expect(viewModel.currentOutletId, 'outlet_1');
      expect(viewModel.currentOutletName, 'Downtown Branch');

      viewModel.startShift();
      expect(viewModel.shiftStartTime, isNotNull);

      viewModel.endShift();
      expect(viewModel.shiftStartTime, isNull);
    });
  });
}
