import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String? imagePath;
  final bool isEdit;
  final bool inDrawer;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    this.isEdit = false,
    required this.onClicked,
    required this.inDrawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    if (inDrawer) {
      return Center(
        child: InkWell(onTap: onClicked, child: buildImage(70)),
      );
    } else {
      return Center(
          child: InkWell(
        onTap: onClicked,
        child: Stack(
          children: [
            buildImage(110),
            Positioned(
              bottom: 0,
              right: 4,
              child: buildEditIcon(color, context),
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
                image: ResizeImage(
                  NetworkImage(
                    imagePath!,
                  ),
                  width: size.toInt()*2,
                  height: size.toInt()*2,
                ),
                fit: BoxFit.cover,
              ),
            )
            // child: Ink.image(
            //   image: image,
            //   fit: BoxFit.cover,
            //   width: size,
            //   height: size,
            //   child: InkWell(onTap: onClicked),
            // ),
            ));
  }

  Widget buildEditIcon(Color color, BuildContext context) => buildCircle(
        color: Theme.of(context).colorScheme.surface,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: Icon(
            isEdit ? Icons.add_a_photo : Icons.edit,
            color: Colors.white,
            size: 15,
          ),
        ),
      );

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
