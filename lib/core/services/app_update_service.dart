import 'dart:developer';
import 'dart:io';

import 'package:in_app_update/in_app_update.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

/// Wraps Google Play's In-App Update API so every POS device is forced
/// onto the latest build as soon as one is published — a shared,
/// company-managed cashier device should never be left running a stale
/// version (Play never force-updates on its own).
///
/// Uses an **immediate** update: Play shows its own full-screen "Update
/// now" flow and blocks the app until it's installed. Falls back to a
/// flexible (background download + restart-to-install) update only on the
/// rare case Play doesn't allow immediate for a given release.
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

      if (info.immediateUpdateAllowed) {
        // Blocks with Play's own full-screen update UI until installed —
        // the cashier can't dismiss their way back into the stale build.
        await InAppUpdate.performImmediateUpdate();
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
      }
    } catch (e) {
      log('AppUpdateService checkForUpdate error: $e');
    }
  }
}
