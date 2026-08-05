import 'package:budlee_app/core/components/components.dart';
import 'package:budlee_app/models/massages/massage_model.dart';
import 'package:budlee_app/modules/screens/chats/voice_message_player.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../config/cubit/app_cubit/app_cubit.dart';
import '../../../config/cubit/app_cubit/app_states.dart';

class MassagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        AppCubit.get(context).getMassages(
          massageReceiverId: AppCubit.get(
            context,
          ).users[AppCubit.get(context).chatItemIndex].uId,
        );
        return BlocConsumer<AppCubit, AppState>(
          listener: (context, state) {
            if (state is UploadVoiceMessageErrorState) {
              showToast(text: state.error, state: ToastStates.ERROR);
            }
            if (state is SendMessageErrorState) {
              showToast(text: state.error, state: ToastStates.ERROR);
            }
          },
          builder: (context, state) {
            var cubit = AppCubit.get(context);
            return Scaffold(
              appBar: AppBar(
                leading: CircleAvatar(
                  radius: 21,
                  backgroundImage: customImageProvider(
                    cubit.users[cubit.chatItemIndex].image,
                  ),
                  onBackgroundImageError: customImageProvider(
                            cubit.users[cubit.chatItemIndex].image,
                          ) !=
                          null
                      ? (exception, stackTrace) {}
                      : null,
                  backgroundColor: Colors.grey[200],
                ),
                title: Text(
                  cubit.users[cubit.chatItemIndex].name.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.video_call)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.phone)),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      cubit.chatItemIndex = null;
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ConditionalBuilder(
                      condition: cubit.model != null,
                      builder: (context) => RefreshIndicator(
                        onRefresh: () async {
                          cubit.getMassages(
                            massageReceiverId:
                                cubit.users[cubit.chatItemIndex].uId,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: cubit.massages.isEmpty
                              ? ListView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.7,
                                      child: Center(
                                        child: Text(
                                          'Start conversation with ${cubit.users[cubit.chatItemIndex].name}',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.separated(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var massage = cubit.massages[index];
                                    bool showDateHeader = false;
                                    String dateHeader = '';

                                    if (massage.massageDate != null) {
                                      DateTime messageDate = DateTime.parse(
                                        massage.massageDate!,
                                      );
                                      if (index == 0) {
                                        showDateHeader = true;
                                        dateHeader = _getDateHeader(
                                          messageDate,
                                        );
                                      } else {
                                        DateTime prevMessageDate =
                                            DateTime.parse(
                                              cubit
                                                  .massages[index - 1]
                                                  .massageDate!,
                                            );
                                        if (messageDate.year !=
                                                prevMessageDate.year ||
                                            messageDate.month !=
                                                prevMessageDate.month ||
                                            messageDate.day !=
                                                prevMessageDate.day) {
                                          showDateHeader = true;
                                          dateHeader = _getDateHeader(
                                            messageDate,
                                          );
                                        }
                                      }
                                    }

                                    Widget messageWidget;
                                    if (cubit.model!.uId ==
                                        massage.massageSenderId) {
                                      messageWidget = massageMyItemBuilder(
                                        massage,
                                      );
                                    } else {
                                      messageWidget = massageItemBuilder(
                                        massage,
                                      );
                                    }

                                    if (showDateHeader) {
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 20.0,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                dateHeader,
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          messageWidget,
                                        ],
                                      );
                                    }
                                    return messageWidget;
                                  },
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 20),
                                  itemCount: cubit.massages.length,
                                ),
                        ),
                      ),
                      fallback: (context) =>
                          Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, width: 1.0),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Row(
                        children: [
                          Expanded(
                            child: cubit.isRecording
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.fiber_manual_record,
                                          color: Colors.red,
                                          size: 15,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Recording ${cubit.recordingDuration}s',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : TextFormField(
                                    controller: cubit.massageController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Type a message',
                                    ),
                                  ),
                          ),
                          Container(
                            height: 50,
                            color: cubit.isRecording
                                ? Colors.red
                                : Colors.grey[600],
                            child: GestureDetector(
                              onTap: () {
                                if (cubit.isRecording) {
                                  cubit.stopRecording(
                                    receiverId:
                                        cubit.users[cubit.chatItemIndex].uId!,
                                  );
                                } else {
                                  cubit.startRecording();
                                }
                              },
                              onLongPress: () {
                                cubit.startRecording();
                              },
                              onLongPressEnd: (details) {
                                cubit.stopRecording(
                                  receiverId:
                                      cubit.users[cubit.chatItemIndex].uId!,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Icon(
                                  cubit.isRecording ? Icons.stop : Icons.mic,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            color: Colors.blueAccent[400],
                            child: MaterialButton(
                              onPressed: () {
                                cubit.sendMassage(
                                  massageReceiverId:
                                      cubit.users[cubit.chatItemIndex].uId,
                                  massageText: cubit.massageController.text,
                                );
                                cubit.massageController.clear();
                              },
                              minWidth: 1,
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget massageItemBuilder(MassageModel? massageModel) {
    String formattedTime = '';
    if (massageModel?.massageDate != null) {
      try {
        formattedTime = DateFormat.jm().format(
          DateTime.parse(massageModel!.massageDate!),
        );
      } catch (e) {
        formattedTime = '';
      }
    }

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[500],
          borderRadius: BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(10),
            topEnd: Radius.circular(10),
            topStart: Radius.circular(10),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (massageModel?.voiceMassage != null)
              VoiceMessagePlayer(
                url: massageModel!.voiceMassage!,
                isMyMessage: false,
              )
            else
              Text(
                '${massageModel!.massageText}',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            if (formattedTime.isNotEmpty)
              Text(
                formattedTime,
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }

  Widget massageMyItemBuilder(MassageModel? massageModel) {
    String formattedTime = '';
    if (massageModel?.massageDate != null) {
      try {
        formattedTime = DateFormat.jm().format(
          DateTime.parse(massageModel!.massageDate!),
        );
      } catch (e) {
        formattedTime = '';
      }
    }

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadiusDirectional.only(
            bottomStart: Radius.circular(10),
            topEnd: Radius.circular(10),
            topStart: Radius.circular(10),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (massageModel?.voiceMassage != null)
              VoiceMessagePlayer(
                url: massageModel!.voiceMassage!,
                isMyMessage: true,
              )
            else
              Text(
                '${massageModel!.massageText}',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            if (formattedTime.isNotEmpty)
              Text(
                formattedTime,
                style: TextStyle(color: Colors.black54, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }
    return DateFormat.yMMMMd().format(date);
  }
}
