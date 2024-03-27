import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(index: 0));

  void getNavBarItem(int index) {
    switch (index) {
      case 0:
        emit(const NavigationState(index: 0));
        break;
      case 1:
        emit(const NavigationState(index: 1));
        break;
      case 2:
        emit(const NavigationState(index: 2));
        break;
      case 3:
        emit(const NavigationState(index: 3));
        break;
      case 4:
        emit(const NavigationState(index: 4));
        break;
    }
  }
}
