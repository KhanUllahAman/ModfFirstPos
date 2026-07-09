import 'package:flutter/material.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

enum MenuTileColor { neutral, destructive }

class MenuList extends StatelessWidget {
  final IconData menuIcon;
  final String menuTitle;
  final VoidCallback menuTap;
  final MenuTileColor menuColor;

  const MenuList({
    super.key,
    required this.menuIcon,
    required this.menuTitle,
    required this.menuTap,
    this.menuColor = MenuTileColor.neutral,
  });

  bool get _destructive => menuColor == MenuTileColor.destructive;

  @override
  Widget build(BuildContext context) {
    final iconBg = _destructive
        ? const Color(0xFFFCEAEA)
        : const Color(0xFFF2F4F8);
    final iconColor = _destructive
        ? const Color(0xFFE5484D)
        : const Color(0xFF4B5768);
    final textColor = _destructive
        ? const Color(0xFFE5484D)
        : ColorResources.labelColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: menuTap,
        splashColor: iconColor.withOpacity(0.08),
        highlightColor: iconColor.withOpacity(0.04),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacingMD,
            vertical: context.spacingSM,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(menuIcon, size: 19, color: iconColor),
              ),
              SizedBox(width: context.spacingSM),
              Expanded(
                child: Text(
                  menuTitle,
                  style: AppFonts.geistMono(
                    fontSize: context.fontSM,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB4B9C6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuSectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const MenuSectionCard({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: context.spacingXS),
            child: Text(
              title!.toUpperCase(),
              style: AppFonts.geistMono(
                fontSize: context.fontXS,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: const Color(0xFF9AA1B0),
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7E9F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F1A2E).withOpacity(0.03),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Padding(
                    padding: EdgeInsets.only(left: context.spacingMD + 38 + 12),
                    child: const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF0F1F5),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class MenuSegmentedTabs extends StatelessWidget {
  final List<String> labels;

  const MenuSegmentedTabs({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0F4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedBuilder(
        animation: controller.animation!,
        builder: (context, _) {
          final value = controller.animation!.value;
          return LayoutBuilder(
            builder: (context, constraints) {
              final segmentWidth = constraints.maxWidth / labels.length;
              return Stack(
                children: [
                  Positioned(
                    left: segmentWidth * value,
                    width: segmentWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(labels.length, (index) {
                      final selected = controller.index == index;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.animateTo(index),
                          child: Center(
                            child: Text(
                              labels[index],
                              style: AppFonts.geistMono(
                                fontSize: context.fontXS,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? ColorResources.labelColor
                                    : const Color(0xFF9AA1B0),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class MenuHeroAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MenuHeroAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacingMD,
            vertical: context.spacingMD,
          ),
          decoration: BoxDecoration(
            color: ColorResources.blackColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ColorResources.appMainColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: ColorResources.blackColor, size: 23),
              ),
              SizedBox(width: context.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.geistMono(
                        fontSize: context.fontMD,
                        fontWeight: FontWeight.w700,
                        color: ColorResources.whiteColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w500,
                        color: ColorResources.whiteColor.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ColorResources.whiteColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: ColorResources.whiteColor,
                  size: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
