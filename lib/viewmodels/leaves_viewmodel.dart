import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/data/models/leave_model.dart';
import 'package:neram_pos/data/repositories/leaves_repository.dart';

/// State management for the Leaves & Attendance Workspace from Stitch.
class LeavesViewModel extends ChangeNotifier {
  LeavesViewModel({this.repository}) {
    _initializeData();
    _startLiveClock();
    _fetchFromApi();
  }

  final LeavesRepository? repository;

  Timer? _ticker;
  DateTime _currentTime = DateTime.now();
  bool _isCheckedIn = true;
  DateTime? _checkInTime = DateTime.now().subtract(
    const Duration(hours: 4, minutes: 22, seconds: 14),
  );
  String _stationName = 'Active';

  int _selectedYear = 2024;
  String _selectedMonth = 'October';
  int _absentDays = 1;
  int _leaveDays = 2;

  Future<void> _fetchFromApi() async {
    if (repository == null) return;
    try {
      final remoteLeaves = await repository!.getLeaveApplications();
      if (remoteLeaves.isNotEmpty) {
        _applications = remoteLeaves;
        notifyListeners();
      }
      final summary = await repository!.getMonthlySummary(
        year: _selectedYear,
        month: _selectedMonth,
      );
      if (summary != null) {
        if (summary['absentDays'] is num) _absentDays = (summary['absentDays'] as num).toInt();
        if (summary['leaveDays'] is num) _leaveDays = (summary['leaveDays'] as num).toInt();
        notifyListeners();
      }
    } catch (_) {}
  }

  static const List<int> yearsList = [2023, 2024, 2025, 2026, 2027];
  static const List<String> monthsList = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late List<LeaveApplicationModel> _applications;

  // Getters
  DateTime get currentTime => _currentTime;
  bool get isCheckedIn => _isCheckedIn;
  DateTime? get checkInTime => _checkInTime;
  String get stationName => _stationName;
  int get selectedYear => _selectedYear;
  String get selectedMonth => _selectedMonth;
  List<LeaveApplicationModel> get applications => _applications;

  // Monthly Attendance & Working Days Metrics
  int get daysInMonth {
    final mIndex = monthsList.indexOf(_selectedMonth) + 1;
    final m = mIndex > 0 ? mIndex : 10;
    return DateTime(_selectedYear, m + 1, 0).day;
  }

  int get totalMonthDays => daysInMonth;
  int get absentDays => _absentDays;
  int get leaveDays => _leaveDays;
  int get totalAbsentLeaveDays => _absentDays + _leaveDays;
  int get absentCount => _absentDays;
  int get leaveCount => _leaveDays;

  // Legacy/Additional Metrics
  String get joinedDate => '15 Jan 2024';
  int get eligibleWorkDays => 26;
  int get presentDays => 21;
  int get offDays => 5;
  double get attendanceRate => 91.3;

  Duration get shiftDuration {
    if (!_isCheckedIn || _checkInTime == null) return Duration.zero;
    return _currentTime.difference(_checkInTime!);
  }

  String get formattedShiftDuration {
    final d = shiftDuration;
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}m ${seconds}s';
  }

  void _startLiveClock() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _currentTime = DateTime.now();
      notifyListeners();
    });
  }

  void checkIn() {
    HapticService.success();
    _isCheckedIn = true;
    final now = DateTime.now();
    _checkInTime = now;
    _stationName = 'Active';
    notifyListeners();
    repository?.checkIn(timestamp: now, station: _stationName);
  }

  void checkOut() {
    HapticService.mediumImpact();
    _isCheckedIn = false;
    _checkInTime = null;
    _stationName = 'Inactive';
    notifyListeners();
    repository?.checkOut(timestamp: DateTime.now());
  }

  void applyLeave({
    required DateTime startDate,
    required DateTime endDate,
    required LeaveType type,
    required String reason,
    required String applicantName,
    required String applicantRole,
    required String staffId,
  }) {
    HapticService.success();
    final days = endDate.difference(startDate).inDays + 1;
    final initials = applicantName.isNotEmpty
        ? applicantName
            .trim()
            .split(RegExp(r'\s+'))
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'ST';

    final newApplication = LeaveApplicationModel(
      id: 'LV-${DateTime.now().millisecondsSinceEpoch % 10000}',
      applicantName: applicantName,
      applicantRole: applicantRole,
      staffId: staffId,
      initials: initials,
      startDate: startDate,
      endDate: endDate,
      days: days > 0 ? days : 1,
      type: type,
      reason: reason,
      status: LeaveStatus.pending,
      reviewedBy: 'Awaiting Manager Dispatch',
      appliedAt: DateTime.now(),
    );

    _applications.insert(0, newApplication);
    notifyListeners();
    repository?.applyLeave(newApplication);
  }

  void cancelLeave(String id) {
    HapticService.selection();
    _applications.removeWhere((app) => app.id == id);
    notifyListeners();
    repository?.cancelLeave(id);
  }

  void setMonth(String month) {
    if (_selectedMonth != month) {
      HapticService.selection();
      _selectedMonth = month;
      notifyListeners();
      _fetchSummaryOnly();
    }
  }

  void setYear(int year) {
    if (_selectedYear != year) {
      HapticService.selection();
      _selectedYear = year;
      notifyListeners();
      _fetchSummaryOnly();
    }
  }

  Future<void> _fetchSummaryOnly() async {
    if (repository == null) return;
    try {
      final summary = await repository!.getMonthlySummary(
        year: _selectedYear,
        month: _selectedMonth,
      );
      if (summary != null) {
        if (summary['absentDays'] is num) _absentDays = (summary['absentDays'] as num).toInt();
        if (summary['leaveDays'] is num) _leaveDays = (summary['leaveDays'] as num).toInt();
        notifyListeners();
      }
    } catch (_) {}
  }

  void _initializeData() {
    _applications = [
      LeaveApplicationModel(
        id: 'LV-8812',
        applicantName: 'Kavita Nair',
        applicantRole: 'Head Barista',
        staffId: 'Staff #N-104',
        initials: 'KN',
        startDate: DateTime(2024, 10, 28),
        endDate: DateTime(2024, 10, 29),
        days: 2,
        type: LeaveType.paidLeave,
        reason: 'Annual Family Function & Travel',
        status: LeaveStatus.approved,
        reviewedBy: 'Chef Julian V.',
        appliedAt: DateTime(2024, 10, 20),
      ),
      LeaveApplicationModel(
        id: 'LV-8815',
        applicantName: 'Sarah Jenkins',
        applicantRole: 'Floor Captain',
        staffId: 'Staff #N-082',
        initials: 'SJ',
        startDate: DateTime(2024, 11, 2),
        endDate: DateTime(2024, 11, 3),
        days: 2,
        type: LeaveType.casualLeave,
        reason: 'Emergency Dental Procedure',
        status: LeaveStatus.pending,
        reviewedBy: 'Awaiting General Manager',
        appliedAt: DateTime(2024, 10, 22),
      ),
      LeaveApplicationModel(
        id: 'LV-8798',
        applicantName: 'David Kim',
        applicantRole: 'Lead Mixologist',
        staffId: 'Staff #N-095',
        initials: 'DK',
        startDate: DateTime(2024, 10, 31),
        endDate: DateTime(2024, 10, 31),
        days: 1,
        type: LeaveType.paidLeave,
        reason: 'Personal Weekend Holiday',
        status: LeaveStatus.rejected,
        reviewedBy: 'Chef Julian V. (Peak Service Conflict)',
        appliedAt: DateTime(2024, 10, 18),
      ),
    ];
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

