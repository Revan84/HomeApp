/// Predefined time ranges for fetching metric data.
enum TimeRange { day1, week1, month1, year1, max }

extension TimeRangeX on TimeRange {
  /// Approximate duration for this time range.
  ///
  /// [max] returns a 10-year span as fallback; callers should clamp
  /// to the actual oldest available data point when appropriate.
  Duration get duration {
    switch (this) {
      case TimeRange.day1:
        return const Duration(days: 1);
      case TimeRange.week1:
        return const Duration(days: 7);
      case TimeRange.month1:
        return const Duration(days: 30);
      case TimeRange.year1:
        return const Duration(days: 365);
      case TimeRange.max:
        return const Duration(days: 3650);
    }
  }

  /// Short localized-friendly label (used as chip text).
  String get shortLabel {
    switch (this) {
      case TimeRange.day1:
        return '1D';
      case TimeRange.week1:
        return '1W';
      case TimeRange.month1:
        return '1M';
      case TimeRange.year1:
        return '1Y';
      case TimeRange.max:
        return 'MAX';
    }
  }
}
