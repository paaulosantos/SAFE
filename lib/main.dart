import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safe/core/constants/app_colors.dart';
import 'package:safe/core/theme/app_theme.dart';
import 'package:safe/firebase_options.dart';
import 'package:safe/features/auth/login_screen.dart';
import 'package:safe/features/home/home_screen.dart';
import 'package:safe/features/map/map_screen.dart';
import 'package:safe/features/profile/profile_screen.dart';
import 'package:safe/features/quiz/quiz_screen.dart';
import 'package:safe/features/report/report_screen.dart';
import 'package:safe/shared/services/safe_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseReady = await _initializeFirebase();
  await SafeNotificationService.initializeAndScheduleDailyQuiz();
  runApp(SafeApp(firebaseReady: firebaseReady));
}

Future<bool> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } on UnsupportedError {
    return false;
  } on FirebaseException {
    return false;
  }
}

class SafeApp extends StatelessWidget {
  final bool firebaseReady;

  const SafeApp({super.key, this.firebaseReady = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAFE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: AuthGate(firebaseReady: firebaseReady),
    );
  }
}

class AuthGate extends StatefulWidget {
  final bool firebaseReady;

  const AuthGate({super.key, required this.firebaseReady});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _demoMode = false;
  bool _authenticatedThisSession = false;

  void _enterDemoMode() {
    setState(() {
      _demoMode = true;
    });
  }

  void _enterAuthenticatedApp() {
    setState(() {
      _authenticatedThisSession = true;
    });
  }

  Future<void> _logout() async {
    if (widget.firebaseReady) {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
    }

    setState(() {
      _demoMode = false;
      _authenticatedThisSession = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_demoMode || _authenticatedThisSession) {
      return MainScreen(onLogout: _logout);
    }

    if (!widget.firebaseReady) {
      return LoginScreen(firebaseReady: false, onDemoAccess: _enterDemoMode);
    }

    return LoginScreen(
      onDemoAccess: _enterDemoMode,
      onAuthenticated: _enterAuthenticatedApp,
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const MainScreen({super.key, required this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  final ValueNotifier<String?> _mapPointToOpen = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onOpenMap: () => _onItemTapped(1),
        onOpenQuiz: () => _onItemTapped(3),
      ),
      MapScreen(pointToOpen: _mapPointToOpen),
      ReportScreen(
        onBack: () => _onItemTapped(0),
        onReportSubmitted: _openReportOnMap,
      ),
      QuizScreen(onBack: () => _onItemTapped(0)),
      ProfileScreen(
        onOpenMap: () => _onItemTapped(1),
        onOpenQuiz: () => _onItemTapped(3),
        onLogout: widget.onLogout,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openReportOnMap(String pointId) {
    _mapPointToOpen.value = pointId;
    _onItemTapped(1);
  }

  @override
  void dispose() {
    _mapPointToOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bgNavBar,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Mapa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_rounded),
            label: 'Denunciar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
