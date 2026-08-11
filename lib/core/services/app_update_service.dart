import 'dart:developer';
import 'dart:io';

import 'package:in_app_update/in_app_update.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

/// Wraps Google Play's In-App Update API so cashiers get the same
/// "update available" prompt other apps show, instead of silently running
/// a stale build forever (Play never force-updates on its own).
///
/// Uses a **flexible** update: downloads in the background while the
/// cashier keeps working (a POS app can't afford to block on an "update
/// now or nothing" screen mid-shift), then shows a snackbar prompting them
/// to restart once it's ready to install.
class AppUpdateService {
  AppUpdateService._();

  static bool _checkedThisSession = false;

  /// Call once, e.g. right after the home screen loads. Android-only (the
  /// underlying Play Core API has no iOS equivalent) and a total no-op if
  /// already checked this session or if the check itself fails (no
  /// internet, not installed via Play, etc — never worth surfacing an
  /// error for).
  static Future<void> checkForUpdate() async {
    if (!Platform.isAndroid || _checkedThisSession) return;
    _checkedThisSession = true;

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }

      if (info.flexibleUpdateAllowed) {
        final result = await InAppUpdate.startFlexibleUpdate();
        if (result == AppUpdateResult.success) {
          customSnackBar(
            'Update Ready',
            'A new version has been downloaded. Tap to restart and install.',
            snackBarType: SnackBarType.info,
            durationSeconds: 10,
            onDismissed: () async {
              try {
                await InAppUpdate.completeFlexibleUpdate();
              } catch (e) {
                log('AppUpdateService completeFlexibleUpdate error: $e');
              }
            },
          );
        }
      } else if (info.immediateUpdateAllowed) {
        // Flexible isn't offered for this update (e.g. it's marked
        // priority/critical on the Play Console side) — immediate is the
        // only option Play gives us here.
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      log('AppUpdateService checkForUpdate error: $e');
    }
  }
}
