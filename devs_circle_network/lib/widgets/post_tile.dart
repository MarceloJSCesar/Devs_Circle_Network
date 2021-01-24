import 'package:flutter/material.dart';
import 'package:social_media/widgets/custom_image.dart';
import 'package:social_media/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: cachedNetworkImage(post.mediaUrl, context),
    );
  }
}
