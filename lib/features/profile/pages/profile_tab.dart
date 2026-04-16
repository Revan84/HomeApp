import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/design_system/buttons/app_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/i18n/locale_controller.dart';

import 'language_page.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCtl = context.watch<LocaleController>();
    final langCode = localeCtl.locale?.languageCode ?? 'fr';

    final langLabel = (langCode == 'en')
        ? context.l10n.languageEnglish
        : context.l10n.languageFrench;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x3l,
          AppSpacing.x2l,
          AppSpacing.x3l,
          100,
        ),
        children: [
          AppSpacing.gapX2l,

          _ProfileTile(
            icon: Icons.person_outline,
            title: context.l10n.profileAccountSecurity,
            onTap: null,
          ),
          AppSpacing.gapX3l,

          _ProfileTile(
            icon: Icons.wifi_tethering,
            title: context.l10n.profileRemoteAccess,
            onTap: null,
          ),
          AppSpacing.gapX3l,

          _ProfileTile(
            icon: Icons.translate,
            title: context.l10n.profileLanguage,
            subtitle: langLabel,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LanguagePage()));
            },
          ),
          AppSpacing.gapX3l,

          _ProfileTile(
            icon: Icons.palette_outlined,
            title: context.l10n.profileAppearance,
            onTap: null,
          ),
          AppSpacing.gapX3l,

          _ProfileTile(
            icon: Icons.cloud_upload_outlined,
            title: context.l10n.profileBackupRestore,
            onTap: null,
          ),

          AppSpacing.gapX6l,

          Center(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: AppButton(
                label: context.l10n.profileLogout,
                leading: Icons.logout,
                variant: AppButtonVariant.danger,
                fullWidth: true,
                onPressed: null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.x4lBR,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2l,
          vertical: AppSpacing.x2l,
        ),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: AppRadius.x4lBR,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            AppSpacing.gapHXl,

            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ),

            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}
