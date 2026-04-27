import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/models/userAllMediaResponse.dart';
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
    final userProvider = context.watch<AllUserProfileProvider>();

    if (userProvider.isLoading) {
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
          ),
        ),
      );
    }

    if (userProvider.profileDate == null) {
      return Scaffold(
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
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _profileBody(
        context,
        scrollController: _scrollController,
        name: userProvider.profileDate!.employeeName,
        designation: userProvider.profileDate!.designation,
        employeeId: userProvider.profileDate!.employeeId,
        dojInYears: userProvider.profileDate!.dojInYears,
        profileImage: userProvider.profileDate!.profileImage,
        userMedia: userProvider.userMedia,
        employeeGuid: userProvider.profileDate!.employeeGuid,
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
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 45),
        child: Column(
          children: [
            Stack(
              alignment: AlignmentGeometry.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: Color(0xFFE0E0E0),
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
                      backgroundColor: Color(0xFFE0E0E0),
                      backgroundImage: profileImage.isNotEmpty
                          ? CachedNetworkImageProvider(profileImage)
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
                name.isNotEmpty ? name.capitalize() : "User",
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
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 10,
                      itemCount: userMedia.length,
                      itemBuilder: (context, index) {
                        var feed = userMedia[index];
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
