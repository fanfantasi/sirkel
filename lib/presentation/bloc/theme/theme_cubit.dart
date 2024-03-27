import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(themeMode: ThemeMode.light)) {
    initialAppTheme();
  }
  final String key = "theme";
  bool? _darkTheme;

  void initialAppTheme() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _darkTheme = pref.getBool(key) ?? false;
    _darkTheme!
        ? emit(ThemeState(themeMode: ThemeMode.dark))
        : emit(ThemeState(themeMode: ThemeMode.light));
  }

  void updateAppTheme() async {
    _darkTheme = !_darkTheme!;
    _darkTheme! ? _setTheme(ThemeMode.dark) : _setTheme(ThemeMode.light);
  }

  void _setTheme(ThemeMode themeMode) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, _darkTheme!);
    emit(ThemeState(themeMode: themeMode));
  }
}
