// ignore: unused_import
import 'dart:io';

import 'package:budlee_app/config/cubit/app_cubit/app_bloc.dart';
import 'package:budlee_app/config/cubit/app_cubit/app_states.dart';
import 'package:budlee_app/core/components/components.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../chats/massages_screen.dart';
import 'friend_profile.dart';

class Friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        var bloc = AppBloc.get(context);
        return Scaffold(
          body: ConditionalBuilder(
            condition: bloc.myFriends.isNotEmpty,
            builder: (context) => ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) =>
                  friendsItemBuilder(context, index, bloc),
              separatorBuilder: (context, index) => myDivider2(),
              itemCount: bloc.myFriends.length,
            ),
            fallback: (context) => const Center(
              child: Text(
                'You have no friends yet!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget friendsItemBuilder(context, index, AppBloc bloc) {
    return InkWell(
      onTap: () {
        navigateTo(context, FriendProfile(friendModel: bloc.myFriends[index]));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 31,
              backgroundImage:
                  (bloc.myFriends[index].profileImageFile != null &&
                      bloc.myFriends[index].profileImageFile!.existsSync())
                  ? FileImage(bloc.myFriends[index].profileImageFile!)
                  : customImageProvider(bloc.myFriends[index].image),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                '${bloc.myFriends[index].name}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () {
                bloc.chatItemIndex = index;
                navigateTo(context, MassagesScreen());
              },
              icon: const Icon(Icons.message),
            ),
          ],
        ),
      ),
    );
  }
}
