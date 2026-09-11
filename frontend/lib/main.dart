import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'config/liquid_glass_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JobTrackerApp());
}

class JobTrackerApp extends StatelessWidget {
  const JobTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
      ],
      child: MaterialApp(
        title: 'Job Application Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: LiquidGlass.bgDeep,
          primaryColor: LiquidGlass.accentPrimary,
          colorScheme: ColorScheme.dark(
            primary: LiquidGlass.accentPrimary,
            secondary: LiquidGlass.accentSecond,
            surface: LiquidGlass.bgSurface,
            error: LiquidGlass.accentRed,
            onSurface: Colors.white,
          ),
          textTheme: GoogleFonts.outfitTextTheme(
            ThemeData.dark().textTheme,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: LiquidGlass.accentPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: LiquidGlass.accentPrimary,
            foregroundColor: Colors.white,
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: LiquidGlass.bgSurface,
            contentTextStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: LiquidGlass.accentPrimary, width: 1.5),
            ),
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            selectedColor: LiquidGlass.accentPrimary.withValues(alpha: 0.3),
            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            shape: const StadiumBorder(),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper widget that checks auth state and routes accordingly.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await context.read<AuthProvider>().tryAutoLogin();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: LiquidGlass.bgDeep,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [LiquidGlass.bgDeep, LiquidGlass.bgMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LiquidGlass.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: LiquidGlass.glowShadow(LiquidGlass.accentPrimary, intensity: 0.5, blur: 28),
                  ),
                  child: const Icon(Icons.work_outline, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 28),
                CircularProgressIndicator(
                  color: LiquidGlass.accentPrimary,
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (ctx, auth, _) {
        if (auth.isAuthenticated) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
