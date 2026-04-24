import 'package:flutter/foundation.dart';

import '../../data/models/finance_dashboard.dart';
import '../../services/app_services.dart';
import '../../utils/period_range.dart';

class FinanceScreenController extends ChangeNotifier {
  static const Duration _dashboardCacheTtl = Duration(seconds: 60);
  static const Duration _yearsCacheTtl = Duration(minutes: 10);

  bool loading = true;
  bool updating = false;
  String? error;
  FinanceDashboard? data;
  List<int> availableYears = const <int>[];

  int? year; // null = all years
  int? quarter; // 1..4 (only valid when year != null)

  int _requestTicket = 0;
  bool _isActive = false;
  bool _hasLoaded = false;
  bool _pendingReload = false;
  bool _disposed = false;

  FinanceScreenController() {
    final shared = AppServices.periodFilters.selection.value;
    year = shared.year;
    quarter = shared.quarter;
    AppServices.periodFilters.selection.addListener(_onSharedFilterChanged);
  }

  Future<void> setActive(bool active) async {
    final becameActive = active && !_isActive;
    _isActive = active;
    if (!active) return;

    if (!_hasLoaded) {
      _hasLoaded = true;
      await load(refreshYears: true);
      return;
    }

    if (becameActive && _pendingReload) {
      _pendingReload = false;
      await load();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    AppServices.periodFilters.selection.removeListener(_onSharedFilterChanged);
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  bool _isRequestStale(int requestTicket) =>
      _disposed || requestTicket != _requestTicket;

  void _onSharedFilterChanged() {
    final shared = AppServices.periodFilters.selection.value;
    if (year == shared.year && quarter == shared.quarter) return;
    year = shared.year;
    quarter = shared.quarter;
    _safeNotify();
    if (!_isActive) {
      _pendingReload = true;
      return;
    }
    load();
  }

  void updateSharedFilter({
    required int? year,
    required int? quarter,
  }) {
    AppServices.periodFilters.setSelection(
      year: year,
      quarter: quarter,
    );
  }

  String _errorMessageOf(Object rawError) {
    final text = rawError.toString().trim();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length).trim();
    }
    return text;
  }

  Future<FinanceDashboard> _fetchDashboard({
    required int? year,
    required int? quarter,
    required bool forceRefresh,
  }) {
    final range = computePeriodRange(year: year, quarter: quarter);
    return AppServices.finance.getDashboard(
      from: range.from,
      to: range.to,
      cacheTtl: _dashboardCacheTtl,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> load({
    bool refreshYears = false,
    bool forceRefresh = false,
  }) async {
    _hasLoaded = true;
    _pendingReload = false;
    final requestTicket = ++_requestTicket;
    final initial = data == null;

    error = null;
    if (initial) {
      loading = true;
      updating = false;
    } else {
      updating = true;
    }
    _safeNotify();

    try {
      final shouldRefreshYears = refreshYears || availableYears.isEmpty;
      var nextYears = availableYears;
      int? effectiveYear = year;
      int? effectiveQuarter = quarter;
      if (effectiveYear != null &&
          nextYears.isNotEmpty &&
          !nextYears.contains(effectiveYear)) {
        effectiveYear = null;
        effectiveQuarter = null;
      }
      if (effectiveYear == null) effectiveQuarter = null;

      late FinanceDashboard financeData;
      if (shouldRefreshYears) {
        final results = await Future.wait<dynamic>([
          _fetchDashboard(
            year: effectiveYear,
            quarter: effectiveQuarter,
            forceRefresh: forceRefresh,
          ),
          AppServices.finance.availableYears(
            cacheTtl: _yearsCacheTtl,
            forceRefresh: forceRefresh,
          ),
        ]);
        if (_isRequestStale(requestTicket)) return;

        financeData = results[0] as FinanceDashboard;
        nextYears = results[1] as List<int>;

        if (effectiveYear != null &&
            nextYears.isNotEmpty &&
            !nextYears.contains(effectiveYear)) {
          effectiveYear = null;
          effectiveQuarter = null;
          financeData = await _fetchDashboard(
            year: effectiveYear,
            quarter: effectiveQuarter,
            forceRefresh: forceRefresh,
          );
          if (_isRequestStale(requestTicket)) return;
        }

        availableYears = nextYears;
      } else {
        financeData = await _fetchDashboard(
          year: effectiveYear,
          quarter: effectiveQuarter,
          forceRefresh: forceRefresh,
        );
        if (_isRequestStale(requestTicket)) return;
      }

      year = effectiveYear;
      quarter = effectiveQuarter;
      data = financeData;
      loading = false;
      updating = false;
      _safeNotify();

      updateSharedFilter(year: effectiveYear, quarter: effectiveQuarter);
    } catch (e) {
      if (_isRequestStale(requestTicket)) return;
      error = _errorMessageOf(e);
      loading = false;
      updating = false;
      _safeNotify();
    }
  }
}
