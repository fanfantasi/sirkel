import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/core/widgets/debouncer.dart';
import 'package:screenshare/core/widgets/loadmore.dart';
import 'package:screenshare/domain/entities/follow_entity.dart';
import 'package:screenshare/presentation/bloc/user/follow/follow_cubit.dart';

class MentionsWidget extends StatefulWidget {
  final List<ResultFollowEntity> tagPeople;
  const MentionsWidget({super.key, required this.tagPeople});

  @override
  State<MentionsWidget> createState() => _MentionsWidgetState();
}

class _MentionsWidgetState extends State<MentionsWidget> {
  final TextEditingController textController = TextEditingController();
  late StreamSubscription<FollowState> userStream;
  List<ResultFollowEntity> resultUser = [];
  int page = 1;

  final debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    getFollow();
    super.initState();
  }

  @override
  void dispose() {
    userStream.cancel();
    resultUser.clear();
    super.dispose();
  }

  void getFollow() async {
    resultUser.clear();
    for (var e in widget.tagPeople) {
      resultUser.add(e);
    }
    context.read<FollowCubit>().getFollow(name: textController.text, page: page);
    userStream = context.read<FollowCubit>().stream.listen((event) {
      if (event is FollowLoaded) {
        for (var e in event.follow.data ?? []) {
          if (resultUser.where((f) => f.id == e.id).isEmpty) {
            resultUser.insert(0, e);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        maxChildSize: .9,
        initialChildSize: 0.5,
        builder: (_, controller) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 0.25,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 12.0,
                    ),
                    child: Container(
                      height: 3.0,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(2.5)),
                      ),
                    ),
                  ),
                ),
                Text(
                  'tag people'.tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 38,
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(fontSize: 14),
                      hintText: 'search peoples'.tr(),
                      suffixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                    ),
                    onChanged: (value) => {
                      debouncer.run(() {  
                        getFollow();
                      })
                    },
                  ),
                ),
                Flexible(
                  child: BlocBuilder<FollowCubit, FollowState>(
                      builder: (context, state) {
                    if (state is FollowLoading) {
                      return const Center(
                        child: LoadingWidget(),
                      );
                    }
                    return ListView.separated(
                      separatorBuilder: (context, i) =>
                          const Divider(height: 1),
                      itemCount: resultUser.length,
                      physics: const BouncingScrollPhysics(),
                      controller: controller,
                      itemBuilder: (context, i) {
                        return ListTile(
                          minLeadingWidth: 0,
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            radius: 18,
                            child: ClipOval(
                                child: Image.network(
                              resultUser[i].user?.avatar ?? '',
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/icons/ic-user.png',
                                  width: 24,
                                  height: 24,
                                );
                              },
                            )),
                          ),
                          title: Text(
                            '@${resultUser[i].user?.username ?? ''}',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 14),
                          ),
                          trailing: (resultUser[i].user?.selected ?? false)
                              ? const Icon(
                                  Icons.close,
                                )
                              : const SizedBox.shrink(),
                          onTap: () {
                            setState(() {
                              resultUser[i].user?.selected =
                                  !(resultUser[i].user?.selected ?? false);
                            });
                          },
                        );
                      },
                    );
                  }),
                ),
                if (resultUser.isNotEmpty)
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 18.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, resultUser.where((el) => el.user?.selected==true).toList());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.onBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12.0),
                      child: Text(
                        'Ok',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
