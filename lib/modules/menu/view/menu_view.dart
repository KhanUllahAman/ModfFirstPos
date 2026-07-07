import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/modules/menu/widget/menu_widget.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/AppWidgets/appinfo_dailog_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/helperFunction/get_device_id_function.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(showMenuIcon: false, showBackIcon: true),
      body: Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: WidgetStateProperty.all(true),
            trackVisibility: WidgetStateProperty.all(true),
            thickness: WidgetStateProperty.all(5),
            radius: const Radius.circular(8),
            thumbColor: WidgetStateProperty.all(ColorResources.thumbColor),
            trackColor: WidgetStateProperty.all(const Color(0xffE6E8EC)),
            trackBorderColor: WidgetStateProperty.all(Colors.transparent),
            crossAxisMargin: 2,
            mainAxisMargin: 4,
            minThumbLength: 40,
            interactive: true,
          ),
        ),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.responsiveWidth(0.02)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Main Menu",
                          style: GoogleFonts.geistMono(
                            fontSize: context.fontMD,
                            fontWeight: FontWeight.w700,
                            color: ColorResources.labelColor,
                          ),
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.catalogueSvg,
                          menuTitle: 'Catalogue',
                          menuColor: MenuTileColor.blue,
                          menuTap: () {
                            Get.toNamed(Routes.catalogue);
                          },
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.orderSvg,
                          menuTitle: 'Orders',
                          menuColor: MenuTileColor.blue,
                          menuTap: () {
                            // Get.toNamed(Routes.order);
                          },
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.searchSvg,
                          menuTitle: 'Search',
                          menuColor: MenuTileColor.blue,
                          menuTap: () {
                            // Get.toNamed(Routes.searchSku);
                          },
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.itemReturnSvg,
                          menuTitle: 'Item Return',
                          menuColor: MenuTileColor.blue,
                          menuTap: () {},
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.receviedOnAmountSvg,
                          menuTitle: 'Received on Account',
                          menuColor: MenuTileColor.blue,
                          menuTap: () {
                            AppDialog.showSearchList(
                              context,
                              title: "Received On Account",
                              items: [
                                AppDialogListItem(
                                  id: "6-18-1",
                                  name: "Shaukat Ali",
                                  trailing: "Rs. 0",
                                ),
                                AppDialogListItem(
                                  id: "6-18-1",
                                  name: "Saleem Iqbal",
                                  trailing: "Rs. 0",
                                ),
                              ],
                              onItemTap: (item) => print(item.name),
                            );
                          },
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        // MenuList(
                        //   menuSvg: ImagesConstant.createGiftVoucherSvg,
                        //   menuTitle: 'Create Gift Voucher',
                        //   menuColor: MenuTileColor.blue,
                        //   menuTap: () {
                        //     AppDialog.showInput(
                        //       context,
                        //       title: "Create Gift Voucher",
                        //       inputLabel: "Enter Amount",
                        //       onConfirm: (val) => log(val),
                        //     );
                        //   },
                        // ),
                        // SizedBox(height: context.responsiveHeight(0.012)),
                        // MenuList(
                        //   menuSvg: ImagesConstant.creditVoucherRefundSvg,
                        //   menuTitle: 'Credit Voucher Refund',
                        //   menuColor: MenuTileColor.blue,
                        //   menuTap: () {
                        //     AppDialog.showInput(
                        //       context,
                        //       title: "Credit Voucher Refund",
                        //       inputLabel: "Enter Voucher Number",
                        //       onConfirm: (val) => log(val),
                        //     );
                        //   },
                        // ),
                        // SizedBox(height: context.responsiveHeight(0.012)),
                        // MenuList(
                        //   menuSvg: ImagesConstant.printReceiptSvg,
                        //   menuTitle: 'Print Receipt',
                        //   menuColor: MenuTileColor.blue,
                        //   menuTap: () {},
                        // ),
                        // SizedBox(height: context.responsiveHeight(0.012)),
                        // MenuList(
                        //   menuSvg: ImagesConstant.duplicateReceiptSvg,
                        //   menuTitle: 'Duplicate Receipt',
                        //   menuColor: MenuTileColor.blue,
                        //   menuTap: () {
                        //     AppDialog.showRadioList(
                        //       context,
                        //       title: "Duplicate Receipt",
                        //       options: [
                        //         AppDialogOption(
                        //           label: "Gift Receipt",
                        //           value: "gift",
                        //         ),
                        //         AppDialogOption(
                        //           label: "Last Receipt",
                        //           value: "last",
                        //         ),
                        //         AppDialogOption(
                        //           label: "Last Credit Voucher",
                        //           value: "credit",
                        //         ),
                        //         AppDialogOption(
                        //           label: "Last Gift Voucher",
                        //           value: "gift_voucher",
                        //         ),
                        //       ],
                        //       onConfirm: (val) => log(val),
                        //     );
                        //   },
                        // ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.expenseSvg,
                          menuTitle: 'Expense',
                          menuColor: MenuTileColor.blue,
                          menuTap: () {
                            AppDialog.showInput(
                              context,
                              title: "Credit Voucher Refund",
                              inputLabel: "Enter Voucher Number",
                              onConfirm: (val) => log(val),
                            );
                          },
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.expenseSvg,
                          menuTitle: 'Notification',
                          menuColor: MenuTileColor.blue,
                          menuTap: () {
                            // Get.toNamed(Routes.notification);
                          },
                        ),
                        SizedBox(height: context.responsiveHeight(0.02)),
                        MenuList(
                          menuSvg: ImagesConstant.expenseSvg,
                          menuTitle: 'Profile',
                          menuColor: MenuTileColor.blue,
                          menuTap: () {
                            Get.toNamed(Routes.profile);
                          },
                        ),
                        SizedBox(height: context.responsiveHeight(0.02)),
                        Text(
                          "Sub Menu",
                          style: GoogleFonts.geistMono(
                            fontSize: context.fontMD,
                            fontWeight: FontWeight.w600,
                            color: ColorResources.labelColor,
                          ),
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.xReportSvg,
                          menuTitle: 'X Report',
                          menuColor: MenuTileColor.red,
                          menuTap: () {},
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.settingsSvg,
                          menuTitle: 'Setting',
                          menuColor: MenuTileColor.red,
                          menuTap: () {
                            Get.toNamed(Routes.setting);
                          },
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.updateSvg,
                          menuTitle: 'Update',
                          menuColor: MenuTileColor.red,
                          menuTap: () {
                            Get.toNamed(Routes.updateModule);
                          },
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.deviceIdSvg,
                          menuTitle: 'Device Id',
                          menuColor: MenuTileColor.red,
                          menuTap: () async {
                            final id = await AppInfo.getDeviceId();
                            AppDialog.showInfo(
                              context,
                              title: "Device ID",
                              content: id,
                            );
                          },
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.versionSvg,
                          menuTitle: 'Version',
                          menuColor: MenuTileColor.red,
                          menuTap: () async {
                            final version = await AppInfo.getAppVersion();
                            AppDialog.showInfo(
                              context,
                              title: "Version",
                              content: version,
                            );
                          },
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.shiftCloseSvg,
                          menuTitle: 'Shift Close',
                          menuColor: MenuTileColor.red,
                          menuTap: () {},
                        ),
                        SizedBox(height: context.responsiveHeight(0.012)),
                        MenuList(
                          menuSvg: ImagesConstant.logoutSvg,
                          menuTitle: 'Log Out',
                          menuColor: MenuTileColor.red,
                          menuTap: () {
                            AppDialog.showConfirm(
                              context,
                              title: "Log Out",
                              message: "Are you sure",
                              subMessage: "You want to log out.",
                              yesButtonColor: ColorResources.appMainColor,
                              image: Image.asset(
                                ImagesConstant.logout,
                                height: context.responsiveHeight(0.20),
                                width: context.responsiveWidth(0.20),
                              ),
                              onYes: () async{
                                await SecureStorageService.clearAll();
                                Get.offAllNamed(Routes.auth);
                              },
                            );
                          },
                        ),
                        SizedBox(height: context.responsiveHeight(0.02)),
                      ],
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ),
      ),
    ).noKeyboard();
  }
}
