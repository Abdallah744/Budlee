// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Ensure LoginCubit is provided by an ancestor widget, for example,
//     // in your main.dart wrapping MaterialApp or your app's root widget.
//     // Example:
//     // BlocProvider(
//     //   create: (context) => LoginCubit(),
//     //   child: MaterialApp(...),
//     // )
//     return BlocConsumer<LoginCubit, LoginStates>(
//       listener: (context, state) {
//         // You can add listeners for specific states if needed,
//         // for example, to show a snackbar on error.
//       },
//       builder: (context, state) {
//         var cubit = LoginCubit.get(context);
//         return Scaffold(
//           appBar: AppBar(
//             title: Text(
//               'Account Details',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             actions: [
//               IconButton(
//                 onPressed: () {
//                   navigateTo(
//                     context,
//                     EditProfileScreen(email: cubit.userProfileData['email']),
//                   );
//                 },
//                 icon: Icon(Icons.edit_outlined, color: Colors.black87),
//               ),
//             ],
//           ),
//           body: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   // Show a loading indicator if data is being fetched and userProfileData is empty
//                   // This example assumes userProfileData is populated after login.
//                   // If state includes a loading state for profile, you can check state here.
//                   if (state is ProfileLoadingAppState &&
//                       cubit.userProfileData.isEmpty)
//                     Center(child: CircularProgressIndicator())
//                   else if (cubit.userProfileData.isEmpty &&
//                       state
//                           is! ProfileSuccessAppState) // Handle case where data might still be empty
//                     Center(
//                       child: Text(
//                         "No profile data found. Please log in again.",
//                       ),
//                     )
//                   else
//                     Column(
//                       children: [
//                         Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 70,
//                               backgroundImage: NetworkImage(
//                                 cubit.userProfileData['avatar'] ??
//                                     'https://via.placeholder.com/150', // Placeholder image
//                               ),
//                             ),
//                             SizedBox(width: 20),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     cubit.userProfileData['name'] ?? 'NA',
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                   Text(
//                                     cubit.userProfileData['email'] ?? 'NA',
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Joined At: ${cubit.userProfileData['creationAt'] ?? 'NA'}',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Last Updated At: ${cubit.userProfileData['updatedAt'] ?? 'NA'}',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 20),
//                         Divider(thickness: 1, color: Colors.grey),
//                         SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Text(
//                               'Account Type: ',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             Text(
//                               cubit.userProfileData['role'] ?? 'NA',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Divider(thickness: 1, color: Colors.grey),
//                         SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Text(
//                               'Phone Number: ',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             Text(
//                               cubit.userProfileData['phone'] ??
//                                   'NA', // Assuming phone can come from data or use previous hardcoded
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Divider(thickness: 1, color: Colors.grey),
//                         SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Text(
//                               'Address: ',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             Text(
//                               cubit.userProfileData['address'] ??
//                                   'NA', // Assuming address can come from data
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Divider(thickness: 1, color: Colors.grey),
//                         SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Text(
//                               'Gender: ',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             Text(
//                               '${cubit.userProfileData['gender'] ?? 'NA'}', // Assuming gender can come from data
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Divider(thickness: 1, color: Colors.grey),
//                         SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Text(
//                               'Birthday: ',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             Text(
//                               cubit.userProfileData['birthday'] ??
//                                   'NA', // Assuming birthday can come from data
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Divider(thickness: 1, color: Colors.grey),
//                         SizedBox(height: 50),
//                         defaultButton(
//                           function: () {
//                             navigateToAndFinish(context, LoginScreen());
//                           },
//                           text: 'Log Out',
//                           background: Colors.blueAccent,
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
