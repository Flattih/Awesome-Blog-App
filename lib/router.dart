import 'package:blog/core/common/common.dart';
import 'package:blog/features/blog/screens/approve_screen.dart';
import 'package:blog/features/auth/screens/login_screen.dart';
import 'package:blog/main.dart';
import 'package:flutter/material.dart';

import 'features/blog/screens/add_topic_screen.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/blog/screens/comments_screen.dart';
import 'features/blog/screens/detail_screen.dart';
import 'features/blog/screens/from_dynamic_link_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'models/blog_model.dart';
import 'models/user_model.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case SignUpScreen.routeName:
      return MaterialPageRoute(builder: (_) => const SignUpScreen());
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case MyHomePage.routeName:
      return MaterialPageRoute(builder: (_) => const MyHomePage());
    case ForgotPasswordScreen.routeName:
      return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());
    case HomeScreen.routeName:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case SearchScreen.routeName:
      return MaterialPageRoute(builder: (_) => const SearchScreen());
    case AddTopicScreen.routeName:
      return MaterialPageRoute(builder: (_) => const AddTopicScreen());
    case EditProfileScreen.routeName:
      return MaterialPageRoute(builder: (_) => const EditProfileScreen());
    case BottomBarProfileScreen.routeName:
      return MaterialPageRoute(builder: (_) => const BottomBarProfileScreen());
    case ProfileScreen.routeName:
      final user = routeSettings.arguments as UserModel;
      return MaterialPageRoute(
        builder: (_) => ProfileScreen(user: user),
      );
    case ApproveBlogScreen.routeName:
      return MaterialPageRoute(builder: (_) => const ApproveBlogScreen());
    case FromDynamicLinkScreen.routeName:
      final id = routeSettings.arguments as String;
      return MaterialPageRoute(builder: (_) => FromDynamicLinkScreen(id: id));
    case DetailScreen.routeName:
      final blog = routeSettings.arguments as Blog;
      return MaterialPageRoute(
          builder: (_) => DetailScreen(
                blog: blog,
              ));
    case CommentsScreen.routeName:
      final postId = routeSettings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => CommentsScreen(
          postId: postId,
        ),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => const ErrorScreen(
          error: "Beklenmedik bir hata oluştu!",
        ),
      );
  }
}
