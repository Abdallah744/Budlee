// ignore_for_file: unnecessary_import, unused_import, unnecessary_null_comparison
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icons_flutter/icons_flutter.dart';

import '../../config/cubit/app_cubit/app_cubit.dart';
import '../../models/posts/posts_model.dart';
import '../constants/constants.dart';

Widget defaultTextFormField({
  required TextEditingController controller,
  required TextInputType type,
  required String? Function(String?) validate,
  required String label,
  Function? onTab,
  required IconData suffix,
}) => TextFormField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(textFormRadius),
    ),
    labelText: label,
    suffixIcon: Icon(suffix),
  ),
  keyboardType: type,
  controller: controller,
  onTap: onTab as void Function()?,
  validator: validate,
);
// login or register button
Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  bool isUpperCase = true,
  double radius = 10.0,
  required Function() function,
  required String text,
}) => Container(
  width: width,
  height: 40.0,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(buttonRadius),
    color: background,
  ),
  child: MaterialButton(
    onPressed: function,
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);
// password FormFiled Box
Widget passwordTextFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function? onSubmit,
  Function? onTap,
  required bool isPassword,
  required String? Function(String?) validate,
  required String label,
  required Widget prefix,
  Widget suffix = const Icon(Icons.remove_red_eye),
  required Function() suffixPressed,
  bool isClickable = true,
}) => TextFormField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(textFormRadius),
    ),
    labelText: label,
    prefixIcon: prefix,
    suffixIcon: IconButton(onPressed: suffixPressed, icon: suffix),
  ),
  keyboardType: type,
  controller: controller,
  validator: validate,
  obscureText: isPassword,
);
// email FormFiled Box
Widget emailTextFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function? onSubmit,
  Function? onTap,
  required String? Function(String?) validate,
  required String label,
  required Widget prefix,
  bool isClickable = true,
}) => TextFormField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(textFormRadius),
    ),
    labelText: label,
    prefixIcon: prefix,
  ),
  keyboardType: type,
  validator: validate,
  controller: controller,
);
// name FormFiled Box
Widget nameTextFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function? onSubmit,
  Function? onTap,
  String? hint,
  required String? Function(String?) validate,
  required String label,
  bool isClickable = true,
}) => TextFormField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(textFormRadius),
    ),
    labelText: label,
    hintText: hint,
  ),
  keyboardType: type,
  controller: controller,
  validator: validate,
);

Widget commentTextFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function? onSubmit,
  Function? onTap,
  String? hint,
  required String? Function(String?) validate,
  required String label,
  bool isClickable = true,
}) => TextFormField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(textFormRadius),
      borderSide: BorderSide(color: Colors.white),
    ),
    labelText: label,
    hintText: hint,
  ),
  keyboardType: type,
  controller: controller,
  validator: validate,
);

Widget dateTextFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function? onSubmit,
  required Function onTap,
  String? hint,
  required String? Function(String?) validate,
  required String label,
  bool isClickable = true,
}) => TextFormField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(textFormRadius),
    ),
    labelText: label,
    hintText: hint,
    suffix: Icon(Icons.calendar_month_outlined),
  ),
  keyboardType: type,
  onTap: onTap as void Function(),
  controller: controller,
  validator: validate,
);

// Article Item Builder
Widget articleItemBuilder(article, context) => InkWell(
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage('''${article['urlToImage']}'''),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Container(
            height: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '''${article['title']}''',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10),
                Text(
                  '''Published At: ${article['publishedAt']}''',
                  style: TextStyle(fontSize: 12, color: Colors.deepOrange),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
);

void navigateTo(BuildContext context, Widget widget) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
}

void navigateToAndFinish(BuildContext context, Widget widget) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => widget),
    (route) => false,
  );
}

void showToast({required String text, required ToastStates state}) =>
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 5,
      backgroundColor: chooseToastColor(state),
      textColor: Colors.white,
      fontSize: 16.0,
    );

enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastColor(ToastStates state) {
  Color color;
  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }
  return color;
}

Widget myDivider() => Padding(
  padding: EdgeInsets.zero,
  child: Container(
    width: double.infinity,
    height: 1.0,
    color: Colors.grey[400],
  ),
);
Widget myDivider2() => Padding(
  padding: const EdgeInsetsDirectional.only(start: 8.0, end: 8),
  child: Container(
    width: double.infinity,
    height: 1.0,
    color: Colors.grey[800],
  ),
);

// Warning massage
Widget defaultWarningMassage({
  required String warningText,
  required String text,
  required Function() function,
}) => Container(
  color: Colors.amber,
  child: Padding(
    padding: const EdgeInsets.all(15.0),
    child: Row(
      children: [
        Icon(Icons.info_outline, color: Colors.black, size: 26),
        SizedBox(width: 15),
        Text(warningText, style: TextStyle(fontSize: 18)),
        Spacer(),
        TextButton(
          onPressed: function,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    ),
  ),
);

PreferredSizeWidget defaultAppBar({
  required BuildContext context,
  required String title,
  List<Widget>? actions,
  TextStyle? titleTextStyle,
}) => AppBar(
  leading: IconButton(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: Icon(Icons.arrow_back_ios_new),
  ),
  title: Text(title, style: titleTextStyle),
  titleSpacing: 0.0,
  actions: actions,
);

Widget galleryItemBuilder(List<File?> productsModel, context) =>
    SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
            childAspectRatio: 1 / 1.93,
            children: List.generate(
              productsModel.length,
              (index) => buildGridGallery(productsModel, index, context),
            ),
          ),
        ],
      ),
    );

Widget buildGridGallery(List<File?> model, index, context) {
  var cubit = AppCubit.get(context);
  ImageProvider? galleryImageProvider;

  // Safely access imagesOfGallery
  if (cubit.model != null &&
      cubit.model!.imagesOfGallery != null &&
      index < cubit.model!.imagesOfGallery!.length &&
      cubit.model!.imagesOfGallery![index] != null) {
    final imagePath = cubit.model!.imagesOfGallery![index].path;
    if (imagePath.startsWith('http')) {
      galleryImageProvider = NetworkImage(imagePath);
    } else {
      galleryImageProvider = FileImage(File(imagePath));
    }
  } else if (cubit.model != null &&
      cubit.model!.coverImage != null &&
      cubit.model!.coverImage!.isNotEmpty) {
    // Fallback to coverImage if imagesOfGallery is not available or item is null
    if (cubit.model!.coverImage!.startsWith('http')) {
      galleryImageProvider = NetworkImage(cubit.model!.coverImage!);
    } else {
      galleryImageProvider = FileImage(File(cubit.model!.coverImage!));
    }
  }

  return InkWell(
    onTap: () {},
    child: Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Added to align text to the start
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            // Wrap Image with Expanded
            child: galleryImageProvider != null
                ? Image(
                    image: galleryImageProvider,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    // Placeholder for when image is not available
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}
