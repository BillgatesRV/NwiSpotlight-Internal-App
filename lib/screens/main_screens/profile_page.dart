import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/models/user_all_media_response.dart';
import 'package:spotlight/provider/profile_provider.dart';
import 'package:spotlight/provider/user_post_provider.dart';
import 'package:spotlight/screens/sub_screens/user_post_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<ProfileProvider>(context, listen: false).initialize();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ProfileProvider>().fetchFeeds();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>(); 

    if (profileProvider.isLoading) {
      return Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: Color(0xFFE0E0E0),
          highlightColor: Color(0xFFF5F5F5),
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: _profileBody(
            context,
            scrollController: _scrollController,
            name: "",
            designation: "",
            employeeId: "",
            dojInYears: "",
            profileImage: "",
            userMedia: dummyData,
            employeeGuid: "",
            coverImageUrl: "",
            isCoverLoading: true,
            profileProvider: null,
          ),
        ),
      );
    }

    if (profileProvider.profileDate == null) {
      final data = profileProvider.profileDate;
      return Scaffold(
        backgroundColor: Colors.white,
        body: _profileBody(
          context,
          scrollController: _scrollController,
          name: data?.employeeName ?? "",
          designation: data?.designation ?? "",
          employeeId: data?.employeeId ?? "",
          dojInYears: data?.dojInYears ?? "",
          profileImage: data?.profileImage ?? "",
          userMedia: profileProvider.userMedia,
          employeeGuid: data?.employeeGuid ?? "",
          coverImageUrl: data?.coverImageUrl ?? "",
          isCoverLoading: false,
          profileProvider: profileProvider,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _profileBody(
        context,
        scrollController: _scrollController,
        name: profileProvider.profileDate!.employeeName,
        designation: profileProvider.profileDate!.designation,
        employeeId: profileProvider.profileDate!.employeeId,
        dojInYears: profileProvider.profileDate!.dojInYears,
        profileImage: profileProvider.profileDate!.profileImage,
        userMedia: profileProvider.userMedia,
        employeeGuid: profileProvider.profileDate!.employeeGuid,
        coverImageUrl: profileProvider.profileDate!.coverImageUrl ?? "",
        isCoverLoading: profileProvider.isCoverImgLoading,
        profileProvider: profileProvider,
      ),
    );
  }

  Widget _profileBody(
    BuildContext context, {
    required scrollController,
    required String name,
    required String designation,
    required String employeeId,
    required String dojInYears,
    required String profileImage,
    required List<UserAllMediaResponse> userMedia,
    required String employeeGuid,
    required String coverImageUrl,
    required bool isCoverLoading,
    required profileProvider,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 45),
      child: Column(
        children: [
          Stack(
            alignment: AlignmentGeometry.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onDoubleTap: () async {
                  await profileProvider.pickCoverImage(context);
                },
                child: Skeletonizer(
                  enabled: isCoverLoading,
                  effect: ShimmerEffect(
                    baseColor: const Color(0xFFD0D5DD),
                    highlightColor: const Color(0xFFEAF3FF),
                    duration: Duration(milliseconds: 1500),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      image: DecorationImage(
                        image: coverImageUrl.isNotEmpty
                            ? (coverImageUrl.startsWith('http'))
                                  ? NetworkImage(coverImageUrl)
                                  : FileImage(File(coverImageUrl))
                            : const AssetImage(
                                'assets/images/profile_cover.jpg',
                              ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 6,
                child: GestureDetector(
                  onTap: () async {
                    final isLogout = await Helpers.showDialogAlert(
                      context,
                      title: "Logout",
                      content: "Are you sure you want to logout?",
                      accept: "Yes",
                      reject: "No",
                    );
                    if (isLogout == true &&
                        profileProvider != null &&
                        !profileProvider.isLoading) {
                      await profileProvider.logout(context);
                    }
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Colors.grey.shade400,
                          spreadRadius: 0.1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      'assets/images/logout_icon.svg',
                      height: 18,
                      width: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFE0E0E0),
                    backgroundImage: profileImage.isNotEmpty
                        ? CachedNetworkImageProvider(profileImage)
                        : AssetImage('assets/images/user_profile.jpg')
                              as ImageProvider,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 70),
          Text(
            name.isNotEmpty ? name.capitalize() : "User",
            style: TextStyle(
              fontFamily: "Lexend",
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              designation.isNotEmpty ? designation.capitalize() : "Developer",
              style: TextStyle(
                fontFamily: "Lexend",
                fontSize: 13,
                fontWeight: FontWeight.w400,
                overflow: TextOverflow.clip,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 25),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  spacing: 4,
                  children: [
                    Text(
                      employeeId.isNotEmpty ? employeeId : "NWIUSER",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Employee Id",
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                VerticalDivider(
                  width: 15,
                  radius: BorderRadius.circular(10),
                  thickness: 1,
                  color: Colors.grey[500],
                ),

                Column(
                  spacing: 4,
                  children: [
                    Text(
                      "${userMedia.isNotEmpty ? userMedia.first.totalCount : 0}",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Post",
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                VerticalDivider(
                  width: 15,
                  radius: BorderRadius.circular(10),
                  thickness: 1,
                  color: Colors.grey[500],
                ),

                Column(
                  spacing: 4,
                  children: [
                    Text(
                      dojInYears.isNotEmpty ? dojInYears : "Recently Joined",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Since Joined",
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 15,
              color: Colors.grey[500],
              radius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 10),

          Expanded(
            child: userMedia.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 20,
                    children: [
                      SvgPicture.asset(
                        'assets/images/no_feed_added.svg',
                        fit: BoxFit.contain,
                        height: 200,
                        width: 200,
                      ),
                      Text(
                        "Nothing to see here… yet",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  )
                : MasonryGridView.builder(
                    controller: _scrollController,
                    gridDelegate:
                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 100),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    itemCount: userMedia.length,
                    itemBuilder: (context, index) {
                      var feed = userMedia[index];
                      var isVideo = Helpers.isVideo(feed.mediaThumb);
                      return GestureDetector(
                        onTap: () {
                          var userGuid = employeeGuid;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider(
                                create: (_) => UserPostProvider(),
                                child: UserPostScreen(
                                  empGuid: userGuid,
                                  mediaGuid: feed.mediaGuid,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: isVideo
                                  ? MemoryImage(feed.videoThumb!)
                                  : NetworkImage(feed.mediaThumb),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 6,
                                color: Colors.grey.shade200,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  final dummyData = List.generate(
    6,
    (index) => UserAllMediaResponse(
      mediaGuid: "",
      addedOn: DateTime.now(),
      mediaDesc: "Loading description",
      mediaThumb: "Loading Thumb image",
      mediaTittle: "Loading Title",
      mediaType: "Loading type",
      totalCount: 6,
    ),
  );
}
