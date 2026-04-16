import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../controllers/home_controller.dart';
import '../../domain/today_widget_type.dart';

/// Bottom sheet to manage which Today widgets are visible and to set the kWh price.
class TodayManageSheet extends StatefulWidget {
  const TodayManageSheet({super.key});

  @override
  State<TodayManageSheet> createState() => _TodayManageSheetState();
}

class _TodayManageSheetState extends State<TodayManageSheet> {
  late Set<TodayWidgetType> _selected;
  late final TextEditingController _priceCtl;

  @override
  void initState() {
    super.initState();
    final ctl = context.read<HomeController>();
    _selected = Set.from(ctl.visibleTodayWidgets);
    _priceCtl = TextEditingController(
      text: ctl.kwhPrice.toStringAsFixed(3),
    );
  }

  @override
  void dispose() {
    _priceCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ctl = context.read<HomeController>();
    final price = double.tryParse(_priceCtl.text.replaceAll(',', '.'));
    if (price != null && price > 0) {
      await ctl.setKwhPrice(price);
    }
    await ctl.setVisibleTodayWidgets(_selected.toList());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Today Widgets',
                  style: TextStyle(
                    fontFamily: 'ShareTech',
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSizes.sectionTitle,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            AppSpacing.gapX3l,

            // Widget toggles
            ...TodayWidgetType.values.map((type) {
              final active = _selected.contains(type);
              return _ToggleRow(
                label: type.displayName,
                value: active,
                onChanged: (v) {
                  setState(() {
                    if (v) {
                      _selected.add(type);
                    } else {
                      _selected.remove(type);
                    }
                  });
                },
              );
            }),

            AppSpacing.gapX3l,
            const Divider(color: AppColors.border),
            AppSpacing.gapXl,

            // kWh price field
            const Text(
              'Electricity price (€/kWh)',
              style: TextStyle(
                fontFamily: 'ShareTech',
                color: AppColors.textSecondary,
                fontSize: AppFontSizes.body,
              ),
            ),
            AppSpacing.gapSm,
            TextField(
              controller: _priceCtl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              style: const TextStyle(
                fontFamily: 'ShareTech',
                color: AppColors.textPrimary,
                fontSize: AppFontSizes.lg,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.bg,
                suffixText: '€/kWh',
                suffixStyle: const TextStyle(
                  fontFamily: 'ShareTech',
                  color: AppColors.textSecondary,
                  fontSize: AppFontSizes.body,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.xlBR,
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.xlBR,
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.xlBR,
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),

            AppSpacing.gapX5l,
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.xlBR,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _save,
                child: const Text(
                  'Save',
                  style: TextStyle(fontFamily: 'ShareTech', fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'ShareTech',
              color: AppColors.textPrimary,
              fontSize: AppFontSizes.md,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
