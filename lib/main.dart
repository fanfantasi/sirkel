import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/firebase_options.dart';
import 'package:screenshare/presentation/bloc/content/content_cubit.dart';
import 'package:screenshare/presentation/bloc/content/post/post_content_cubit.dart';
import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
import 'package:screenshare/presentation/bloc/music/music_cubit.dart';
import 'package:screenshare/presentation/bloc/user/follow/follow_cubit.dart';
import 'package:screenshare/presentation/bloc/user/user_cubit.dart';
import 'package:screenshare/presentation/bloc/video/token/token_cubit.dart';
import 'core/theme/theme.dart';
import 'core/utils/constants.dart';
import 'injection_container.dart' as di;
import 'package:timeago/timeago.dart' as timeago;
import 'presentation/bloc/auth/auth_cubit.dart';
import 'presentation/bloc/navigation/navigation_cubit.dart';
import 'presentation/bloc/theme/theme_cubit.dart';
import 'presentation/routes/app_routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapBoxSearch.init(Config.mapBox);
  await di.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  timeago.setLocaleMessages('id', timeago.IdMessages());
  PhotoManager.clearFileCache();
  runApp(EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('id')],
    path: 'assets/translations',
    fallbackLocale: const Locale('id'),
    startLocale: const Locale('id'),
    useOnlyLangCode: true,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.getIt<ThemeCubit>()..initialAppTheme()),
        BlocProvider(create: (_) => di.getIt<NavigationCubit>()),
        BlocProvider(create: (_) => di.getIt<ContentCubit>()),
        BlocProvider(create: (_) => di.getIt<AuthCubit>()),
        BlocProvider(create: (_) => di.getIt<UserCubit>()),
        BlocProvider(create: (_) => di.getIt<LikedCubit>()),
        BlocProvider(create: (_) => di.getIt<FollowCubit>()),
        BlocProvider(create: (_) => di.getIt<MusicCubit>()),
        BlocProvider(create: (_) => di.getIt<VideoTokenCubit>()),
        BlocProvider(create: (_) => di.getIt<PostContentCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: true,
            title: 'Screen Share',
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            locale: context.locale,
            theme: ThemeModel().lightTheme,
            darkTheme: ThemeModel().darkTheme,
            themeMode: context
                .select((ThemeCubit themeCubit) => themeCubit.state.themeMode),
            onGenerateRoute: RouteGenerator.generateRoute,
            initialRoute: Routes.root,
          );
        },
      )
    );
  }
}