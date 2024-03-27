import 'package:get_it/get_it.dart';
import 'package:screenshare/domain/repositories/repository.dart';
import 'package:screenshare/domain/usecases/auth/auth_usecase.dart';
import 'package:screenshare/domain/usecases/follow/get_follow_usecase.dart';
import 'package:screenshare/domain/usecases/liked/post_liked_usecase.dart';
import 'package:screenshare/domain/usecases/music/get_music_usecase.dart';
import 'package:screenshare/domain/usecases/pictures/get_pictures_usecase.dart';
import 'package:screenshare/domain/usecases/user/get_user_usecase.dart';
import 'package:screenshare/presentation/bloc/liked/liked_cubit.dart';
import 'package:screenshare/presentation/bloc/music/music_cubit.dart';
import 'package:screenshare/presentation/bloc/pictures/picture_cubit.dart';
import 'package:screenshare/presentation/bloc/user/follow/follow_cubit.dart';
import 'package:screenshare/presentation/bloc/user/user_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/datasource.dart';
import 'data/datasources/datasource_impl.dart';
import 'data/repositories/repository_impl.dart';
import 'data/services/api_services.dart';
import 'domain/usecases/auth/signin_usecase.dart';
import 'domain/usecases/auth/signout_usecase.dart';
import 'presentation/bloc/auth/auth_cubit.dart';
import 'presentation/bloc/navigation/navigation_cubit.dart';
import 'presentation/bloc/theme/theme_cubit.dart';

final getIt = GetIt.instance;
Future<void> init() async {
  //Bloc
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit());
  getIt.registerFactory<NavigationCubit>(() => NavigationCubit());
  getIt.registerFactory<PictureCubit>(() => PictureCubit(getPicturesUseCase: getIt.call()));
  getIt.registerFactory<AuthCubit>(
      () => AuthCubit(authUseCase: getIt.call(), signOutUseCase: getIt.call(), signInUseCase: getIt.call()));
  getIt.registerFactory<UserCubit>(() => UserCubit(getCurrentUserUseCase: getIt.call()));
  getIt.registerFactory<LikedCubit>(() => LikedCubit(postLikedUseCase: getIt.call()));
  getIt.registerFactory<FollowCubit>(() => FollowCubit(getFollowUserUseCase: getIt.call()));
  getIt.registerFactory<MusicCubit>(() => MusicCubit(getMusicUseCase: getIt.call()));
      
  //usecase
  getIt.registerLazySingleton<SignInUseCase>(() => SignInUseCase());
  getIt.registerLazySingleton<AuthUseCase>(() => AuthUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase());
  getIt.registerLazySingleton<GetPicturesUseCase>(() => GetPicturesUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<GetCurrentUserUseCase>(() => GetCurrentUserUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<PostLikedUseCase>(() => PostLikedUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<GetFollowUserUseCase>(() => GetFollowUserUseCase(repository: getIt.call()));
  getIt.registerLazySingleton<GetMusicUseCase>(() => GetMusicUseCase(repository: getIt.call()));
  //repository
  getIt.registerLazySingleton<Repository>(
      () => RepositoryImpl(dataSource: getIt.call()));

  //remote data
  getIt.registerLazySingleton<DataSource>(
      () => DataSourceImpl(api: getIt.call()));

  //External
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => prefs);
}
