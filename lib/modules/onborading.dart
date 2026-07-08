import 'package:budlee_app/config/user/login_and_register/login_screen.dart';
import 'package:budlee_app/core/components/components.dart';
import 'package:budlee_app/utils/shared/network/local/cash_helper.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BoardingModel {
  final String image;
  final String title;
  final String body;

  BoardingModel({required this.image, required this.title, required this.body});
}

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  var boardController = PageController();

  List<BoardingModel> boarding = [
    BoardingModel(
      image: 'assets/images/marketing1.jpg',
      title: 'Get Closer To EveryOne',
      body: 'Helps you to contact everyone with just easy way',
    ),
    BoardingModel(
      image: 'assets/images/marketing2.png',
      title: 'Stay Connected Always',
      body: 'Reach out to your friends and family anytime, anywhere',
    ),
    BoardingModel(
      image: 'assets/images/marketing3.png',
      title: 'Share Your Best Moments',
      body: 'Experience the joy of sharing with your loved ones',
    ),
  ];

  bool isLast = false;

  void submit() {
    setState(() {
      CashHelper.savedData(key: 'onBoarding', value: false);
    });
    navigateToAndFinish(context, Login());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: [
          TextButton(
            onPressed: submit,
            child: Text(
              'SKIP',
              style: TextStyle(
                color: HexColor('#7E22CE'),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: boardController,
                onPageChanged: (int index) {
                  if (index == boarding.length - 1) {
                    setState(() {
                      isLast = true;
                    });
                  } else {
                    setState(() {
                      isLast = false;
                    });
                  }
                },
                itemBuilder: (context, index) =>
                    buildBoardingItem(boarding[index]),
                itemCount: boarding.length,
              ),
            ),
            const SizedBox(height: 40.0),
            SmoothPageIndicator(
              controller: boardController,
              effect: ExpandingDotsEffect(
                dotColor: Colors.grey[300]!,
                activeDotColor: HexColor('#7E22CE'),
                dotHeight: 10,
                expansionFactor: 4,
                dotWidth: 10,
                spacing: 5.0,
              ),
              count: boarding.length,
            ),
            const SizedBox(height: 40.0),
            defaultButton(
              function: () {
                if (isLast) {
                  submit();
                } else {
                  boardController.nextPage(
                    duration: const Duration(milliseconds: 750),
                    curve: Curves.fastLinearToSlowEaseIn,
                  );
                }
              },
              text: isLast ? 'Get Started' : 'Next',
              background: HexColor('#7E22CE'),
              radius: 15.0,
              isUpperCase: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBoardingItem(BoardingModel model) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: Image(image: AssetImage(model.image))),
      const SizedBox(height: 30.0),
      Text(
        model.title,
        style: const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 15.0),
      Text(
        model.body,
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 30.0),
    ],
  );
}
