import 'package:budlee_app/core/components/components.dart';
import 'package:budlee_app/models/massages/massage_model.dart';
import 'package:budlee_app/modules/screens/chats/voice_message_player.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../config/cubit/app_cubit/app_bloc.dart';
import '../../../config/cubit/app_cubit/app_event.dart';
import '../../../config/cubit/app_cubit/app_states.dart';

class MassagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        var bloc = AppBloc.get(context);
        bloc.add(
          AppGetMassagesEvent(
            massageReceiverId: bloc.users[bloc.chatItemIndex].uId,
          ),
        );
        return BlocConsumer<AppBloc, AppState>(
          listener: (context, state) {
            if (state is UploadVoiceMessageErrorState) {
              showToast(text: state.error, state: ToastStates.ERROR);
            }
            if (state is SendMessageErrorState) {
              showToast(text: state.error, state: ToastStates.ERROR);
            }
          },
          builder: (context, state) {
            var bloc = AppBloc.get(context);
            return Scaffold(
              appBar: AppBar(
                leading: CircleAvatar(
                  radius: 21,
                  backgroundImage: customImageProvider(
                    bloc.users[bloc.chatItemIndex].image,
                  ),
                  onBackgroundImageError:
                      customImageProvider(
                            bloc.users[bloc.chatItemIndex].image,
                          ) !=
                          null
                      ? (exception, stackTrace) {}
                      : null,
                  backgroundColor: Colors.grey[200],
                ),
                title: Text(
                  bloc.users[bloc.chatItemIndex].name.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.video_call),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.phone)),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      bloc.chatItemIndex = null;
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ConditionalBuilder(
                      condition: bloc.model != null,
                      builder: (context) => RefreshIndicator(
                        onRefresh: () async {
                          bloc.add(
                            AppGetMassagesEvent(
                              massageReceiverId:
                                  bloc.users[bloc.chatItemIndex].uId,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: bloc.massages.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.7,
                                      child: Center(
                                        child: Text(
                                          'Start conversation with ${bloc.users[bloc.chatItemIndex].name}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var massage = bloc.massages[index];
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
                                        DateTime
                                        prevMessageDate = DateTime.parse(
                                          bloc.massages[index - 1].massageDate!,
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
                                    if (bloc.model!.uId ==
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
                                                style: const TextStyle(
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
                                      const SizedBox(height: 20),
                                  itemCount: bloc.massages.length,
                                ),
                        ),
                      ),
                      fallback: (context) =>
                          const Center(child: CircularProgressIndicator()),
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
                            child: bloc.isRecording
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.fiber_manual_record,
                                          color: Colors.red,
                                          size: 15,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Recording ${bloc.recordingDuration}s',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : TextFormField(
                                    controller: bloc.massageController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Type a message',
                                    ),
                                  ),
                          ),
                          Container(
                            height: 50,
                            color: bloc.isRecording
                                ? Colors.red
                                : Colors.grey[600],
                            child: GestureDetector(
                              onTap: () {
                                if (bloc.isRecording) {
                                  bloc.add(
                                    AppStopRecordingEvent(
                                      bloc.users[bloc.chatItemIndex].uId!,
                                    ),
                                  );
                                } else {
                                  bloc.add(AppStartRecordingEvent());
                                }
                              },
                              onLongPress: () {
                                bloc.add(AppStartRecordingEvent());
                              },
                              onLongPressEnd: (details) {
                                bloc.add(
                                  AppStopRecordingEvent(
                                    bloc.users[bloc.chatItemIndex].uId!,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Icon(
                                  bloc.isRecording ? Icons.stop : Icons.mic,
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
                                bloc.add(
                                  AppSendMassageEvent(
                                    massageReceiverId:
                                        bloc.users[bloc.chatItemIndex].uId,
                                    massageText: bloc.massageController.text,
                                  ),
                                );
                                bloc.massageController.clear();
                              },
                              minWidth: 1,
                              child: const Icon(
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
        decoration: const BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(10),
            topEnd: Radius.circular(10),
            topStart: Radius.circular(10),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            if (formattedTime.isNotEmpty)
              Text(
                formattedTime,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
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
          borderRadius: const BorderRadiusDirectional.only(
            bottomStart: Radius.circular(10),
            topEnd: Radius.circular(10),
            topStart: Radius.circular(10),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            if (formattedTime.isNotEmpty)
              Text(
                formattedTime,
                style: const TextStyle(color: Colors.black54, fontSize: 10),
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
