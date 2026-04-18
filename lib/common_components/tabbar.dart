import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotlight/screens/mainScreens/home_page.dart';
import 'package:spotlight/screens/mainScreens/profile_page.dart';
import 'package:spotlight/screens/mainScreens/upload_page.dart';

class GlassBottomNav extends StatefulWidget {
  const GlassBottomNav({super.key});
  static late Function(int index) changeTab;
  @override
  State<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends State<GlassBottomNav> {
  int currentIndex = 0;

  final List<Widget> screens = [HomePage(), UploadPage(), ProfilePage()];
  @override
  void initState() {
    super.initState();

    GlassBottomNav.changeTab = (index) {
      setState(() {
        currentIndex = index;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IndexedStack(index: currentIndex, children: screens),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: Color(0xff1c1c1ca).withAlpha(30),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      navItem(
                        "assets/images/home.svg",
                        "assets/images/home_filled.svg",
                        0,
                      ),
                      navItem(Icons.add_box_outlined, Icons.add_box_rounded, 1),
                      navItem(
                        "assets/images/user_profile.svg",
                        "assets/images/user_profile_filled.svg",
                        2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget navItem(dynamic unSeletedIcon, dynamic selectedIcon, int index) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: unSeletedIcon.runtimeType == IconData
            ? isSelected
                  ? Icon(selectedIcon, size: 27)
                  : Icon(unSeletedIcon, size: 28, color: Colors.grey)
            : isSelected
            ? SvgPicture.asset(selectedIcon, height: 24, width: 24)
            : SvgPicture.asset(unSeletedIcon, height: 24, width: 24),
      ),
    );
  }
}
