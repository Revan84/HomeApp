enum HistoryWindow {
  d1,
  w1,
  m1,
  y1,
  max,
}

extension HistoryWindowX on HistoryWindow {
  /// Computes the visible start date for the selected history range.
  ///
  /// `max` uses the oldest available point when possible.
  DateTime startDate({
    required DateTime end,
    DateTime? oldestPointAt,
  }) {
    switch (this) {
      case HistoryWindow.d1:
        return end.subtract(const Duration(days: 1));

      case HistoryWindow.w1:
        return end.subtract(const Duration(days: 7));

      case HistoryWindow.m1:
        return DateTime(
          end.year,
          end.month - 1,
          end.day,
          end.hour,
          end.minute,
          end.second,
          end.millisecond,
          end.microsecond,
        );

      case HistoryWindow.y1:
        return DateTime(
          end.year - 1,
          end.month,
          end.day,
          end.hour,
          end.minute,
          end.second,
          end.millisecond,
          end.microsecond,
        );

      case HistoryWindow.max:
        return oldestPointAt ?? end.subtract(const Duration(days: 30));
    }
  }
}