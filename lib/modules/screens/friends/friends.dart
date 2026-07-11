// ignore: unused_import
import 'dart:io';

import 'package:budlee_app/config/cubit/app_cubit/app_cubit.dart';
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
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = AppCubit.get(context);
        return Scaffold(
          body: ConditionalBuilder(
            condition: cubit.myFriends.isNotEmpty,
            builder: (context) => ListView.separated(
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) =>
                  friendsItemBuilder(context, index),
              separatorBuilder: (context, index) => myDivider2(),
              itemCount: cubit.myFriends.length,
            ),
            fallback: (context) => Center(
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

  Widget friendsItemBuilder(context, index) {
    var cubit = AppCubit.get(context);
    return InkWell(
      onTap: () {
        navigateTo(context, FriendProfile(friendModel: cubit.myFriends[index]));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 31,
              backgroundImage: (cubit.myFriends[index].profileImageFile != null &&
                      cubit.myFriends[index].profileImageFile!.existsSync())
                  ? FileImage(cubit.myFriends[index].profileImageFile!)
                  : customImageProvider(cubit.myFriends[index].image),
            ),
            SizedBox(width: 20),
            Text(
              '${cubit.myFriends[index].name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                cubit.chatItemIndex = index;
                navigateTo(context, MassagesScreen());
              },
              icon: Icon(Icons.message),
            ),
          ],
        ),
      ),
    );
  }
}
