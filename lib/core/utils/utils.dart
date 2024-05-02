import 'package:path_provider/path_provider.dart';

class Utilitas {
  static String scrolling = 'stopped';
  static bool isMute = true;
  static List<String> likeListTapScreen = [];
  static int page = 1;
  static bool isRefreshPage = false;
  static bool isInitialPage = true;
  static bool isLastPage = false;
  static bool isLoadMore = false;
  static bool scrollUp = false;
  static bool scrollDown = true;
  static Map currentUser = {};
  static bool jumpToTop = false;
}