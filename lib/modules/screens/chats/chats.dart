// ignore: unused_import
import 'dart:io';

import 'package:budlee_app/core/components/components.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../config/cubit/app_cubit/app_bloc.dart';
import '../../../config/cubit/app_cubit/app_states.dart';
import 'massages_screen.dart';

class Chats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        var bloc = AppBloc.get(context);
        return Scaffold(
          body: ConditionalBuilder(
            condition: bloc.users.isNotEmpty,
            builder: (context) => ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) =>
                  chatsItemBuilder(context, index, bloc),
              separatorBuilder: (context, index) => myDivider2(),
              itemCount: bloc.users.length,
            ),
            fallback: (context) =>
                const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget chatsItemBuilder(context, index, AppBloc bloc) {
    return InkWell(
      onTap: () {
        bloc.chatItemIndex = index;
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
                  backgroundImage:
                      (bloc.users[index].profileImageFile != null &&
                          bloc.users[index].profileImageFile!.existsSync())
                      ? FileImage(bloc.users[index].profileImageFile!)
                      : customImageProvider(bloc.users[index].image),
                  onBackgroundImageError:
                      (bloc.users[index].profileImageFile != null &&
                              bloc.users[index].profileImageFile!
                                  .existsSync() ||
                          customImageProvider(bloc.users[index].image) != null)
                      ? (exception, stackTrace) {}
                      : null,
                  backgroundColor: Colors.grey[200],
                ),
                const Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 3, end: 3),
                  child: Icon(
                    Icons.circle_rounded,
                    color: Colors.green,
                    size: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${bloc.users[index].name}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (bloc.lastMessagesMap.containsKey(
                            bloc.users[index].uId,
                          ) &&
                          bloc
                                  .lastMessagesMap[bloc.users[index].uId]!
                                  .massageDate !=
                              null)
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            _getFormattedLastMessageDate(
                              DateTime.parse(
                                bloc
                                    .lastMessagesMap[bloc.users[index].uId]!
                                    .massageDate!,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    _getLastMessageText(bloc, index),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
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

  String _getLastMessageText(AppBloc bloc, int index) {
    final userId = bloc.users[index].uId;
    if (!bloc.lastMessagesMap.containsKey(userId)) {
      return 'Start conversation with ${bloc.users[index].name}';
    }

    final lastMsg = bloc.lastMessagesMap[userId]!;
    if (lastMsg.voiceMassage != null) {
      return '🎤 Voice message';
    }
    return lastMsg.massageText ?? '';
  }
}
