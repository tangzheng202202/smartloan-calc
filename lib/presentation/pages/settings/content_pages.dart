import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// 通用静态内容页骨架
class _ContentPage extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _ContentPage({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.7)),
        ],
      ),
    );
  }
}

/// 关于页
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _ContentPage(
      title: l10n.aboutButton,
      body: '${l10n.aboutContent}\n\n${l10n.versionLabel}',
      icon: Icons.calculate_outlined,
    );
  }
}

/// 隐私政策页
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _ContentPage(
      title: l10n.privacyButton,
      body: l10n.privacyContent,
      icon: Icons.privacy_tip_outlined,
    );
  }
}

/// 免责声明页
class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _ContentPage(
      title: l10n.disclaimerButton,
      body: l10n.disclaimerContent,
      icon: Icons.gavel_outlined,
    );
  }
}
