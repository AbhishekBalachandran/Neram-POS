import 'dart:convert';
import 'package:intl/intl.dart';

/// Single item entry for kitchen order ticket rendering.
class KitchenTicketItem {
  const KitchenTicketItem({
    required this.name,
    required this.quantity,
    this.itemNote,
    this.category,
  });

  final String name;
  final int quantity;
  final String? itemNote;
  final String? category;
}

/// Builds ESC/POS standard binary command sequences for 80mm / 58mm thermal receipt printers.
abstract final class TicketBuilder {
  // ESC/POS Command Byte Constants
  static const List<int> _init = [0x1B, 0x40]; // ESC @
  static const List<int> _alignCenter = [0x1B, 0x61, 0x01]; // ESC a 1
  static const List<int> _alignLeft = [0x1B, 0x61, 0x00]; // ESC a 0
  static const List<int> _boldOn = [0x1B, 0x45, 0x01]; // ESC E 1
  static const List<int> _boldOff = [0x1B, 0x45, 0x00]; // ESC E 0
  static const List<int> _doubleSize = [0x1D, 0x21, 0x11]; // GS ! 0x11 (Double width + height)
  static const List<int> _doubleHeight = [0x1D, 0x21, 0x01]; // GS ! 0x01
  static const List<int> _normalSize = [0x1D, 0x21, 0x00]; // GS ! 0x00
  static const List<int> _feed3 = [0x1B, 0x64, 0x03]; // ESC d 3
  static const List<int> _cutPaper = [0x1D, 0x56, 0x42, 0x00]; // GS V 'B' 0 (Partial Cut)
  static const int _lf = 0x0A;

  /// Builds a kitchen order ticket (KOT) byte sequence.
  /// Includes header, table, local order no, time, items with qty and notes,
  /// optional [isReprint] banner, feed and paper cut.
  static List<int> buildKitchenTicket({
    required String orderNo,
    required String tableName,
    required String diningMode,
    String? customerName,
    String? orderNote,
    required List<KitchenTicketItem> items,
    required DateTime timestamp,
    bool isReprint = false,
    String title = 'KITCHEN ORDER TICKET (KOT)',
  }) {
    final buffer = <int>[];

    void writeString(String text) {
      buffer.addAll(latin1.encode(text));
    }

    void writeLine(String text) {
      writeString(text);
      buffer.add(_lf);
    }

    void writeDivider() {
      writeLine('------------------------------------------------');
    }

    // 1. Initialize Printer
    buffer.addAll(_init);

    // 2. REPRINT Header (if manual reprint)
    if (isReprint) {
      buffer.addAll(_alignCenter);
      buffer.addAll(_boldOn);
      buffer.addAll(_doubleSize);
      writeLine('*** REPRINT ***');
      buffer.addAll(_normalSize);
      buffer.addAll(_boldOff);
      buffer.add(_lf);
    }

    // 3. Header & Title
    buffer.addAll(_alignCenter);
    buffer.addAll(_boldOn);
    buffer.addAll(_doubleHeight);
    writeLine(title);
    buffer.addAll(_normalSize);
    buffer.addAll(_boldOff);
    writeDivider();

    // 4. Order Metadata (Table, Order #, Time)
    buffer.addAll(_alignLeft);
    buffer.addAll(_boldOn);
    buffer.addAll(_doubleHeight);
    writeLine('TABLE: $tableName ($diningMode)');
    buffer.addAll(_normalSize);
    buffer.addAll(_boldOff);

    writeLine('ORDER NO : $orderNo');
    writeLine('TIME     : ${DateFormat('dd MMM yyyy, hh:mm:ss a').format(timestamp.toLocal())}');
    if (customerName != null && customerName.trim().isNotEmpty) {
      writeLine('CUSTOMER : $customerName');
    }
    if (orderNote != null && orderNote.trim().isNotEmpty) {
      buffer.addAll(_boldOn);
      writeLine('NOTE     : $orderNote');
      buffer.addAll(_boldOff);
    }
    writeDivider();

    // 5. Items Header
    buffer.addAll(_boldOn);
    writeLine('QTY  ITEM DESCRIPTION');
    buffer.addAll(_boldOff);
    writeDivider();

    // 6. Item Lines
    for (final item in items) {
      buffer.addAll(_boldOn);
      buffer.addAll(_doubleHeight);
      final qtyPrefix = '${item.quantity}x'.padRight(5);
      writeLine('$qtyPrefix ${item.name}');
      buffer.addAll(_normalSize);
      buffer.addAll(_boldOff);

      // Item-level note (e.g. "extra spicy", "no onion")
      if (item.itemNote != null && item.itemNote!.trim().isNotEmpty) {
        writeLine('     * NOTE: ${item.itemNote!.trim()}');
      }
      buffer.add(_lf);
    }

    writeDivider();

    // 7. Footer & Paper Feed + Cut
    buffer.addAll(_alignCenter);
    writeLine('NERAM POS • KITCHEN DISPATCH');
    buffer.addAll(_feed3);
    buffer.addAll(_cutPaper);

    return buffer;
  }

  /// Stub for customer billing / payment receipts.
  static List<int> buildBillTicket({
    required String orderNo,
    required String tableName,
    required double subtotal,
    required double tax,
    required double total,
    required DateTime timestamp,
  }) {
    final buffer = <int>[];
    buffer.addAll(_init);
    buffer.addAll(_alignCenter);
    buffer.addAll(_boldOn);
    buffer.addAll(_doubleHeight);
    buffer.addAll(latin1.encode('NERAM POS\n'));
    buffer.addAll(_normalSize);
    buffer.addAll(_boldOff);
    buffer.addAll(latin1.encode('TAX INVOICE\n'));
    buffer.addAll(latin1.encode('Order: $orderNo • Table: $tableName\n'));
    buffer.addAll(latin1.encode('Total Payable: ₹${total.toStringAsFixed(2)}\n'));
    buffer.addAll(_feed3);
    buffer.addAll(_cutPaper);
    return buffer;
  }
}
