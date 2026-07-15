import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modfirstpos/modules/storeSelection/controller/store_selection_controller.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class StoreSelectionView extends GetView<StoreSelectionController> {
  const StoreSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(0.06)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: context.spacingXL),
              Text(
                'Select Your Store',
                textAlign: TextAlign.center,
                style: GoogleFonts.geistMono(
                  fontSize: context.fontLG,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.spacingSM),
              Text(
                'This is a one-time setup for this device',
                textAlign: TextAlign.center,
                style: GoogleFonts.geistMono(
                  fontSize: context.fontXS,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              SizedBox(height: context.spacingLG),
              Expanded(
                child: ListView.separated(
                  primary: false,
                  itemCount: controller.stores.length,
                  separatorBuilder: (_, __) => SizedBox(height: context.spacingSM),
                  itemBuilder: (_, index) {
                    final store = controller.stores[index];
                    return _StoreTile(
                      name: store.displayName,
                      isLoading: controller.isLoading.value,
                      onTap: () => controller.selectStore(store),
                    );
                  },
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  final String name;
  final bool isLoading;
  final VoidCallback onTap;

  const _StoreTile({
    required this.name,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacingMD,
            vertical: context.spacingMD,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.geistMono(
                    fontSize: context.fontMD,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}