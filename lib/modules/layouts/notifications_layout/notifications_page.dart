import 'package:budlee_app/config/cubit/app_cubit/app_cubit.dart';
import 'package:budlee_app/config/cubit/app_cubit/app_states.dart';
import 'package:budlee_app/core/components/components.dart';
import 'package:budlee_app/models/notifications/notification_model.dart';
import 'package:budlee_app/modules/screens/chats/massages_screen.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = AppCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            title: Text('Notifications'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              cubit.getNotifications();
            },
            child: ConditionalBuilder(
              condition: cubit.notifications.isNotEmpty,
              builder: (context) => ListView.separated(
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) =>
                    buildNotificationItem(cubit.notifications[index], context),
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    width: double.infinity,
                    height: 1.0,
                    color: Colors.grey[300],
                  ),
                ),
                itemCount: cubit.notifications.length,
              ),
              fallback: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 100,
                      color: Colors.grey,
                    ),
                    Text(
                      'No Notifications yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildNotificationItem(NotificationModel model, context) {
    IconData icon;
    String text = '';
    Color iconColor;

    switch (model.type) {
      case 'like':
        icon = Icons.favorite;
        text = '${model.senderName} liked your post';
        iconColor = Colors.red;
        break;
      case 'comment':
        icon = Icons.comment;
        text = '${model.senderName} commented on your post';
        iconColor = Colors.blue;
        break;
      case 'reply':
        icon = Icons.reply;
        text = '${model.senderName} replied to your comment';
        iconColor = Colors.green;
        break;
      case 'message':
        icon = Icons.message;
        text = '${model.senderName} sent you a message';
        iconColor = Colors.orange;
        break;
      case 'post':
        icon = Icons.post_add;
        text = '${model.senderName} added a new post';
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.notifications;
        text = 'New notification';
        iconColor = Colors.blue;
    }

    return InkWell(
      onTap: () {
        var cubit = AppCubit.get(context);
        if (model.notificationId != null) {
          cubit.markNotificationAsRead(model.notificationId!);
        }
        if (model.type == 'message') {
          try {
            var user = cubit.users.firstWhere(
              (element) => element.uId == model.senderId,
            );
            cubit.chatItemIndex = cubit.users.indexOf(user);
            navigateTo(context, MassagesScreen());
          } catch (e) {
            print('User not found in users list: $e');
          }
        } else if (model.type == 'like' ||
            model.type == 'comment' ||
            model.type == 'post' ||
            model.type == 'reply') {
          if (model.postId != null) {
            var postIndex = cubit.posts.indexWhere(
              (element) => element.postId == model.postId,
            );
            if (postIndex != -1) {
              cubit.toCommentScreen(context, postIndex);
            }
          }
        }
      },
      child: Container(
        color: (model.isRead ?? false)
            ? Colors.white
            : Colors.blue.withOpacity(0.05),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: Image.network(
                  '${model.senderImage}',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey[600],
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${model.dateTime}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(icon, color: iconColor, size: 25),
          ],
        ),
      ),
    );
  }
}
