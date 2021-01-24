import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


// notice user when user img is loading in their profile page
Widget cachedNetworkImage(mediaUrl, context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height / 1.8,
    margin: const EdgeInsets.fromLTRB(20,0,20,0),
    child: CachedNetworkImage(
      imageUrl: mediaUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Padding(
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
        ),
        padding: EdgeInsets.all(10.0),),errorWidget: (context, url, error) => Icon(Icons.error),
    ),
  );
}
