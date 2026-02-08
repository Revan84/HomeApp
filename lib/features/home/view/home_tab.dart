import 'package:flutter/material.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/area_card.dart';
import '../../../core/widgets/favorite_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          children: [
            // Favoris
            SectionHeader(title: AppStrings.favorites),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  FavoriteCard(
                    value: '21 °C',
                    label: 'Thermomètre',
                    room: 'Salon',
                    icon: Icons.wb_sunny_outlined,
                    isOn: false,
                  ),
                  SizedBox(width: 12),
                  FavoriteCard(
                    value: '64 %',
                    label: 'Hygromètre',
                    room: 'Salon',
                    icon: Icons.water_drop_outlined,
                    isOn: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Areas
            SectionHeader(title: AppStrings.areas),
            const SizedBox(height: 10),
            const AreaCard(title: 'Salon'),
            const SizedBox(height: 12),
            const AreaCard(title: 'Cuisine'),

            const SizedBox(height: 14),
            Center(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.stroke.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {},
                child: const Text('See all'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}