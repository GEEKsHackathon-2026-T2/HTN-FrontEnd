import 'api_client.dart';

class CitizenSession {
  const CitizenSession({required this.accessToken, this.displayName});

  final String accessToken;
  final String? displayName;
}

/// Wraps `POST /auth/citizen` (docs/05-api.md §1.1, §1.3) — the "temporary
/// path before social login" the backend already exposes for citizens.
///
/// While `AUTH_DEFAULT_USER_ENABLED` is on (MVP default), the backend
/// ignores the email we send and always returns the same fixed account —
/// so this always signs in as whichever account the backend has chosen.
class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  Future<CitizenSession> signInAsCitizen({required String email}) async {
    final res = await _client.post('/auth/citizen', {'email': email});
    final user = res['user'] as Map<String, dynamic>?;
    return CitizenSession(
      accessToken: res['accessToken'] as String,
      displayName: user?['displayName'] as String?,
    );
  }
}
