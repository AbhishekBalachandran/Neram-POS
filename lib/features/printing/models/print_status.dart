/// Lifecycle states of a physical thermal print job.
enum PrintStatus {
  pending,
  printing,
  printed,
  failed,
  fallbackRequested,
  serverPrinted,
  unknown;

  /// Whether the job has completed printing (locally or via server fallback).
  bool get isCompleted => this == printed || this == serverPrinted;

  /// Whether this is a terminal success status that must never be downgraded.
  bool get isFinalSuccess => this == printed || this == serverPrinted;

  /// Whether direct LAN printing can be attempted on this job.
  /// (Guards against duplicate printing once printed, server-printed, or fallback-requested).
  bool get canDirectPrint =>
      this != printed && this != serverPrinted && this != fallbackRequested;

  String get displayName => switch (this) {
    PrintStatus.pending => 'Pending',
    PrintStatus.printing => 'Printing',
    PrintStatus.printed => 'Printed',
    PrintStatus.failed => 'Failed',
    PrintStatus.fallbackRequested => 'Server Fallback',
    PrintStatus.serverPrinted => 'Server Printed',
    PrintStatus.unknown => 'Status Unknown',
  };

  static PrintStatus fromString(String value) {
    return PrintStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PrintStatus.unknown,
    );
  }
}

