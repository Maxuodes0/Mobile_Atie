import 'package:flutter/foundation.dart';

import '../../data/models/dashboard_mobile_summary.dart';
import '../../data/models/dashboard_summary.dart';
import '../../data/models/finance_dashboard.dart';
import '../../data/models/monthly_collection_point.dart';
import '../../data/models/project_status_count.dart';
import '../../data/models/project_summary.dart';
import '../../services/app_services.dart';
import '../../utils/period_range.dart';

class DashboardScreenController extends ChangeNotifier {
  static const sectionYears = 'years';
  static const sectionFinance = 'finance';
  static const sectionCollections = 'collections';
  static const sectionStatusCounts = 'statusCounts';
  static const sectionSummary = 'summary';
  static const sectionLatestProjects = 'latestProjects';

  bool loading = true;
  bool updating = false;
  String? error;

  FinanceDashboard? finance;
  DashboardSummary? summary;
  List<MonthlyCollectionPoint> collections = const <MonthlyCollectionPoint>[];
  List<ProjectStatusCount> statusCounts = const <ProjectStatusCount>[];
  List<ProjectSummary> latestProjects = const <ProjectSummary>[];
  List<int> availableYears = const <int>[];

  Map<String, String> sectionErrors = const <String, String>{};
  final Set<String> updatingSections = <String>{};

  int? year; // null = all years
  int? quarter; // 1..4 (only valid when year != null)

  int _requestTicket = 0;
  bool _isActive = false;
  bool _hasLoaded = false;
  bool _pendingReload = false;
  bool _disposed = false;

