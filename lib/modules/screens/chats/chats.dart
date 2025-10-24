import 'dart:io';

import 'package:budlee_app/core/components/components.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/cubit/app_cubit/app_cubit.dart';
import '../../../config/cubit/app_cubit/app_states.dart';
import 'massages_screen.dart';

class Chats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = AppCubit.get(context);
        return Scaffold(
          body: ConditionalBuilder(
            condition: cubit.users.isNotEmpty,
            builder: (context) => ListView.separated(
              physics: BouncingScrollPhysics(),
              itemBuilder: chatsItemBuilder,
              separatorBuilder: (context, index) => myDivider2(),
              itemCount: cubit.users.length,
            ),
            fallback: (context) => Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget chatsItemBuilder(context, index) {
    var cubit = AppCubit.get(context);
    return InkWell(
      onTap: () {
        cubit.chatItemIndex = index;
        navigateTo(context, MassagesScreen());
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundImage: cubit.users[index].profileImageFile == null
                      ? (cubit.users[index].image.toString().startsWith('http')
                            ? NetworkImage(cubit.users[index].image.toString())
                            : FileImage(
                                File(cubit.users[index].image.toString()),
                              ))
                      : FileImage(cubit.users[index].profileImageFile!),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 3, end: 3),
                  child: Icon(
                    Icons.circle_rounded,
                    color: Colors.green,
                    size: 15,
                  ),
                ),
              ],
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cubit.users[index].name}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight
                        .bold, // You can adjust the font weight as needed
                  ),
                ),
                Text(
                  cubit.lastMessages.isEmpty
                      ? 'Start conversation with ${cubit.users[index].name}'
                      : cubit.lastMessages.last,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
