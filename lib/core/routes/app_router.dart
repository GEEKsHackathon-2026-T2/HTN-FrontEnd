import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../features/ai_complaint/ai_complaint_screen.dart';
import '../../features/complaint/complaint_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/location_picker/location_picker_screen.dart';
import '../../features/my/my_screen.dart';
import '../../features/report_complete/report_complete_screen.dart';
import '../../features/report_status/report_status_screen.dart';
import '../../features/status/status_screen.dart';
import '../../shared/widgets/app_shell.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/complaint',
              builder: (context, state) => const ComplaintScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/status',
              builder: (context, state) => const StatusScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my',
              builder: (context, state) => const MyScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/ai-complaint',
      builder: (context, state) => const AiComplaintScreen(),
    ),
    GoRoute(
      path: '/report-complete',
      builder: (context, state) =>
          ReportCompleteScreen(data: state.extra as ReportCompletionData),
    ),
    GoRoute(
      path: '/report-status',
      builder: (context, state) => const ReportStatusScreen(),
    ),
    GoRoute(
      path: '/location-picker',
      builder: (context, state) =>
          LocationPickerScreen(initialLocation: state.extra as LatLng?),
    ),
  ],
);