  DashboardScreenController() {
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

  bool _canApplyRequest(int ticket) => !_disposed && ticket == _requestTicket;

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

  List<String> _primarySectionsForLoad({required bool refreshYears}) {
    final sections = <String>[sectionFinance];
    if (refreshYears || availableYears.isEmpty) {
      sections.insert(0, sectionYears);
    }
    return sections;
  }

  List<String> _heavySectionsForLoad() {
    return const <String>[
      sectionCollections,
      sectionStatusCounts,
      sectionSummary,
      sectionLatestProjects,
    ];
  }

  Future<DashboardMobileSummary> _fetchSections({
    required int? year,
    required PeriodRange range,
    required List<String> sections,
    required Duration cacheTtl,
    required bool forceRefresh,
  }) {
    return AppServices.dashboard.mobileSummary(
      year: year,
      from: range.from,
      to: range.to,
      sections: sections,
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );
  }

  void _setSectionsLoading(Iterable<String> sections) {
    final keys = sections.toSet();
    if (keys.isEmpty) return;
    updatingSections.addAll(keys);
    final nextErrors = Map<String, String>.from(sectionErrors);
    for (final key in keys) {
      nextErrors.remove(key);
    }
    sectionErrors = nextErrors;
    _safeNotify();
  }

  void _setSectionsError(Iterable<String> sections, String message) {
    final keys = sections.toSet();
    if (keys.isEmpty) return;
    final nextErrors = Map<String, String>.from(sectionErrors);
    for (final key in keys) {
      nextErrors[key] = message;
    }
    sectionErrors = nextErrors;
    _safeNotify();
  }

  void _setSectionsIdle(Iterable<String> sections) {
    final keys = sections.toSet();
    if (keys.isEmpty) return;
    updatingSections.removeAll(keys);
    _safeNotify();
  }

  String errorMessageOf(Object rawError) {
    final text = rawError.toString().trim();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length).trim();
    }
    return text;
  }

  void _mergeSummary(DashboardMobileSummary payload) {
    if (payload.availableYears != null) {
      final previousYear = year;
      final previousQuarter = quarter;
      availableYears = List<int>.from(payload.availableYears!);
      if (year != null && !availableYears.contains(year)) {
        year = null;
        quarter = null;
      }
      if (previousYear != year || previousQuarter != quarter) {
        updateSharedFilter(year: year, quarter: quarter);
      }
    }

    if (payload.finance != null) {
      finance = payload.finance;
    }
    if (payload.collections != null) {
      collections = List<MonthlyCollectionPoint>.from(payload.collections!);
    }
    if (payload.statusCounts != null) {
      statusCounts = List<ProjectStatusCount>.from(payload.statusCounts!);
    }
    if (payload.summary != null) {
      summary = payload.summary;
    }
    if (payload.latestProjects != null) {
      latestProjects = List<ProjectSummary>.from(payload.latestProjects!);
    }

    final nextErrors = Map<String, String>.from(sectionErrors);
    for (final section in payload.sections) {
      nextErrors.remove(section);
    }
    nextErrors.addAll(payload.errors);
    sectionErrors = nextErrors;
  }

  Future<void> load({
    bool refreshYears = false,
    bool forceRefresh = false,
  }) async {
    _hasLoaded = true;
    _pendingReload = false;
    final requestTicket = ++_requestTicket;
    final initial = finance == null &&
        summary == null &&
        statusCounts.isEmpty &&
        collections.isEmpty &&
        latestProjects.isEmpty;

    error = null;
    if (initial) {
      loading = true;
      updating = false;
    } else {
      updating = true;
    }
    _safeNotify();

    final shouldUseYear = year != null &&
        (availableYears.isEmpty || availableYears.contains(year));
    final effectiveYear = shouldUseYear ? year : null;
    final effectiveQuarter = effectiveYear == null ? null : quarter;
    final range = computePeriodRange(
      year: effectiveYear,
      quarter: effectiveQuarter,
    );

    final primarySections = _primarySectionsForLoad(refreshYears: refreshYears);
    final heavySections = _heavySectionsForLoad();

    try {
      final summaryPayload = await _fetchSections(
        year: effectiveYear,
        range: range,
        sections: primarySections,
        cacheTtl: const Duration(seconds: 60),
        forceRefresh: forceRefresh,
      );
      if (!_canApplyRequest(requestTicket)) return;

      _mergeSummary(summaryPayload);
      year = effectiveYear;
      quarter = effectiveQuarter;
      loading = false;
      updating = false;
      _safeNotify();

      if (heavySections.isEmpty) return;
      _setSectionsLoading(heavySections);

      try {
        final heavySummary = await _fetchSections(
          year: effectiveYear,
          range: range,
          sections: heavySections,
          cacheTtl: const Duration(seconds: 45),
          forceRefresh: forceRefresh,
        );
        if (!_canApplyRequest(requestTicket)) return;
        _mergeSummary(heavySummary);
        _safeNotify();
      } catch (e) {
        if (!_canApplyRequest(requestTicket)) return;
        final message = errorMessageOf(e);
        _setSectionsError(heavySections, message);
      } finally {
        if (_canApplyRequest(requestTicket)) _setSectionsIdle(heavySections);
      }
    } catch (e) {
      if (!_canApplyRequest(requestTicket)) return;
      error = errorMessageOf(e);
      loading = false;
      updating = false;
      _safeNotify();
    }
  }

  Future<void> retrySections(List<String> sections) async {
    final target = sections.toSet();
    if (target.isEmpty) return;

    _setSectionsLoading(target);

    final range = computePeriodRange(year: year, quarter: quarter);

    try {
      final summaryPayload = await _fetchSections(
        year: year,
        range: range,
        sections: target.toList(),
        cacheTtl: const Duration(seconds: 20),
        forceRefresh: true,
      );
      if (_disposed) return;
      _mergeSummary(summaryPayload);
      _safeNotify();
    } catch (e) {
      if (_disposed) return;
      final message = errorMessageOf(e);
      _setSectionsError(target, message);
    } finally {
      if (!_disposed) _setSectionsIdle(target);
    }
  }

  String? combinedError(List<String> sections) {
    final messages = sections
        .map((k) => sectionErrors[k])
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    if (messages.isEmpty) return null;
    return messages.join('\n');
  }
}
