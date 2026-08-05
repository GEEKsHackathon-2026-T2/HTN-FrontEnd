import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../network/api_client.dart';
import '../network/auth_api.dart';

const _deviceEmailKey = 'device_citizen_email';

/// There's no login screen yet, so every install signs in silently through
/// `POST /auth/citizen`. Report creation requires a signed-in user for
/// non-anonymous petitions (see ReportsService.create), so this must
/// complete before submitting.
///
/// The email is generated once and persisted per device — under real auth
/// this would give each install its own account. Right now the backend's
/// `AUTH_DEFAULT_USER_ENABLED` MVP mode maps every request to one fixed
/// account regardless of the email sent (docs/05-api.md §1.3), so this is
/// forward-compatible rather than load-bearing today.
class Session {
  Session._();

  static Future<void>? _pending;
  static String? displayName;

  static Future<void> ensureSignedIn() {
    return _pending ??= _signIn();
  }

  static void signOut() {
    apiClient.setAccessToken(null);
    displayName = null;
    _pending = null;
  }

  static Future<void> _signIn() async {
    final prefs = await SharedPreferences.getInstance();
    var email = prefs.getString(_deviceEmailKey);
    if (email == null) {
      email = 'citizen-${const Uuid().v4()}@device.local';
      await prefs.setString(_deviceEmailKey, email);
    }
    final session = await AuthApi().signInAsCitizen(email: email);
    apiClient.setAccessToken(session.accessToken);
    displayName = session.displayName;
  }
}
