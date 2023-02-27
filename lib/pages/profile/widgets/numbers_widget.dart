import 'package:flutter/material.dart';
import 'package:projet_lepl1509_groupe_17/models/user_profile.dart';

class NumbersWidget extends StatefulWidget {
  final UserProfile? userProfile;

  const NumbersWidget({super.key, this.userProfile});

  @override
  State<NumbersWidget> createState() => _NumbersWidgetState();
}

class _NumbersWidgetState extends State<NumbersWidget> {
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildText(context, widget.userProfile?.ranking.toString() ?? "0", 'Ranking'),
          buildDivider(),
          buildText(
              context, widget.userProfile?.following.toString() ?? "0", 'Following'),
          buildDivider(),
          buildText(
              context, widget.userProfile?.followers.toString() ?? "0", 'Followers'),
        ],
      );

  Widget buildDivider() => const SizedBox(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildText(BuildContext context, String value, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        const SizedBox(height: 2),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
