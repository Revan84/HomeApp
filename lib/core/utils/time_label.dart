import 'package:flutter/widgets.dart';
import '../i18n/loc.dart';

String ageLabel(BuildContext context, DateTime? time) {
  if (time == null) return '';

  final duration = DateTime.now().difference(time);

  if (duration.inSeconds < 10) {
    return context.l10n.updatedJustNow;
  }

  if (duration.inMinutes < 1) {
    return context.l10n.updatedSecondsAgo(duration.inSeconds);
  }

  if (duration.inHours < 1) {
    return context.l10n.updatedMinutesAgo(duration.inMinutes);
  }

  return context.l10n.updatedHoursAgo(duration.inHours);
}