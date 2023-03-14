class UserProfile {
  final String? uid;
  int followers;
  int following;
  int ranking;
  String? bio;

  UserProfile({this.uid, this.bio, required this.followers, required this.following, required this.ranking});

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
        uid: map['uid'],
        bio: map['bio'],
        followers: map['followers'],
        following: map['following'],
        ranking: map['ranking'],
        );
  }

  void updateBio(String bio) {
    this.bio = bio;
  }
}
