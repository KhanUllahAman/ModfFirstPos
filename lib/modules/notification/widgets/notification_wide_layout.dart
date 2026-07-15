import 'package:flutter/material.dart';
import 'package:modfirstpos/modules/notification/widgets/notification_filter_sidebar_widget.dart';
import 'package:modfirstpos/modules/notification/widgets/notification_panel_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class NotificationWideLayout extends StatelessWidget {
  const NotificationWideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(
          flex: 3,
          child: NotificationFilterSidebarWidget(),
        ),
        SizedBox(width: context.responsiveWidth(0.02)),
        const Expanded(
          flex: 7,
          child: NotificationPanelWidget(),
        ),
      ],
    );
  }
}
