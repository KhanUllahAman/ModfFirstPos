import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class AppDialog extends StatefulWidget {
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
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog> {
  dynamic _selectedValue;
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<AppDialogListItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue ?? widget.options?.first.value;
    _filteredItems = widget.listItems ?? [];
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = (widget.listItems ?? [])
          .where((e) => e.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _searchController.dispose();
    super.dispose();
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
          widget.title,
          style: GoogleFonts.geistMono(
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
    switch (widget.type) {
      case AppDialogType.radioList:
        return _buildRadioList(context);
      case AppDialogType.input:
        return _buildInput(context);
      case AppDialogType.searchList:
        return _buildSearchList(context);
      case AppDialogType.confirm:
        return _buildConfirm(context);
      case AppDialogType.info:
        return _buildInfo(context);
    }
  }

  Widget _buildRadioList(BuildContext context) {
    final options = widget.options ?? [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final opt in options)
          RadioListTile(
            value: opt.value,
            groupValue: _selectedValue,
            onChanged: (val) => setState(() => _selectedValue = val),
            title: Text(
              opt.label,
              style: GoogleFonts.geistMono(
                fontSize: 13,
                color: ColorResources.labelColor,
              ),
            ),
            activeColor: ColorResources.appMainColor,
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        SizedBox(height: context.responsiveHeight(0.02)),
        _buildTwoButtons(
          context,
          cancelText: widget.cancelText ?? "Cancel",
          confirmText: widget.confirmText ?? "Print",
          onCancel: widget.onCancel,
          onConfirm: () {
            Navigator.of(context).pop();
            widget.onConfirmRadio?.call(_selectedValue);
          },
        ),
      ],
    );
  }

  Widget _buildInput(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextFormField(
          controller: _inputController,
          labelText: widget.inputLabel ?? "",
          keyboardType: widget.inputKeyboardType ?? TextInputType.text,
        ),
        SizedBox(height: context.responsiveHeight(0.025)),
        _buildTwoButtons(
          context,
          cancelText: widget.cancelText ?? "Cancel",
          confirmText: widget.confirmText ?? "OK",
          onCancel: widget.onCancel,
          onConfirm: () {
            Navigator.of(context).pop();
            widget.onConfirmInput?.call(_inputController.text.trim());
          },
        ),
      ],
    );
  }

  Widget _buildSearchList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextFormField(
          controller: _searchController,
          labelText: "Search Member",
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
                  widget.onItemTap?.call(item);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.responsiveHeight(0.012),
                  ),
                  child: Row(
                    children: [
                      Text(
                        item.id,
                        style: GoogleFonts.geistMono(
                          fontSize: 13,
                          color: ColorResources.labelColor,
                        ),
                      ),
                      SizedBox(width: context.responsiveWidth(0.015)),
                      Expanded(
                        child: Text(
                          item.name,
                          style: GoogleFonts.geistMono(
                            fontSize: 13,
                            color: ColorResources.labelColor,
                          ),
                        ),
                      ),
                      Text(
                        item.trailing,
                        style: GoogleFonts.geistMono(
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

  Widget _buildConfirm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.confirmImage != null) ...[
          widget.confirmImage!,
          SizedBox(height: context.responsiveHeight(0.02)),
        ],
        Text(
          widget.confirmMessage ?? "",
          style: GoogleFonts.geistMono(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: ColorResources.labelColor,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.confirmSubMessage != null) ...[
          SizedBox(height: context.responsiveHeight(0.006)),
          Text(
            widget.confirmSubMessage!,
            style: GoogleFonts.geistMono(
              fontSize: 13,
              color: ColorResources.labelColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: context.responsiveHeight(0.025)),
        _buildTwoButtons(
          context,
          cancelText: widget.noText ?? "No",
          confirmText: widget.yesText ?? "Yes",
          confirmColor: widget.yesButtonColor ?? ColorResources.gradientRed,
          onCancel: widget.onNo,
          onConfirm: () {
            Navigator.of(context).pop();
            widget.onYes?.call();
          },
        ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.content ?? "",
          style: GoogleFonts.geistMono(
            fontSize: 14,
            color: ColorResources.labelColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.responsiveHeight(0.025)),
        SizedBox(
          width: context.responsiveWidth(0.10),
          child: AppButton(
            onPressed:
                widget.onButtonPressed ?? () => Navigator.of(context).pop(),
            isLoading: false,
            child: Text(
              widget.buttonText ?? "OK",
              style: GoogleFonts.geistMono(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
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
    return Row(
      children: [
        Expanded(
          child: AppButton(
            backgroundColor: ColorResources.buttonColor,
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            isLoading: false,
            child: Text(
              cancelText,
              style: GoogleFonts.geistMono(
                color: ColorResources.appMainColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: context.responsiveWidth(0.02)),
        Expanded(
          child: AppButton(
            backgroundColor: confirmColor,
            onPressed: onConfirm ?? () => Navigator.of(context).pop(),
            isLoading: false,
            child: Text(
              confirmText,
              style: GoogleFonts.geistMono(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}



//App Widgets ///

class AppSyncButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double iconSize;

  const AppSyncButton({
    super.key,
    this.label = "All Sync",
    this.onPressed,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed ?? () {},
      icon: Icon(
        Icons.sync,
        size: iconSize,
        color: ColorResources.appMainColor,
      ),
      label: Text(
        label,
        style: GoogleFonts.geistMono(
          fontSize: 12,
          color: ColorResources.appMainColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: ColorResources.backgroundColor,
        side: BorderSide(color: ColorResources.backgroundColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(0.015),
          vertical: context.responsiveHeight(0.008),
        ),
      ),
    );
  }
}

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
        style: GoogleFonts.geistMono(
          fontSize: 13,
          color: ColorResources.labelColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.geistMono(
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
        style: GoogleFonts.geistMono(
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
        style: GoogleFonts.geistMono(
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
    return GestureDetector(
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
            Icon(icon, size: 11, color: ColorResources.appMainColor),
            SizedBox(width: context.responsiveWidth(0.004)),
            Text(
              label,
              style: GoogleFonts.geistMono(
                fontSize: 10,
                color: ColorResources.labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}