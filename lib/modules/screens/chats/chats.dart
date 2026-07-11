// ignore: unused_import
import 'dart:io';

import 'package:budlee_app/core/components/components.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
                  backgroundImage: (cubit.users[index].profileImageFile != null &&
                          cubit.users[index].profileImageFile!.existsSync())
                      ? FileImage(cubit.users[index].profileImageFile!)
                      : customImageProvider(cubit.users[index].image),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${cubit.users[index].name}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      if (cubit.lastMessagesMap.containsKey(
                            cubit.users[index].uId,
                          ) &&
                          cubit
                                  .lastMessagesMap[cubit.users[index].uId]!
                                  .massageDate !=
                              null)
                        Text(
                          _getFormattedLastMessageDate(
                            DateTime.parse(
                              cubit
                                  .lastMessagesMap[cubit.users[index].uId]!
                                  .massageDate!,
                            ),
                          ),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                  Text(
                    _getLastMessageText(cubit, index),
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedLastMessageDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return DateFormat.jm().format(date);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat.E().format(date);
    } else {
      return DateFormat.yMd().format(date);
    }
  }

  String _getLastMessageText(AppCubit cubit, int index) {
    final userId = cubit.users[index].uId;
    if (!cubit.lastMessagesMap.containsKey(userId)) {
      return 'Start conversation with ${cubit.users[index].name}';
    }

    final lastMsg = cubit.lastMessagesMap[userId]!;
    if (lastMsg.voiceMassage != null) {
      return '🎤 Voice message';
    }
    return lastMsg.massageText ?? '';
  }
}
