import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/profile/controller/update_profile_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

class UpdateProfileView extends GetView<UpdateProfileController> {
  const UpdateProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(showMenuIcon: true, onMenuPressed: () => Get.back()),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.responsiveWidth(0.03)),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BackBar(title: "Update Profile"),
                  SizedBox(height: context.spacingLG),
                  Center(child: _AvatarPicker(context: context)),
                  SizedBox(height: context.spacingLG),
                  CustomTextFormField(
                    customFocusedBorderColor: ColorResources.blackColor,
                    customEnabledBorderColor: ColorResources.blackColor,
                    controller: controller.fullNameController,
                    labelText: "Full Name",
                    hintText: "Enter your full name",
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Full name is required";
                      }
                      if (value.trim().length < 3) {
                        return "Full name is too short";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.spacingMD),
                  CustomTextFormField(
                    customFocusedBorderColor: ColorResources.blackColor,
                    customEnabledBorderColor: ColorResources.blackColor,
                    controller: controller.phoneController,
                    labelText: "Phone Number",
                    hintText: "Enter your phone number",
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Phone number is required";
                      }
                      if (value.trim().length < 10) {
                        return "Enter a valid phone number";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.spacingXL),
                  Obx(
                    () => AppButton(
                      backgroundColor: theme.secondaryColor.value,
                      onPressed:
                          controller.isLoading.value ||
                              controller.isUploadingImage.value
                          ? () {}
                          : controller.updateProfile,
                      isLoading:
                          controller.isLoading.value ||
                          controller.isUploadingImage.value,
                      borderRadius: 12,
                      child: Text(
                        controller.isUploadingImage.value
                            ? "Uploading image..."
                            : controller.isLoading.value
                            ? "Updating..."
                            : "Update Profile",
                        style: AppFonts.geistMono(
                          fontSize: context.fontSM,
                          fontWeight: FontWeight.w500,
                          color: theme.onSecondaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.spacingMD),
                ],
              ),
            ),
          ),
        ),
      ),
    ).noKeyboard();
  }
}

class _AvatarPicker extends StatelessWidget {
  final BuildContext context;

  const _AvatarPicker({required this.context});

  UpdateProfileController get controller => Get.find<UpdateProfileController>();

  @override
  Widget build(BuildContext _) {
    final theme = Get.find<AppThemeService>();
    final avatarRadius = context.responsiveWidth(0.14);

    return GestureDetector(
      onTap: () => _showImageSourceSheet(context),
      child: Obx(() {
        final file = controller.selectedImage.value;
        final url = controller.displayImageUrl;

        ImageProvider? imageProvider;
        if (file != null) {
          imageProvider = FileImage(file);
        } else if (url.isNotEmpty) {
          imageProvider = NetworkImage(url);
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: ColorResources.labelBorderColor.withAlpha(60),
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Icon(
                      Iconsax.user,
                      size: avatarRadius,
                      color: theme.onSecondaryColor.withOpacity(0.5),
                    )
                  : null,
            ),
            Positioned(
              bottom: 10,
              right: 50,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.secondaryColor.value,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.onSecondaryColor,
                    width: 2,
                  ),
                ),
                child:  Icon(
                  Iconsax.camera,
                  size: 16,
                  color: theme.onSecondaryColor,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Image Source",
              style: AppFonts.geistMono(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ColorResources.labelColor,
              ),
            ),
            SizedBox(height: context.spacingMD),
            ListTile(
              leading: const Icon(Iconsax.camera),
              title: const Text("Camera"),
              onTap: () {
                Get.back();
                controller.pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery),
              title: const Text("Gallery"),
              onTap: () {
                Get.back();
                controller.pickImageFromGallery();
              },
            ),
            Obx(
              () => controller.selectedImage.value != null
                  ? ListTile(
                      leading: const Icon(Iconsax.trash, color: Colors.red),
                      title: const Text(
                        "Remove selected image",
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        Get.back();
                        controller.removeSelectedImage();
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
