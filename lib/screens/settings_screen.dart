import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.card : AppColors.lightSurface;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightMuted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personalize', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 10),
                _SettingsTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Reminders',
                  subtitle: 'Daily notifications and schedules',
                  mutedColor: mutedColor,
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  icon: Icons.color_lens_rounded,
                  title: 'Appearance',
                  subtitle: 'System theme with accent colors',
                  mutedColor: mutedColor,
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 10),
                _SettingsTile(
                  icon: Icons.info_rounded,
                  title: 'Version',
                  subtitle: '1.0.0',
                  mutedColor: mutedColor,
                  onTap: () => _showVersion(context),
                ),
                _SettingsTile(
                  icon: Icons.help_rounded,
                  title: 'Support',
                  subtitle: 'Get help and share feedback',
                  mutedColor: mutedColor,
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color mutedColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.mutedColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedColor),
      ),
      onTap: onTap,
    );
  }
}

void _showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Coming soon.')),
  );
}

void _showVersion(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Streaks Tracker v1.0.0')),
  );
}
