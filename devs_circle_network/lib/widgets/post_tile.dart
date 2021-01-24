import 'package:flutter/material.dart';
import 'package:social_media/pages/post_screen.dart';
import 'package:social_media/widgets/custom_image.dart';
import 'package:social_media/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl, context),
    );
  }

  // function to show other photo page , the photo where they clicked
  showPost(context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PostScreen(postId: post.postId, userId: post.ownerId,),
    ));
  }
}
