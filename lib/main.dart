import 'dart:ui';

import 'package:device_preview/device_preview.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:projet_lepl1509_groupe_17/pages/auth/auth_page.dart';
import 'package:splashscreen/splashscreen.dart';

import 'pages/home/home_page.dart';

const String themoviedbApi = "**REMOVED**";

ColorScheme? lightColorScheme;
ColorScheme? darkColorScheme;

ThemeData lightTheme(ColorScheme? lightColorScheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    colorSchemeSeed: lightColorScheme == null ? Colors.lightBlue : null,
    brightness: Brightness.light,
  );
}

ThemeData darkTheme(ColorScheme? darkColorScheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    colorSchemeSeed: darkColorScheme == null ? Colors.lightBlue : null,
    brightness: Brightness.dark,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // prevent landscape mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Firebase.initializeApp();
  await GetStorage.init();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  Animate.restartOnHotReload = true;
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool? _isDark;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _isDark = box.read('isDark');
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      lightColorScheme = lightColorScheme;
      darkColorScheme = darkColorScheme;
      return GetMaterialApp(
        title: 'MovieGram',
        theme: lightTheme(lightColorScheme),
        darkTheme: darkTheme(darkColorScheme),
        themeMode: _isDark != null ? (_isDark! ? ThemeMode.dark : ThemeMode.light) : ThemeMode.system,
        home: const IntroScreen(),
      );
    });
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  User? result = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      useLoader: true,
      loadingText: Text(result == null ? 'Loading...' : 'Welcome back ${result!.displayName}!'),
      navigateAfterSeconds: result == null ? const AuthPage() : const HomePage(),
      seconds: 1,
      title: const Text(
        'MovieGram',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ),
      loadingTextPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.background,
      styleTextUnderTheLoader: const TextStyle(),
    );
  }
}
