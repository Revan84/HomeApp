import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';

enum AppLang { fr, en }

extension on AppLang {
  Locale get locale => switch (this) {
    AppLang.fr => const Locale('fr'),
    AppLang.en => const Locale('en'),
  };
}

AppLang _langFromLocale(Locale? l) {
  final code = (l?.languageCode ?? 'fr').toLowerCase();
  return code == 'en' ? AppLang.en : AppLang.fr;
}

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCtl = context.watch<LocaleController>();
    final selected = _langFromLocale(localeCtl.locale);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileLanguage)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              width: 1,
              color: AppColors.stroke.withValues(alpha: 0.75),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: RadioGroup<AppLang>(
              groupValue: selected,
              onChanged: (v) {
                if (v == null) return;
                context.read<LocaleController>().setLocale(v.locale);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<AppLang>(
                    value: AppLang.fr,
                    title: Text(context.l10n.languageFrench),
                  ),
                  const Divider(height: 1),
                  RadioListTile<AppLang>(
                    value: AppLang.en,
                    title: Text(context.l10n.languageEnglish),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
