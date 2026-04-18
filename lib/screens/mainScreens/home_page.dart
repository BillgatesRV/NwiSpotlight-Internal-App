import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotlight/common_components/tabbar.dart';
import 'package:spotlight/components/user_card.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/custom_controls/video_playerFeed.dart';
import 'package:spotlight/models/allMediaResponse.dart';
import 'package:spotlight/models/mediaLikedByResponse.dart';
import 'package:spotlight/provider/allUserProfileProvider.dart';
import 'package:spotlight/provider/homeProvider.dart';
import 'package:spotlight/screens/subScreens/allUserProfileScreen.dart';
import 'package:spotlight/services/authService/authStorage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _userScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<HomeProvider>(context, listen: false).initialize();
    });

    _scrollController.addListener(() {
      final provider = Provider.of<HomeProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !provider.isLoading &&
          provider.hasMore) {
        setState(() {
          provider.isPaginating = true;
        });
        provider.fetchFeeds();
      }
    });

    _userScrollController.addListener(() {
      final provider = Provider.of<HomeProvider>(context, listen: false);
      if (_userScrollController.position.pixels >=
              _userScrollController.position.maxScrollExtent - 200 &&
          !provider.isUserLoading &&
          provider.userHasMore) {
        setState(() {
          provider.isUserPaginating = true;
        });
        provider.fetchUsers();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _userScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column( 
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    "assets/images/media_icon.svg",
                    height: 22,
                    width: 22,
                  ),
                  Text(
                    'Spotlight',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: "Lexend",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/images/notification_icon_b.svg",
                    height: 22,
                    width: 22,
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final provider = Provider.of<HomeProvider>(
                    context,
                    listen: false,
                  );
                  _scrollController.position.jumpTo(0);
                  _userScrollController.position.jumpTo(0);
                  await provider.reset();
                },
                child: Consumer<HomeProvider>(
                  builder: (context, value, child) {
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 110,
                            width: double.infinity,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              controller: _userScrollController,
                              itemCount:
                                  value.isUserLoading &&
                                      !value.isUserPaginating
                                  ? 6
                                  : value.usersList.length + 1,
                              itemBuilder: (context, index) {
                                if (value.isUserLoading &&
                                    !value.isUserPaginating) {
                                  return UserCard(
                                    name: "",
                                    profileImageUrl: "",
                                    userGuid: "",
                                    isUserLoading: true,
                                  );
                                }
                                if (index < value.usersList.length) {
                                  var user = value.usersList[index];
                                  return UserCard(
                                    key: ValueKey(user.employeeGuid),
                                    name: user.employeeName,
                                    profileImageUrl: user.profileImage,
                                    userGuid: user.employeeGuid,
                                    isUserLoading:
                                        value.isUserLoading &&
                                        !value.isUserPaginating,
                                  );
                                } else {
                                  return value.hasMore &&
                                          value.isUserLoading &&
                                          value.isUserPaginating
                                      ? Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Center(
                                            child: const SizedBox(
                                              width: 25,
                                              height: 25,
                                              child:
                                                  CircularProgressIndicator(
                                                    strokeWidth: 3,
                                                  ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                        ),
          
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (value.isLoading && !value.isPaginating) {
                                return FeedCard(
                                  mediaFeed: dummyFeed,
                                  isLoading: true,
                                );
                              }
                              if (index < value.mediaFeeds.length) {
                                return FeedCard(
                                  key: ValueKey(
                                    value.mediaFeeds[index].mediaGuid,
                                  ),
                                  mediaFeed: value.mediaFeeds[index],
                                  isLoading:
                                      value.isLoading && !value.isPaginating,
                                );
                              } else {
                                return value.isLoading &&
                                        value.isPaginating &&
                                        value.hasMore
                                    ? Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Center(
                                          child: const SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              }
                            },
                            childCount: value.isLoading && !value.isPaginating
                                ? 5
                                : value.mediaFeeds.length + 1,
                          ),
                        ),
          
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.13,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedCard extends StatefulWidget {
  final AllMediaResponse mediaFeed;
  final bool isLoading;

  FeedCard({super.key, required this.mediaFeed, required this.isLoading});

  @override
  State<FeedCard> createState() => _FeedCard();
}

class _FeedCard extends State<FeedCard> {
  final AuthStorage _authStorage = AuthStorage();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: widget.isLoading,
      effect: ShimmerEffect(
        baseColor: Color(0xFFE0E0E0),
        highlightColor: Color(0xFFF5F5F5),
      ),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Stack(
          children: [
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 350,
                    enableInfiniteScroll: false,
                    viewportFraction: 1,
                    scrollPhysics: BouncingScrollPhysics(),
                    onPageChanged: (index, reason) {
                      setState(() => currentIndex = index);
                    },
                  ),
                  items: widget.mediaFeed.mediaFiles!.map((file) {
                    return file.fileType == "Image"
                        ? GestureDetector(
                            onTap: () {
                              final images = widget.mediaFeed.mediaFiles!
                                  .where((f) => f.fileType == "Image")
                                  .map((f) => Image.network(f.filePath!).image)
                                  .toList();
                              showImageViewerPager(
                                context,
                                MultiImageProvider(
                                  images,
                                  initialIndex: currentIndex,
                                ),
                                doubleTapZoomable: true,
                                backgroundColor: Colors.white,
                                closeButtonColor: Colors.black,
                                useSafeArea: true,
                                immersive: false,
                              );
                            },
                            child: widget.isLoading
                                ? null
                                : CachedNetworkImage(
                                    imageUrl: file.filePath!,
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    width: double.infinity,
                                    height: 350,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : CustomVideoPlayerFeed(videoUrl: file.filePath!);
                  }).toList(),
                ),
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.5),
                      ],
                      stops: [0.0, 0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          var loggedUserGuid = await _authStorage.getUserGuid();

                          if (widget.mediaFeed.employeeGuid == loggedUserGuid) {
                            GlassBottomNav.changeTab(2);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider(
                                  create: (_) => AllUserProfileProvider(),
                                  child: AllUserProfileScreen(
                                    empGuid: widget.mediaFeed.employeeGuid!,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 10, left: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white24,
                                    width: 1.1,
                                  ),
                                  color: Colors.white24.withAlpha(30),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 35,
                                      width: 35,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withAlpha(90),
                                        image:
                                            widget.isLoading &&
                                                widget
                                                    .mediaFeed
                                                    .profileImage
                                                    .isEmpty
                                            ? null
                                            : DecorationImage(
                                                image: NetworkImage(
                                                  widget.mediaFeed.profileImage,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.mediaFeed.employeeName!
                                              .capitalize(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontFamily: "Lexend",
                                            fontWeight: FontWeight.w500,
                                            height: 1.2,
                                          ),
                                        ),
                                        Text(
                                          widget.mediaFeed.designation!
                                              .capitalize(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontFamily: "Lexend",
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10, right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                            child: Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 1.1,
                                ),
                                color: Colors.white24.withAlpha(30),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  final RenderBox button =
                                      context.findRenderObject() as RenderBox;
                                  final RenderBox overlay =
                                      Overlay.of(
                                            context,
                                          ).context.findRenderObject()
                                          as RenderBox;
                                  final Offset offset = button.localToGlobal(
                                    Offset.zero,
                                    ancestor: overlay,
                                  );
                                  final RelativeRect position =
                                      RelativeRect.fromLTRB(
                                        offset.dx + button.size.width,
                                        offset.dy + 70,
                                        offset.dx + 30,
                                        offset.dy,
                                      );

                                  showMenu(
                                    context: context,
                                    position: position,
                                    color: Colors.white,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    items: [
                                      PopupMenuItem(
                                        onTap: () =>
                                            GlassBottomNav.changeTab(1),
                                        height: 25,
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/images/share_icon.svg',
                                              color: Colors.grey[700],
                                              height: 15,
                                              width: 15,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              "Share media",
                                              style: TextStyle(
                                                fontFamily: "Lexend",
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Provider.of<HomeProvider>(
                                      context,
                                      listen: false,
                                    ).toggleLike(widget.mediaFeed.mediaGuid!);
                                  },
                                  child: SvgPicture.asset(
                                    widget.mediaFeed.isUserLiked!
                                        ? "assets/images/like_icon.svg"
                                        : "assets/images/unlike_icon.svg",
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                                SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () async {
                                    var provider = Provider.of<HomeProvider>(
                                      context,
                                      listen: false,
                                    );
                                    await provider.fetchLikedBy(
                                      widget.mediaFeed.mediaGuid!,
                                    );
                                    provider.likedBy.isEmpty
                                        ? null
                                        : showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return LikedByBottomSheet(
                                                isLikedByLoading:
                                                    provider.isLikedByLoading,
                                                likedByList: provider.likedBy,
                                              );
                                            },
                                          );
                                  },
                                  child: Text(
                                    widget.mediaFeed.likesCount == 0
                                        ? "Like"
                                        : "${widget.mediaFeed.likesCount} Likes",
                                    style: TextStyle(
                                      fontFamily: "Lexend",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            widget.mediaFeed.mediaFiles!.length <= 1
                                ? SizedBox.shrink()
                                : Container(
                                    margin: EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 20,
                                          sigmaY: 20,
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 3,
                                            horizontal: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.white24,
                                              width: 1.1,
                                            ),
                                            color: Colors.white24.withAlpha(15),
                                          ),
                                          child: Text(
                                            "${currentIndex + 1}/${widget.mediaFeed.mediaFiles!.length}",
                                            style: TextStyle(
                                              fontFamily: "Lexend",
                                              color: Colors.white54,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.mediaFeed.mediaDesc ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LikedByBottomSheet extends StatefulWidget {
  final bool isLikedByLoading;
  final List<MediaLikedByResponse> likedByList;
  const LikedByBottomSheet({
    super.key,
    required this.isLikedByLoading,
    required this.likedByList,
  });

  @override
  State<LikedByBottomSheet> createState() => _LikedByCard();
}

class _LikedByCard extends State<LikedByBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.likedByList.isEmpty
                        ? "Liked by 0"
                        : "Liked by ${widget.likedByList.first.totalLikes}",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Lexend",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Divider(color: Colors.grey[400], thickness: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.likedByList.length,
                  itemBuilder: (context, index) {
                    if (widget.isLikedByLoading) {
                      return SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 10,
                            children: [
                              Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      widget.likedByList[index].profileImage,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.likedByList[index].employeeName
                                        .capitalize(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: "Lexend",
                                      fontWeight: FontWeight.w500,
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    widget.likedByList[index].designation
                                        .capitalize(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: "Lexend",
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SvgPicture.asset(
                            "assets/images/like_icon.svg",
                            height: 16,
                            width: 16,
                          ),
                        ],
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

final dummyFeed = AllMediaResponse(
  mediaGuid: "",
  employeeName: "Employee Name",
  designation: "Employee Designation",
  profileImage: "",
  mediaFiles: [MediaFilesResponse(fileType: "Image", filePath: "")],
  likesCount: 0,
  isUserLiked: false,
  mediaDesc: "Loading description",
);
