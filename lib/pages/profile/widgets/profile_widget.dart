import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class ProfileWidget extends StatelessWidget {
  final String? imagePath;
  final bool isEdit;
  final bool inDrawer;
  final VoidCallback onClicked;
  final bool access;
  final bool self;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    this.isEdit = false,
    required this.onClicked,
    required this.inDrawer,
    required this.access,
    required this.self,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    if (inDrawer) {
      return Center(
        child: InkWell(onTap: self ? onClicked : () {}, child: buildImage(70)),
      );
    } else {
      return Center(
          child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: self ? onClicked : () {},
        child: Stack(
          children: [
            buildImage(90),
            Positioned(
              bottom: 0,
              right: 4,
              child: self ? buildEditIcon(color, context) : Container(),
            ),
          ],
        ),
      ));
    }
  }

  Widget buildImage(double size) {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: size,
          height: size,
          child: Image(
            image: OptimizedCacheImageProvider(imagePath!),
            width: size.toInt() * 2,
            height: size.toInt() * 2,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color, BuildContext context) {
    return buildCircle(
      color: Theme.of(context).colorScheme.surface,
      all: 2,
      child: buildCircle(
        color: color,
        all: 5,
        child: Icon(
          isEdit ? Icons.add_a_photo : Icons.edit,
          color: Colors.white,
          size: 15,
        ),
      ),
    );
  }

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
