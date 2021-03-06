import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/pages/activity_feed.dart';
import 'package:social_media/pages/home.dart';
import 'package:social_media/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  // a controller to my search input
  TextEditingController searchController = TextEditingController();
  // a query snapshot to get as variable where be storage our userdata
  Future<QuerySnapshot> searchResultFuture;

  // our function to search users and the variable query will pick the text typed and search the text typed
  handleSearch(String query) {
    // search user where diplayName isGreaterThanOrEqualTo query
    Future<QuerySnapshot> users =
        userRef.where('displayName', isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultFuture = users;
    });
  }

  // litlle funciton to clear our text typed inside search field
  clear() {
    searchController.clear();
  }

  // to save our search user results
  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(),
      body: searchResultFuture == null
          ? buildNoContentBody()
          : buildBodyWithContent(),
    );
  }

  // building appBar
  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      title: TextFormField(
        controller: searchController,
        onFieldSubmitted: handleSearch,
        style: TextStyle(color: Colors.white),
        //onFieldSubmitted: ,
        decoration: InputDecoration(
          filled: true,
          hintText: 'Search for user ...',
          hintStyle: TextStyle(
            color: Colors.white
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.account_box,
            size: 25.0,
            color: Colors.white,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              size: 18,
              color: Colors.white,
            ),
            onPressed: clear,
          ),
        ),
      ),
    );
  }

  // a function to build my body
  Container buildNoContentBody() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/earth-and-magnify-glass.svg',
              height: 300,
            ),
            Text(
              'Find Users',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // a fucntion that will return our body with content
  buildBodyWithContent() {
    return FutureBuilder(
      future: searchResultFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        // the list of our search result where be storaged our user data
        List<UserResult> userResults = [];
        // picking user snapshot(data) for each user
        snapshot.data.docs.forEach((doc) {
          // picking the data through our User document of User class created before
          UserData user = UserData.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          // our List userResults will receive as data our User user
          userResults.add(searchResult);
        });
        return ListView(
          children: userResults,
        );
      },
    );
  }
}

class UserResult extends StatelessWidget {
  final UserData user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColorDark.withOpacity(0.1),
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: ListTile(
              leading: CircleAvatar(
                // the reason to use this widgets to provide image it's because will save in cache and optimize our state ...
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(user.displayName, style: TextStyle(
                color: Colors.white)
              ),
              subtitle: Text(user.name, style: TextStyle(
                color: Colors.white),
            ),
            onTap: () => showProfile(context, profileId: user.id)),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
