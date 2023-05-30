import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:blog/core/common/common.dart';
import 'package:blog/core/providers/shared_pref_provider.dart';
import 'package:blog/core/theme/app_colors.dart';
import 'package:blog/core/theme/app_theme.dart';
import 'package:blog/features/auth/screens/login_screen.dart';

import 'package:blog/features/profile/screens/profile_screen.dart';
import 'package:blog/firebase_options.dart';
import 'package:blog/router.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'core/providers/user_provider.dart';
import 'features/blog/screens/add_blog_screen.dart';
import 'features/auth/controller/auth_controller.dart';

import 'features/home/screens/home_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;

  void getData(WidgetRef ref, User data) async {
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
          data: (data) {
            if (data != null) {
              getData(ref, data);
            }
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ref.watch(themeProvider),
              onGenerateRoute: (settings) => generateRoute(settings),
              title: "Ma'Blog",
              home: data != null ? const MyHomePage() : const LoginScreen(),
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  static const String routeName = '/main';
  const MyHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  /// Controller to handle PageView and also handles initial page
  final _pageController = PageController(initialPage: 1);

  /// widget list
  final List<Widget> bottomBarPages = [
    const HomeScreen(),
    const SearchScreen(),
    const AddBlogScreen(),
    const BottomBarProfileScreen()
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    name();
    //DynamicLinkPro().initDynamic(context);

    super.initState();
  }

  void name() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            message:
                message.notification!.body ?? "Tebrikler blogunuz yayınlandı",
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
              bottomBarPages.length, (index) => bottomBarPages[index]),
        ),
        extendBody: true,
        bottomNavigationBar: AnimatedNotchBottomBar(
          pageController: _pageController,
          color: Colors.white,
          showLabel: false,
          bottomBarItems: [
            BottomBarItem(
              inActiveItem: const Icon(
                Icons.home_filled,
                color: Colors.blueGrey,
              ),
              activeItem: Icon(
                Icons.home_filled,
                color: ref.watch(themeProvider) == AppTheme.darkTheme
                    ? Colors.teal.withOpacity(0.3)
                    : AppColors.primaryColor.withOpacity(0.2),
              ),
              itemLabel: 'Page 1',
            ),
            const BottomBarItem(
              inActiveItem: Icon(
                Icons.search_outlined,
                color: Colors.blueGrey,
              ),
              activeItem: Icon(
                Icons.search_outlined,
                color: Color(0xFF9ACD9F),
              ),
              itemLabel: 'Page 2',
            ),
            BottomBarItem(
              inActiveItem: const Icon(
                Icons.add,
                color: Colors.blueGrey,
              ),
              activeItem: Icon(
                Icons.add,
                color: Colors.brown[400],
              ),
              itemLabel: 'Page 2',
            ),
            BottomBarItem(
              inActiveItem: const Icon(
                Icons.person,
                color: Colors.blueGrey,
              ),
              activeItem: Consumer(builder: (context, ref, child) {
                return ref.watch(userProvider) == null
                    ? const Icon(Icons.person)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          ref.watch(userProvider)!.profilePic,
                          fit: BoxFit.cover,
                        ),
                      );
              }),
              itemLabel: 'Page 5',
            ),
          ],
          onTap: (index) {
            /// control your animation using page controller
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
            );
          },
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
}
