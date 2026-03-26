import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/services/home_widget_sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/soulie/data/soulie_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0C0810),
    ),
  );
  runApp(SoulieApp());
}

class SoulieApp extends StatelessWidget {
  SoulieApp({super.key, AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<HomeWidgetSyncService>(
          create: (_) => const HomeWidgetSyncService(),
        ),
        RepositoryProvider<SoulieRepository>(
          create: (_) => SoulieRepository(authRepository: _authRepository),
        ),
      ],
      child: BlocProvider(
        create: (_) =>
            AuthBloc(authRepository: _authRepository)
              ..add(const AuthCheckRequested()),
        child: const _SoulieAppView(),
      ),
    );
  }
}

class _SoulieAppView extends StatelessWidget {
  const _SoulieAppView();

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return MaterialApp.router(
      title: 'Soulie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router(authBloc),
    );
  }
}
