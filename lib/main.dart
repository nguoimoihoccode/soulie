import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'core/router/app_router.dart';
import 'core/services/home_widget_sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/soulie/data/soulie_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const homeWidgetSyncService = HomeWidgetSyncService();
  await homeWidgetSyncService.configure();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0C0810),
    ),
  );
  runApp(SoulieApp(homeWidgetSyncService: homeWidgetSyncService));
}

class SoulieApp extends StatelessWidget {
  SoulieApp({
    super.key,
    AuthRepository? authRepository,
    HomeWidgetSyncService? homeWidgetSyncService,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _homeWidgetSyncService =
           homeWidgetSyncService ?? const HomeWidgetSyncService();

  final AuthRepository _authRepository;
  final HomeWidgetSyncService _homeWidgetSyncService;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<HomeWidgetSyncService>(
          create: (_) => _homeWidgetSyncService,
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

class _SoulieAppView extends StatefulWidget {
  const _SoulieAppView();

  @override
  State<_SoulieAppView> createState() => _SoulieAppViewState();
}

class _SoulieAppViewState extends State<_SoulieAppView> {
  GoRouter? _router;
  Stream<Uri?>? _widgetClickStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authBloc = context.read<AuthBloc>();
    _router ??= AppRouter.router(authBloc);
    _widgetClickStream ??= HomeWidget.widgetClicked;
  }

  void _handleWidgetClick(Uri? uri) {
    final router = _router;
    if (router == null) {
      return;
    }

    router.go(AppRouter.routeForWidgetUri(uri));
  }

  @override
  Widget build(BuildContext context) {
    final router = _router!;

    return StreamBuilder<Uri?>(
      stream: _widgetClickStream,
      builder: (context, snapshot) {
        final clickedUri = snapshot.data;
        if (clickedUri != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleWidgetClick(clickedUri);
          });
        }

        return MaterialApp.router(
          title: 'Soulie',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: router,
        );
      },
    );
  }
}
