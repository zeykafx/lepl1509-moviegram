import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

class NumbersWidget extends StatefulWidget {
  final UserProfile? userProfile;
  final int numberPosts;

  const NumbersWidget({super.key, this.userProfile, this.numberPosts = 0});

  @override
  State<NumbersWidget> createState() => _NumbersWidgetState();
}

class _NumbersWidgetState extends State<NumbersWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        buildText(context, widget.numberPosts.toString(), 'N° Posts'),
        buildDivider(),
        buildText(context, widget.userProfile?.following.toString() ?? "0",
            'Following'),
        buildDivider(),
        buildText(context, widget.userProfile?.followers.toString() ?? "0",
            'Followers'),
      ],
    );
  }

  Widget buildDivider() => const SizedBox(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildText(BuildContext context, String value, String text) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Theme.of(context).dividerColor),
        ),
      ],
    );
  }
}
