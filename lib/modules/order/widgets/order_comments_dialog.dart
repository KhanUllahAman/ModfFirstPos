import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/order/controller/order_controller.dart';
import 'package:modfirstpos/modules/order/model/order_comment_model.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';

class OrderCommentsDialog extends StatefulWidget {
  const OrderCommentsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const OrderCommentsDialog(),
    );
  }

  @override
  State<OrderCommentsDialog> createState() => _OrderCommentsDialogState();
}

class _OrderCommentsDialogState extends State<OrderCommentsDialog> {
  final OrderController controller = Get.find<OrderController>();
  final TextEditingController commentController = TextEditingController();
  final Map<String, String> commentTypes = const {
    'customer_message': 'Customer Message',
    'note': 'Note',
    'status_update': 'Status Update',
    'internal_flag': 'Internal Flag',
  };
  String selectedType = 'customer_message';

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final order = controller.selectedOrder.value;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Comments${order?.orderNumber != null ? ' - ${order!.orderNumber}' : ''}',
                    style: AppFonts.geistMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorResources.labelColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(color: ColorResources.cardBorderColor),
              Expanded(child: Obx(() => _buildCommentsList())),
              const SizedBox(height: 10),
              const Divider(color: ColorResources.cardBorderColor),
              const SizedBox(height: 10),
              _buildComposer(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    if (controller.isLoadingComments.value) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (controller.orderComments.isEmpty) {
      return Center(
        child: Text(
          'No comments yet',
          style: AppFonts.geistMono(fontSize: 13, color: Colors.grey[500]),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.orderComments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildCommentTile(controller.orderComments[i]),
    );
  }

  Widget _buildCommentTile(OrderCommentModel comment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorResources.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorResources.cardBorderColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTypeBadge(comment.commentType),
              Text(
                _formatDateTime(comment.createdAt),
                style: AppFonts.geistMono(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.comment ?? '',
            style: AppFonts.geistMono(
              fontSize: 12.5,
              color: ColorResources.labelColor,
            ),
          ),
          if (comment.attachmentUrl != null &&
              comment.attachmentUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                comment.attachmentUrl!,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String? type) {
    Color color;
    switch (type) {
      case 'status_update':
        color = ColorResources.blueColor;
        break;
      case 'internal_flag':
        color = ColorResources.gradientRed;
        break;
      case 'note':
        color = ColorResources.warningOrange;
        break;
      default:
        color = ColorResources.successGreen;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        (commentTypes[type] ?? type ?? '').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildComposer(AppThemeService theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final attachment = controller.pendingCommentAttachment.value;
          if (attachment == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    attachment,
                    height: 48,
                    width: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    attachment.path.split(Platform.pathSeparator).last,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.geistMono(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: controller.removeCommentAttachment,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
          );
        }),
        Row(
          children: [
            SizedBox(
              width: 140,
              child: DropdownButtonFormField<String>(
                value: selectedType,
                isExpanded: true,
                dropdownColor: ColorResources.whiteColor,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: ColorResources.whiteColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: ColorResources.labelBorderColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: ColorResources.labelBorderColor,
                    ),
                  ),
                ),
                style: AppFonts.geistMono(
                  fontSize: 11,
                  color: ColorResources.labelColor,
                ),
                items: commentTypes.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (val) =>
                    setState(() => selectedType = val ?? selectedType),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _showAttachmentPicker,
              icon: const Icon(Icons.attach_file_rounded),
              tooltip: 'Attach image',
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          controller: commentController,
          labelText: 'Comment',
          hintText: 'Write a comment...',
          maxLines: 3,
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isPostingComment.value
                  ? null
                  : _submitComment,
              icon: controller.isPostingComment.value
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, size: 16),
              label: Text(
                'SEND',
                style: AppFonts.geistMono(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor.value,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAttachmentPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorResources.whiteColor,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                controller.pickCommentAttachment(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                controller.pickCommentAttachment(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    final success = await controller.postOrderComment(
      comment: text,
      commentType: selectedType,
    );
    if (success) {
      commentController.clear();
    }
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return DateFormat('MMM d, hh:mm a').format(dateTime);
    } catch (_) {
      return isoString;
    }
  }
}
