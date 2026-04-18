import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/provider/allUserProfileProvider.dart';
import 'package:spotlight/provider/userPostProvider.dart';
import 'package:spotlight/screens/subScreens/userPostScreen.dart';

class AllUserProfileScreen extends StatefulWidget {
  final String empGuid;
  const AllUserProfileScreen({super.key, required this.empGuid});

  @override
  State<AllUserProfileScreen> createState() => _AllUserProfilePageState();
}

class _AllUserProfilePageState extends State<AllUserProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<AllUserProfileProvider>(
        context,
        listen: false,
      ).initialize(widget.empGuid);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent - 200) {
        context.read<AllUserProfileProvider>().fetchOthersFeeds(widget.empGuid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<AllUserProfileProvider>();

    if (profileProvider.isLoading) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    if (profileProvider.profileDate == null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Something went wrong please try again later...',
                  style: TextStyle(
                    fontFamily: "Lexend",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    overflow: TextOverflow.clip,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Stack(
                alignment: AlignmentGeometry.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      image: DecorationImage(
                        image: AssetImage('assets/images/profile_cover.jpg'),
                        fit: BoxFit.cover,
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
                        backgroundImage:
                            profileProvider.profileDate!.profileImage.isNotEmpty
                            ? CachedNetworkImageProvider(
                                profileProvider.profileDate!.profileImage,
                              )
                            : AssetImage('assets/images/user_profile.jpg')
                                  as ImageProvider,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white60,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                          size: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  profileProvider.profileDate!.employeeName.isNotEmpty
                      ? profileProvider.profileDate!.employeeName.capitalize()
                      : "User",
                  style: TextStyle(
                    fontFamily: "Lexend",
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  profileProvider.profileDate!.designation.isNotEmpty
                      ? profileProvider.profileDate!.designation.capitalize()
                      : "Developer",
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
                          profileProvider.profileDate!.employeeId.isNotEmpty
                              ? profileProvider.profileDate!.employeeId
                              : "NWIUSER",
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
                          "${profileProvider.userMedia.isNotEmpty ? profileProvider.userMedia.first.totalCount : 0}",
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
                          profileProvider.profileDate!.dojInYears.isNotEmpty
                              ? profileProvider.profileDate!.dojInYears
                              : "Recently Joined",
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
                child: profileProvider.userMedia.isEmpty
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
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 10,
                        itemCount: profileProvider.userMedia.length,
                        itemBuilder: (context, index) {
                          var feed = profileProvider.userMedia[index];
                          var isVideo = Helpers.isVideo(feed.mediaThumb);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider(
                                    create: (_) => UserPostProvider(),
                                    child: UserPostScreen(
                                      empGuid: widget.empGuid,
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
        ),
      ),
    );
  }
}
