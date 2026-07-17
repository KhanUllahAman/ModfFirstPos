import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/profile/controller/get_profile_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

import 'package:modfirstpos/shared/widgets/sideNav/app_nav_drawer.dart';

class GetProfileView extends GetView<GetProfileController> {
  const GetProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(),
      drawer: const AppNavDrawer(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.responsiveWidth(0.03)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BackBar(title: "Profile"),
                    SizedBox(height: context.spacingMD),
              Expanded(
                child: Obx(() {
                  final profile = controller.profile.value;

                  if (controller.isLoading.value && profile == null) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.primaryColor.value,
                      ),
                    );
                  }

                  if (profile == null) {
                    return Center(
                      child: Text(
                        'Profile Load Error',
                        style: AppFonts.geistMono(
                          fontSize: context.fontSM,
                          fontWeight: FontWeight.w500,
                          color: theme.onPrimaryColor.withOpacity(0.85),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    primary: false,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(context.spacingMD),
                            decoration: BoxDecoration(
                              color: ColorResources.whiteColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE7E9F0),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar + Name row
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: context.responsiveWidth(0.07),
                                      backgroundColor: theme.primaryColor.value.withOpacity(0.1),
                                      backgroundImage:
                                          (profile.imageUrl != null &&
                                              profile.imageUrl!.isNotEmpty)
                                          ? NetworkImage(profile.fullImageUrl!)
                                          : null,
                                      child:
                                          (profile.imageUrl == null ||
                                              profile.imageUrl!.isEmpty)
                                          ? Icon(
                                              Icons.person,
                                              size: context.responsiveWidth(
                                                0.07,
                                              ),
                                              color:
                                                  theme.primaryColor.value,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: context.spacingSM),
                                    Expanded(
                                      child: Text(
                                        profile.fullName ?? '-',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFonts.geistMono(
                                          fontSize: context.fontMD,
                                          fontWeight: FontWeight.w600,
                                          color: ColorResources.blackColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: context.spacingSM),
                                Divider(
                                  height: 1,
                                  color: const Color(0xFFE7E9F0),
                                ),
                                SizedBox(height: context.spacingXS),
                                _ProfileInfoRow(
                                  icon: Icons.person_outline,
                                  label: 'Full Name',
                                  value: profile.fullName ?? '-',
                                ),
                                _ProfileInfoRow(
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  value: profile.email ?? '-',
                                ),
                                _ProfileInfoRow(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  value: profile.phone ?? '-',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.spacingMD),
                          AppButton(
                            backgroundColor: theme.secondaryColor.value,
                            onPressed: controller.goToUpdateProfile,
                            isLoading: false,
                            borderRadius: 12,
                            child: Text(
                              'Update Your Profile',
                              style: AppFonts.geistMono(
                                fontSize: context.fontSM,
                                fontWeight: FontWeight.w500,
                                color: theme.onSecondaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),
    ).noKeyboard();
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacingXS / 1.5),
      child: Row(
        children: [
          Icon(icon, size: context.fontSM, color: theme.secondaryColor.value),
          SizedBox(width: context.spacingSM),
          Text(
            label,
            style: AppFonts.geistMono(
              fontSize: context.fontXS,
              fontWeight: FontWeight.w400,
              color: ColorResources.blackColor.withOpacity(0.55),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.geistMono(
                fontSize: context.fontXS,
                fontWeight: FontWeight.w600,
                color: ColorResources.blackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
