import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/pages/auth/auth_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/home_page.dart';
import 'package:splashscreen/splashscreen.dart';

ColorScheme? lightColorScheme;
ColorScheme? darkColorScheme;

ThemeData lightTheme(ColorScheme? lightColorScheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    colorSchemeSeed: lightColorScheme == null ? Colors.orange : null,
    brightness: Brightness.light,
  );
}

ThemeData darkTheme(ColorScheme? darkColorScheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    colorSchemeSeed: darkColorScheme == null ? Colors.orange : null,
    brightness: Brightness.dark,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      lightColorScheme = lightColorScheme;
      darkColorScheme = darkColorScheme;
      return GetMaterialApp(
        title: 'MovieGram',
        theme: lightTheme(lightColorScheme),
        darkTheme: darkTheme(darkColorScheme),
        themeMode: ThemeMode.system,
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
      loadingText:
          Text(result == null ? 'Loading...' : 'Welcome back ${result!.displayName}!'),
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
