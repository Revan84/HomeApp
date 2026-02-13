import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        children: [
          const SizedBox(height: 14),

          _ProfileTile(
            icon: Icons.person_outline,
            title: context.l10n.profileAccountSecurity,
            onTap: null,
          ),
          const SizedBox(height: 15),

          _ProfileTile(
            icon: Icons.wifi_tethering,
            title: context.l10n.profileRemoteAccess,
            onTap: null,
          ),
          const SizedBox(height: 15),

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
          const SizedBox(height: 15),

          _ProfileTile(
            icon: Icons.palette_outlined,
            title: context.l10n.profileAppearance,
            onTap: null,
          ),
          const SizedBox(height: 15),

          _ProfileTile(
            icon: Icons.cloud_upload_outlined,
            title: context.l10n.profileBackupRestore,
            onTap: null,
          ),

          const SizedBox(height: 24),

          Center(
            child: FractionallySizedBox(
              widthFactor: 0.5, // 50% de la largeur dispo
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.logout, color: AppColors.danger),
                label: Text(context.l10n.profileLogout),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(
                    color: AppColors.danger.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
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
      borderRadius: BorderRadius.circular(25),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: AppColors.stroke.withValues(alpha: 0.75)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.success),
            const SizedBox(width: 12),

            // Titre
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
