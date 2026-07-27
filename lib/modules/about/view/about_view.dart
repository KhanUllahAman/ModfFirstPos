import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/about/controller/about_controller.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  Future<void> _openUrl(String url) async {
    if (url.trim().isEmpty) return;
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      if (!launched) {
        customSnackBar(
          'Error',
          'Could not open link',
          snackBarType: SnackBarType.error,
        );
      }
    } catch (_) {
      customSnackBar(
        'Error',
        'Could not open link',
        snackBarType: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(showMenuIcon: false, showBackIcon: true),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.secondaryColor.value,
              ),
            );
          }

          return ListView(
            primary: false,
            padding: EdgeInsets.all(context.spacingMD),
            children: [
              _HeaderCard(controller: controller, theme: theme),
              SizedBox(height: context.spacingMD),

              if (controller.siteDescription.value.isNotEmpty)
                _SectionCard(
                  title: 'About',
                  children: [
                    Text(
                      controller.siteDescription.value,
                      style: AppFonts.geistMono(
                        fontSize: context.fontSM,
                        color: ColorResources.labelColor.withOpacity(0.75),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),

              SizedBox(height: context.spacingMD),
              _SectionCard(
                title: 'Contact',
                children: [
                  if (controller.contactEmail.value.isNotEmpty)
                    _InfoRow(
                      icon: Icons.email_rounded,
                      label: 'Email',
                      value: controller.contactEmail.value,
                    ),
                  if (controller.supportEmail.value.isNotEmpty)
                    _InfoRow(
                      icon: Icons.support_agent_rounded,
                      label: 'Support',
                      value: controller.supportEmail.value,
                    ),
                  if (controller.contactPhone.value.isNotEmpty)
                    _InfoRow(
                      icon: Icons.phone_rounded,
                      label: 'Phone',
                      value: controller.contactPhone.value,
                    ),
                  if (controller.whatsappNumber.value.isNotEmpty)
                    _InfoRow(
                      icon: Icons.chat_rounded,
                      label: 'WhatsApp',
                      value: controller.whatsappNumber.value,
                    ),
                ],
              ),

              SizedBox(height: context.spacingMD),
              _SectionCard(
                title: 'Location',
                children: [
                  if (controller.address.value.isNotEmpty)
                    _InfoRow(
                      icon: Icons.location_on_rounded,
                      label: 'Address',
                      value: controller.address.value,
                    ),
                  if (controller.city.value.isNotEmpty ||
                      controller.provinceCode.value.isNotEmpty)
                    _InfoRow(
                      icon: Icons.map_rounded,
                      label: 'City',
                      value: [
                        controller.city.value,
                        controller.provinceCode.value,
                        controller.postalCode.value,
                      ].where((e) => e.isNotEmpty).join(', '),
                    ),
                  if (controller.countryCode.value.isNotEmpty)
                    _InfoRow(
                      icon: Icons.public_rounded,
                      label: 'Country',
                      value: controller.countryCode.value,
                    ),
                  if (controller.businessHours.value.isNotEmpty)
                    _InfoRow(
                      icon: Icons.schedule_rounded,
                      label: 'Hours',
                      value: controller.businessHours.value,
                    ),
                ],
              ),

              SizedBox(height: context.spacingMD),
              _SectionCard(
                title: 'Store Info',
                children: [
                  if (controller.currency.value.isNotEmpty)
                    _InfoRow(
                      icon: Icons.attach_money_rounded,
                      label: 'Currency',
                      value:
                          '${controller.currency.value} (${controller.currencySymbol.value})',
                    ),
                ],
              ),

              if (_hasAnySocialLink(controller)) ...[
                SizedBox(height: context.spacingMD),
                _SectionCard(
                  title: 'Follow Us',
                  children: [
                    _SocialLinksRow(controller: controller, onTap: _openUrl),
                  ],
                ),
              ],

              SizedBox(height: context.spacingMD),
              _SectionCard(
                title: 'App Info',
                children: [
                  _InfoRow(
                    icon: Icons.info_rounded,
                    label: 'Version',
                    value: controller.appVersion.value,
                  ),
                  _InfoRow(
                    icon: Icons.perm_device_information_rounded,
                    label: 'Device ID',
                    value: controller.deviceId.value,
                  ),
                ],
              ),

              SizedBox(height: context.spacingLG),
            ],
          );
        }),
      ),
    );
  }

  bool _hasAnySocialLink(AboutController c) {
    return c.facebookUrl.value.isNotEmpty ||
        c.instagramUrl.value.isNotEmpty ||
        c.twitterUrl.value.isNotEmpty ||
        c.tiktokUrl.value.isNotEmpty ||
        c.linkedinUrl.value.isNotEmpty ||
        c.youtubeUrl.value.isNotEmpty ||
        c.pinterestUrl.value.isNotEmpty;
  }
}

class _HeaderCard extends StatelessWidget {
  final AboutController controller;
  final AppThemeService theme;
  const _HeaderCard({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: context.spacingMD,
          vertical: context.spacingLG,
        ),
        decoration: BoxDecoration(
          color: theme.primaryColor.value,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              controller.siteName.value,
              style: AppFonts.geistMono(
                fontSize: context.fontLG,
                fontWeight: FontWeight.w700,
                color: theme.onPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (controller.siteTagline.value.isNotEmpty) ...[
              SizedBox(height: context.spacingXS),
              Text(
                controller.siteTagline.value,
                style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  color: theme.onPrimaryColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: context.spacingXS),
          child: Text(
            title.toUpperCase(),
            style: AppFonts.geistMono(
              fontSize: context.fontXS,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: const Color(0xFF9AA1B0),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.spacingMD),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7E9F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Icon(icon, size: 18, color: theme.secondaryColor.value)),
          SizedBox(width: context.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.geistMono(
                    fontSize: context.fontXS - 1,
                    color: const Color(0xFF9AA1B0),
                  ),
                ),
                Text(
                  value,
                  style: AppFonts.geistMono(
                    fontSize: context.fontSM,
                    fontWeight: FontWeight.w600,
                    color: ColorResources.labelColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLinksRow extends StatelessWidget {
  final AboutController controller;
  final Future<void> Function(String url) onTap;
  const _SocialLinksRow({required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final links = <(IconData, String)>[
      if (controller.facebookUrl.value.isNotEmpty)
        (Icons.facebook_rounded, controller.facebookUrl.value),
      if (controller.instagramUrl.value.isNotEmpty)
        (Icons.camera_alt_rounded, controller.instagramUrl.value),
      if (controller.twitterUrl.value.isNotEmpty)
        (Icons.alternate_email_rounded, controller.twitterUrl.value),
      if (controller.tiktokUrl.value.isNotEmpty)
        (Icons.music_note_rounded, controller.tiktokUrl.value),
      if (controller.linkedinUrl.value.isNotEmpty)
        (Icons.business_center_rounded, controller.linkedinUrl.value),
      if (controller.youtubeUrl.value.isNotEmpty)
        (Icons.play_circle_fill_rounded, controller.youtubeUrl.value),
      if (controller.pinterestUrl.value.isNotEmpty)
        (Icons.push_pin_rounded, controller.pinterestUrl.value),
    ];

    final theme = Get.find<AppThemeService>();

    return Obx(
      () => Wrap(
        spacing: context.spacingSM,
        runSpacing: context.spacingSM,
        children: links.map((entry) {
          final (icon, url) = entry;
          return GestureDetector(
            onTap: () => onTap(url),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.secondaryColor.value.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.secondaryColor.value, size: 20),
            ),
          );
        }).toList(),
      ),
    );
  }
}
