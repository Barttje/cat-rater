import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class CatImage extends StatelessWidget {
  const CatImage({
    Key key,
    this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return FadeInImage.memoryNetwork(
      placeholder: kTransparentImage,
      image: url,
    );
  }
}
