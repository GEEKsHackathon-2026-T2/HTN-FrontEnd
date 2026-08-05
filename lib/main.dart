import 'dart:async';

import 'package:flutter/material.dart';
import 'app.dart';
import 'core/auth/session.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(Session.ensureSignedIn());
  runApp(const MyApp());
}
