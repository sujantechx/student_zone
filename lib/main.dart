import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:student_zone/firebase_options.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;
import 'core/routes/app_router.dart';
import 'core/theme/theme_manager.dart';
import 'logic/auth/admin_cubit.dart';
import 'data/repositories/auth_repository.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/theme/theme_cubit.dart';
import 'logic/content/content_cubit.dart'; // Added import for ContentCubit to provide content management state
import 'data/repositories/content_repository.dart';
import 'logic/theme/theme_state.dart'; // Added import for ContentRepository required by ContentCubit
import 'data/repositories/pdf_repository.dart';

// Main entry point for the Student Zone app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: kIsWeb? DefaultFirebaseOptions.web :null
    );
    developer.log('Firebase initialized successfully');

    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: const String.fromEnvironment('FLUTTER_ENV') == 'production'
            ? AndroidProvider.playIntegrity
            : AndroidProvider.debug,
      );
      developer.log('Firebase App Check activated');
    } catch (e) {
      developer.log('Error activating App Check: $e', error: e);
    }

    runApp(const MyApp());
  } catch (e) {
    developer.log('Error initializing app: $e', error: e);
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // These initializations are correct
    final authRepository = AuthRepository(
      deviceInfo: DeviceInfoPlugin(),
      uuid: const Uuid(),
    );

    final authCubit = AuthCubit(authRepository: authRepository);
    final adminCubit = AdminCubit(authRepository: authRepository);
    final themeCubit = ThemeCubit();

    return MultiProvider(
      providers: [
        // Keep your existing providers
        Provider<AuthRepository>.value(value: authRepository),
        BlocProvider(create: (context) => authCubit..init()),
        BlocProvider(create: (context) => adminCubit),
        BlocProvider(create: (context) => themeCubit),

        // ✅ 1. Provide the ContentRepository itself.
        // This must come BEFORE the ContentCubit which depends on it.
        Provider<ContentRepository>(
          create: (_) => ContentRepository(),
        ),

        // ✅ 2. Now, your ContentCubit can be created successfully
        // because it can find and read the ContentRepository provided above.
        BlocProvider<ContentCubit>(
          create: (context) => ContentCubit(
            contentRepository: context.read<ContentRepository>(),
          ),
        ),
        Provider<PdfRepository>(
          create: (_) => PdfRepository(),
        ),

      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Student Zone',
            theme: ThemeManager.light,
            darkTheme: ThemeManager.dark,
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter(authCubit: authCubit).router,
          );
        },
      ),
    );
  }
}
