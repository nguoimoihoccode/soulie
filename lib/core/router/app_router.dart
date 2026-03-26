import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/main/presentation/pages/main_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/login',
      refreshListenable: _AuthRefreshStream(authBloc),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isOnLogin = state.matchedLocation == '/login';

        if (authState.status == AuthStatus.authenticated && isOnLogin) {
          return '/main';
        }

        if (authState.status == AuthStatus.unauthenticated && !isOnLogin) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/main',
          name: 'main',
          builder: (context, state) => const MainPage(),
          routes: [
            GoRoute(
              path: 'profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
            GoRoute(
              path: 'chat/:friendKey',
              name: 'chat',
              builder: (context, state) {
                final friendKey =
                    state.pathParameters['friendKey'] ?? 'unknown';
                final initialFriendName =
                    state.uri.queryParameters['name'] ?? 'Unknown';
                return ChatPage(
                  friendKey: friendKey,
                  initialFriendName: initialFriendName,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Converts BLoC stream to Listenable for GoRouter refresh
class _AuthRefreshStream extends ChangeNotifier {
  _AuthRefreshStream(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
