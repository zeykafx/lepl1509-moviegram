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
          buildButton(context, widget.userProfile?.ranking.toString() ?? "0", 'Ranking'),
          buildDivider(),
          buildButton(
              context, widget.userProfile?.following.toString() ?? "0", 'Following'),
          buildDivider(),
          buildButton(
              context, widget.userProfile?.followers.toString() ?? "0", 'Followers'),
        ],
      );

  Widget buildDivider() => Container(
        height: 24,
        child: const VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) => MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      );
}
