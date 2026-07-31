import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';

enum AppDialogType { radioList, input, searchList, confirm, info }

class AppDialogOption {
  final String label;
  final dynamic value;
  const AppDialogOption({required this.label, required this.value});
}

class AppDialogListItem {
  final String id;
  final String name;
  final String trailing;
  const AppDialogListItem({
    required this.id,
    required this.name,
    required this.trailing,
  });
}

class AppDialog extends StatelessWidget {
  final AppDialogType type;
  final String title;
  final String? content;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final List<AppDialogOption>? options;
  final dynamic initialValue;
  final String? cancelText;
  final String? confirmText;
  final VoidCallback? onCancel;
  final void Function(dynamic selectedValue)? onConfirmRadio;
  final String? inputLabel;
  final TextInputType? inputKeyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String value)? onConfirmInput;
  final List<AppDialogListItem>? listItems;
  final void Function(AppDialogListItem item)? onItemTap;
  final String? confirmMessage;
  final String? confirmSubMessage;
  final Widget? confirmImage;
  final String? noText;
  final String? yesText;
  final Color? yesButtonColor;
  final VoidCallback? onNo;
  final VoidCallback? onYes;

  const AppDialog({
    super.key,
    required this.type,
    required this.title,
    this.content,
    this.buttonText,
    this.onButtonPressed,
    this.options,
    this.initialValue,
    this.cancelText,
    this.confirmText,
    this.onCancel,
    this.onConfirmRadio,
    this.inputLabel,
    this.inputKeyboardType,
    this.inputFormatters,
    this.onConfirmInput,
    this.listItems,
    this.onItemTap,
    this.confirmMessage,
    this.confirmSubMessage,
    this.confirmImage,
    this.noText,
    this.yesText,
    this.yesButtonColor,
    this.onNo,
    this.onYes,
  });

  static Future<void> showRadioList(
    BuildContext context, {
    required String title,
    required List<AppDialogOption> options,
    dynamic initialValue,
    String cancelText = "Cancel",
    String confirmText = "Print",
    VoidCallback? onCancel,
    void Function(dynamic value)? onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppDialog(
        type: AppDialogType.radioList,
        title: title,
        options: options,
        initialValue: initialValue,
        cancelText: cancelText,
        confirmText: confirmText,
        onCancel: onCancel,
        onConfirmRadio: onConfirm,
      ),
    );
  }

  static Future<void> showInput(
    BuildContext context, {
    required String title,
    required String inputLabel,
    String cancelText = "Cancel",
    String confirmText = "OK",
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onCancel,
    void Function(String value)? onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppDialog(
        type: AppDialogType.input,
        title: title,
        inputLabel: inputLabel,
        inputKeyboardType: keyboardType,
        inputFormatters: inputFormatters,
        cancelText: cancelText,
        confirmText: confirmText,
        onCancel: onCancel,
        onConfirmInput: onConfirm,
      ),
    );
  }

  static Future<void> showSearchList(
    BuildContext context, {
    required String title,
    required List<AppDialogListItem> items,
    void Function(AppDialogListItem item)? onItemTap,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppDialog(
        type: AppDialogType.searchList,
        title: title,
        listItems: items,
        onItemTap: onItemTap,
      ),
    );
  }

  static Future<void> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String? subMessage,
    Widget? image,
    String noText = "No",
    String yesText = "Yes",
    Color? yesButtonColor,
    VoidCallback? onNo,
    VoidCallback? onYes,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppDialog(
        type: AppDialogType.confirm,
        title: title,
        confirmMessage: message,
        confirmSubMessage: subMessage,
        confirmImage: image,
        noText: noText,
        yesText: yesText,
        yesButtonColor: yesButtonColor,
        onNo: onNo,
        onYes: onYes,
      ),
    );
  }

  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = "OK",
    VoidCallback? onButtonPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppDialog(
        type: AppDialogType.info,
        title: title,
        content: content,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: ColorResources.whiteColor,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.responsiveWidth(0.32),
        vertical: context.responsiveHeight(0.1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(0.03),
          vertical: context.responsiveHeight(0.025),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_buildTitle(context), _buildBody(context)],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppFonts.geistMono(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ColorResources.labelColor,
          ),
          textAlign: TextAlign.center,
        ),
        Divider(
          height: context.responsiveHeight(0.03),
          color: ColorResources.cardBorderColor,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (type) {
      case AppDialogType.radioList:
        return _RadioListBody(dialog: this);
      case AppDialogType.input:
        return _InputBody(dialog: this);
      case AppDialogType.searchList:
        return _SearchListBody(dialog: this);
      case AppDialogType.confirm:
        return _buildConfirm(context);
      case AppDialogType.info:
        return _buildInfo(context);
    }
  }

  Widget _buildConfirm(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(() {
      final confirmColor = yesButtonColor ?? theme.secondaryColor.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (confirmImage != null) ...[
            confirmImage!,
            SizedBox(height: context.responsiveHeight(0.02)),
          ],
          Text(
            confirmMessage ?? '',
            style: AppFonts.geistMono(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ColorResources.labelColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (confirmSubMessage != null) ...[
            SizedBox(height: context.responsiveHeight(0.006)),
            Text(
              confirmSubMessage!,
              style: AppFonts.geistMono(
                fontSize: 13,
                color: ColorResources.labelColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: context.responsiveHeight(0.025)),
          _buildTwoButtons(
            context,
            cancelText: noText ?? 'No',
            confirmText: yesText ?? 'Yes',
            confirmColor: confirmColor,
            onCancel: onNo,
            onConfirm: () {
              Navigator.of(context).pop();
              onYes?.call();
            },
          ),
        ],
      );
    });
  }

  Widget _buildInfo(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            content ?? '',
            style: AppFonts.geistMono(
              fontSize: 14,
              color: ColorResources.labelColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveHeight(0.025)),
          SizedBox(
            width: context.responsiveWidth(0.10),
            child: AppButton(
              backgroundColor: theme.primaryColor.value,
              onPressed: onButtonPressed ?? () => Navigator.of(context).pop(),
              isLoading: false,
              child: Text(
                buttonText ?? 'OK',
                style: AppFonts.geistMono(
                  color: theme.onPrimaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoButtons(
    BuildContext context, {
    required String cancelText,
    required String confirmText,
    Color? confirmColor,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
  }) {
    final theme = Get.find<AppThemeService>();
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: AppButton(
              backgroundColor: theme.primaryColor.value,
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              isLoading: false,
              child: Text(
                cancelText,
                style: AppFonts.geistMono(
                  color: theme.onPrimaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: context.responsiveWidth(0.02)),
          Expanded(
            child: AppButton(
              backgroundColor: confirmColor ?? theme.secondaryColor.value,
              onPressed: onConfirm ?? () => Navigator.of(context).pop(),
              isLoading: false,
              child: Text(
                confirmText,
                style: AppFonts.geistMono(
                  color: theme.onSecondaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Radio-list dialog body. Owns its local selection state.
class _RadioListBody extends StatefulWidget {
  final AppDialog dialog;
  const _RadioListBody({required this.dialog});

  @override
  State<_RadioListBody> createState() => _RadioListBodyState();
}

class _RadioListBodyState extends State<_RadioListBody> {
  dynamic _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue =
        widget.dialog.initialValue ?? widget.dialog.options?.first.value;
  }

  @override
  Widget build(BuildContext context) {
    final dialog = widget.dialog;
    final theme = Get.find<AppThemeService>();
    final opts = dialog.options ?? [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final opt in opts)
          RadioListTile(
            value: opt.value,
            groupValue: _selectedValue,
            onChanged: (val) => setState(() => _selectedValue = val),
            title: Text(
              opt.label,
              style: AppFonts.geistMono(
                fontSize: 13,
                color: ColorResources.labelColor,
              ),
            ),
            activeColor: theme.secondaryColor.value,
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        SizedBox(height: context.responsiveHeight(0.02)),
        dialog._buildTwoButtons(
          context,
          cancelText: dialog.cancelText ?? 'Cancel',
          confirmText: dialog.confirmText ?? 'Print',
          onCancel: dialog.onCancel,
          onConfirm: () {
            Navigator.of(context).pop();
            dialog.onConfirmRadio?.call(_selectedValue);
          },
        ),
      ],
    );
  }
}

/// Input dialog body. Owns and disposes its [TextEditingController].
class _InputBody extends StatefulWidget {
  final AppDialog dialog;
  const _InputBody({required this.dialog});

  @override
  State<_InputBody> createState() => _InputBodyState();
}

class _InputBodyState extends State<_InputBody> {
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialog = widget.dialog;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextFormField(
          controller: _inputController,
          labelText: dialog.inputLabel ?? '',
          keyboardType: dialog.inputKeyboardType ?? TextInputType.text,
        ),
        SizedBox(height: context.responsiveHeight(0.025)),
        dialog._buildTwoButtons(
          context,
          cancelText: dialog.cancelText ?? 'Cancel',
          confirmText: dialog.confirmText ?? 'OK',
          onCancel: dialog.onCancel,
          onConfirm: () {
            final value = _inputController.text.trim();
            Navigator.of(context).pop();
            dialog.onConfirmInput?.call(value);
          },
        ),
      ],
    );
  }
}

/// Search-list dialog body. Owns and disposes its search controller and
/// keeps the filtered list as local state (no listener leaks).
class _SearchListBody extends StatefulWidget {
  final AppDialog dialog;
  const _SearchListBody({required this.dialog});

  @override
  State<_SearchListBody> createState() => _SearchListBodyState();
}

class _SearchListBodyState extends State<_SearchListBody> {
  late final TextEditingController _searchController;
  late List<AppDialogListItem> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.dialog.listItems ?? [];
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = (widget.dialog.listItems ?? [])
          .where((e) => e.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dialog = widget.dialog;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextFormField(
          controller: _searchController,
          labelText: 'Search Member',
          suffixIcon: Icons.search,
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: context.responsiveHeight(0.015)),
        SizedBox(
          height: context.responsiveHeight(0.3),
          child: ListView.separated(
            itemCount: _filteredItems.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: ColorResources.labelBorderColor),
            itemBuilder: (_, i) {
              final item = _filteredItems[i];
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  dialog.onItemTap?.call(item);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.responsiveHeight(0.012),
                  ),
                  child: Row(
                    children: [
                      Text(
                        item.id,
                        style: AppFonts.geistMono(
                          fontSize: 13,
                          color: ColorResources.labelColor,
                        ),
                      ),
                      SizedBox(width: context.responsiveWidth(0.015)),
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppFonts.geistMono(
                            fontSize: 13,
                            color: ColorResources.labelColor,
                          ),
                        ),
                      ),
                      Text(
                        item.trailing,
                        style: AppFonts.geistMono(
                          fontSize: 13,
                          color: ColorResources.labelColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

//App Widgets ///

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? textController;

  const AppSearchBar({
    super.key,
    this.hintText = "Search",
    this.onChanged,
    this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.responsiveHeight(0.05),
      child: TextField(
        controller: textController,
        onChanged: onChanged,
        style: AppFonts.geistMono(
          fontSize: 13,
          color: ColorResources.labelColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppFonts.geistMono(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ColorResources.labelColor.withOpacity(0.5),
          ),
          suffixIcon: Icon(
            Icons.search,
            size: 28,
            color: ColorResources.blueColor,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(0.015),
            vertical: 0,
          ),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xffF2F6FF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xffF2F6FF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xffF2F6FF), width: 1.5),
          ),
          filled: true,
          fillColor: const Color(0xffF2F6FF),
        ),
      ),
    );
  }
}

class AppHeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final TextAlign textAlign;

  const AppHeaderCell(
    this.label, {
    super.key,
    required this.flex,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppFonts.geistMono(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: ColorResources.labelColor,
        ),
        textAlign: textAlign,
      ),
    );
  }
}

class AppDataCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign textAlign;

  const AppDataCell(
    this.text, {
    super.key,
    required this.flex,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppFonts.geistMono(
          fontSize: 11,
          color: ColorResources.labelColor,
        ),
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class AppActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AppActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(
      () => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(0.008),
            vertical: context.responsiveHeight(0.005),
          ),
          decoration: BoxDecoration(
            border: Border.all(color: ColorResources.backgroundColor),
            borderRadius: BorderRadius.circular(6),
            color: ColorResources.backgroundColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: theme.secondaryColor.value),
              SizedBox(width: context.responsiveWidth(0.004)),
              Text(
                label,
                style: AppFonts.geistMono(
                  fontSize: 10,
                  color: ColorResources.labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
