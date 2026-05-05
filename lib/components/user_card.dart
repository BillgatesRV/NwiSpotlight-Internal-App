import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotlight/common_components/tabbar.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/provider/all_user_profile_provider.dart';
import 'package:spotlight/screens/sub_screens/all_user_profile_screen.dart';
import 'package:spotlight/services/auth_service/auth_storage.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String profileImageUrl;
  final String userGuid;
  final bool isUserLoading;

  UserCard({
    super.key,
    required this.name,
    required this.profileImageUrl,
    required this.userGuid,
    required this.isUserLoading,
  });

  final AuthStorage _authStorage = AuthStorage();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isUserLoading,
      effect: ShimmerEffect(
        baseColor: Color(0xFFE0E0E0),
        highlightColor: Color(0xFFF5F5F5),
      ),
      child: GestureDetector(
        onTap: () async {
          var loggedUserGuid = await _authStorage.getUserGuid();

          if (userGuid == loggedUserGuid) {
            GlassBottomNav.changeTab(2);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => AllUserProfileProvider(),
                  child: AllUserProfileScreen(empGuid: userGuid),
                ),
              ),
            );
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(2.2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: isUserLoading
                      ? null
                      : CachedNetworkImageProvider(profileImageUrl),
                ),
              ),

              SizedBox(height: 10),

              SizedBox(
                width: 85,
                child: Text(
                  isUserLoading ? 'User Loading' : name.capitalize(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Lexend',
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
