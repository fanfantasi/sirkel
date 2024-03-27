import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshare/domain/entities/user_entity.dart';
import 'package:screenshare/presentation/bloc/user/user_cubit.dart';
import 'package:shimmer/shimmer.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late StreamSubscription<UserState> userStream;
  UserEntity? user;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((v) async {
      getCurrentUser();
    });
    super.initState();
  }

  void getCurrentUser() async {
    context.read<UserCubit>().getCurrentUser();
    if (!mounted) return;

    userStream = context.read<UserCubit>().stream.listen((event) {
      if (event is UserLoaded) {
        user = event.user;
      }
    });
  }

  @override
  void dispose() {
    userStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(builder: (context, state) {
      // if (state is UserLoading) {
      //   return SizedBox(
      //     height: MediaQuery.of(context).size.height - (kToolbarHeight * 2),
      //     child: const Center(child: LoadingWidget()));
      // }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                userAvatar(state),
                countWidget(label: 'posts'.tr(), count: '${user?.data?.count?.posts??0}'),
                countWidget(label: 'followers'.tr(), count: '${user?.data?.count?.followers??0}'),
                countWidget(label: 'following'.tr(), count: '${user?.data?.count?.following??0}'),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              user?.data?.name??'Loading ...',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16),
            ),
            const SizedBox(
              height: 5,
            ),
            ExpandableText(
              'Bio Profile app_time_stats: avg=1546.96ms min=1546.96ms max=1546.96ms count=1 Easy Localization] [WARNING] Localization key [Edit profile] not found',
              expandText: 'more',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
              collapseText: 'less',
              expandOnTextTap: true,
              collapseOnTextTap: true,
              maxLines: 2,
              linkColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)),
                        side: BorderSide(
                          width: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Text('Edit profile'.tr(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w400,
                          )),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                SizedBox(
                  height: 38,
                  width: 50,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3)),
                      side: BorderSide(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.person_add,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget userAvatar(UserState state) {
    if (state is UserLoading){
      return SizedBox(
        height: 75,
        width: 75,
        child: Shimmer.fromColors(
          baseColor: Colors.black45,
          highlightColor: Colors.white,
          child: Container(
            height: 75,
            width: 75,
            decoration: const BoxDecoration(
              color: Colors.black12,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Container(
      height: 75,
      width: 75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: NetworkImage(user?.data?.avatar ?? ''),
            fit: BoxFit.cover),
      ),
    );
  }

  Widget countWidget({String? label, String? count}) {
    return Column(
      children: [
        Text(
          count??'0',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          label??'label',
          style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14),
        ),
      ],
    );
  }
}
