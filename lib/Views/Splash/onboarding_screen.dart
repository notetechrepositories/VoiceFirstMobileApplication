import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:voicefirst/Views/LoginPage/login_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      pages: [
        _buildPage(
          title: "Voice First",
          body:
              "Smart, Real-Time Issue Reporting & Resolution powered by Notetech Software",
          imagePath: "assets/OnBoardingImage/1.png",
        ),
        _buildPage(
          title: "AI-Powered Insights",
          body:
              "Leverage artificial intelligence to uncover actionable insights.",
          imagePath: "assets/OnBoardingImage/2.png",
        ),
        _buildPage(
          title: "Automated Reports",
          body:
              "Generate reports automatically for data-driven decision making.",
          imagePath: "assets/OnBoardingImage/3.png",
        ),
        _buildPage(
          title: "Real-Time Alerts & Escalations",
          body:
              "Notify the right personnel instantly for quick action and escalation.",
          imagePath: "assets/OnBoardingImage/4.png",
        ),
      ],
      onDone: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      ),
      onSkip: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      ),
      showSkipButton: true,
      skip: const Text(
        "Skip",
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
      next: const Icon(Icons.arrow_forward, color: Colors.black),
      done: const Text(
        "Done",
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: const Size(22.0, 10.0),
        activeColor: Colors.yellow,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  PageViewModel _buildPage({
    required String title,
    required String body,
    required String imagePath,
  }) {
    return PageViewModel(
      titleWidget: SizedBox.shrink(),
      bodyWidget: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative background
          Positioned(
            top: 0,
            left: -60,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              // Image floating above the card
              SizedBox(
                height: 250,
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 40),
              // Card container for text
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 3, width: 40, color: Colors.yellow),
                    const SizedBox(height: 20),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade300,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      decoration: PageDecoration(
        imagePadding: EdgeInsets.zero,
        contentMargin: EdgeInsets.zero,
        bodyAlignment: Alignment.center,
        boxDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.yellow.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}
