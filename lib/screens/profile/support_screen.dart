import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $urlString'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('$label copied!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.of(context).primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.headlineLarge?.color ??
        AppColors.of(context).textColor;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ??
        AppColors.of(context).textSecondary;
    final primaryColor = AppColors.of(context).primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Support',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reassuring Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: GlassDecoration(context: context),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.headset_mic_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need help? Reach out directly for order or payment issues.',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Fast, personal support for key activation, account verification, and transaction assistance.',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Community & Instant Messaging Section
              _buildSectionTitle(context, 'Community & Instant Messaging'),
              const SizedBox(height: 12),

              // Discord Server (Community Help)
              _buildActionCard(
                context: context,
                icon: Icons.forum_rounded,
                iconColor: const Color(0xFF5865F2),
                title: 'Discord Server',
                subtitle: 'Community help, discussions & store updates',
                actionType: _ActionType.link,
                onTap: () => _launchUrl(context, 'https://discord.gg/2FPuePXem'),
              ),

              const SizedBox(height: 10),

              // Telegram (Direct Messaging)
              _buildActionCard(
                context: context,
                icon: Icons.send_rounded,
                iconColor: const Color(0xFF229ED9),
                title: 'Telegram',
                subtitle: 'Direct messaging with @DasIstNowrid',
                actionType: _ActionType.link,
                onTap: () => _launchUrl(context, 'https://t.me/DasIstNowrid'),
              ),

              const SizedBox(height: 28),

              // Direct Contact Section
              _buildSectionTitle(context, 'Direct Contact & Copy'),
              const SizedBox(height: 12),

              // Discord DM (nowridtheowl)
              _buildActionCard(
                context: context,
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: const Color(0xFF5865F2),
                title: 'Discord DM',
                subtitle: 'nowridtheowl (tap to copy)',
                actionType: _ActionType.copy,
                onTap: () =>
                    _copyToClipboard(context, 'nowridtheowl', 'Discord username'),
              ),

              const SizedBox(height: 10),

              // Email (nisdigitalstore@gmail.com)
              _buildActionCard(
                context: context,
                icon: Icons.mail_outline_rounded,
                iconColor: const Color(0xFFEA4335),
                title: 'Email',
                subtitle: 'nisdigitalstore@gmail.com (tap to copy)',
                actionType: _ActionType.copy,
                onTap: () => _copyToClipboard(
                    context, 'nisdigitalstore@gmail.com', 'Email address'),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.of(context).textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required _ActionType actionType,
    required VoidCallback onTap,
  }) {
    final textColor = Theme.of(context).textTheme.headlineLarge?.color ??
        AppColors.of(context).textColor;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ??
        AppColors.of(context).textSecondary;

    return Container(
      decoration: GlassDecoration(context: context),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: actionType == _ActionType.copy
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.copy_rounded,
                    color: AppColors.of(context).primary,
                    size: 16,
                  ),
                )
              : Icon(
                  Icons.open_in_new_rounded,
                  color: AppColors.of(context).textSecondary,
                  size: 18,
                ),
        ),
      ),
    );
  }
}

enum _ActionType {
  link,
  copy,
}
