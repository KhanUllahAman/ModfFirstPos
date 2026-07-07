import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/profile/controller/get_profile_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

class GetProfileView extends GetView<GetProfileController> {
  const GetProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(showMenuIcon: true, onMenuPressed: () => Get.back()),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Padding(
          padding: EdgeInsets.all(context.responsiveWidth(0.03)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BackBar(title: "Profile"),
              SizedBox(height: context.spacingLG),
              Expanded(
                child: Obx(() {
                  final profile = controller.profile.value;

                  if (controller.isLoading.value && profile == null) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: ColorResources.appMainColor,
                      ),
                    );
                  }

                  if (profile == null) {
                    return Center(
                      child: Text(
                        'Profile Load Error',
                        style: GoogleFonts.geistMono(
                          fontSize: context.fontSM,
                          fontWeight: FontWeight.w500,
                          color: ColorResources.blackColor,
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(context.spacingLG),
                            decoration: BoxDecoration(
                              color: ColorResources.whiteColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFE7E9F0),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: CircleAvatar(
                                    radius: context.responsiveWidth(0.09),
                                    backgroundColor:
                                        ColorResources.appMainColor.withOpacity(0.1),
                                    backgroundImage: (profile.imageUrl != null &&
                                            profile.imageUrl!.isNotEmpty)
                                        ? NetworkImage(profile.imageUrl!)
                                        : null,
                                    child: (profile.imageUrl == null ||
                                            profile.imageUrl!.isEmpty)
                                        ? Icon(
                                            Icons.person,
                                            size: context.responsiveWidth(0.09),
                                            color: ColorResources.appMainColor,
                                          )
                                        : null,
                                  ),
                                ),
                                SizedBox(height: context.spacingSM),
                                Center(
                                  child: Text(
                                    profile.fullName ?? '-',
                                    style: GoogleFonts.geistMono(
                                      fontSize: context.fontLG,
                                      fontWeight: FontWeight.w600,
                                      color: ColorResources.blackColor,
                                    ),
                                  ),
                                ),
                                if (profile.role != null) ...[
                                  SizedBox(height: context.spacingXS / 2),
                                  Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: context.spacingSM,
                                        vertical: context.spacingXS / 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ColorResources.appMainColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        profile.role!,
                                        style: GoogleFonts.geistMono(
                                          fontSize: context.fontXS,
                                          fontWeight: FontWeight.w500,
                                          color: ColorResources.appMainColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                SizedBox(height: context.spacingXL),
                                _ProfileInfoRow(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  value: profile.phone ?? '-',
                                ),
                                _ProfileInfoRow(
                                  icon: Icons.badge_outlined,
                                  label: 'Admin',
                                  value: profile.isAdmin == true ? 'Yes' : 'No',
                                ),
                                _ProfileInfoRow(
                                  icon: Icons.toggle_on_outlined,
                                  label: 'Active',
                                  value: profile.isActive == true ? 'Yes' : 'No',
                                ),
                                _ProfileInfoRow(
                                  icon: Icons.lock_outline,
                                  label: 'PIN Enabled',
                                  value: profile.pinEnabled == true ? 'Yes' : 'No',
                                ),
                                if (profile.autoLockMinutes != null)
                                  _ProfileInfoRow(
                                    icon: Icons.timer_outlined,
                                    label: 'Auto Lock',
                                    value: '${profile.autoLockMinutes} min',
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.spacingLG),
                          AppButton(
                            backgroundColor: ColorResources.mainbuttonColor,
                            onPressed: controller.goToUpdateProfile,
                            isLoading: false,
                            borderRadius: 12,
                            child: Text(
                              'Update Your Profile',
                              style: GoogleFonts.geistMono(
                                fontSize: context.fontMD,
                                fontWeight: FontWeight.w500,
                                color: ColorResources.blackColor,
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacingXS),
      child: Row(
        children: [
          Icon(icon, size: context.fontMD, color: ColorResources.appMainColor),
          SizedBox(width: context.spacingSM),
          Text(
            label,
            style: GoogleFonts.geistMono(
              fontSize: context.fontXS,
              fontWeight: FontWeight.w400,
              color: ColorResources.blackColor.withOpacity(0.55),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.geistMono(
              fontSize: context.fontXS,
              fontWeight: FontWeight.w600,
              color: ColorResources.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}