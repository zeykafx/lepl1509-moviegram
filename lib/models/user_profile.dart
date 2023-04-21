class UserProfile {
  final String? uid;
  String? bio;
  int followers;
  int following;
  int ranking;
  String photoURL;
  String name;
  String email;
  List<int> watchlist = [];
  List<int> watched = [];

  UserProfile({
    this.uid,
    this.bio,
    required this.followers,
    required this.following,
    required this.ranking,
    required this.photoURL,
    required this.name,
    required this.email,
  });

  static UserProfile fromMap(Map<String, dynamic> map) {
    UserProfile ret = UserProfile(
      uid: map['uid'],
      bio: map['bio'] ?? "No Bio",
      followers: map['followers'].round() ?? 0,
      following: map['following'].round() ?? 0,
      ranking: map['ranking'].round() ?? 0,
      photoURL: map['photoURL'] != ""
          ? map['photoURL'] ?? 'http://www.gravatar.com/avatar/?d=mp'
          : 'http://www.gravatar.com/avatar/?d=mp',
      name: map['name'] ?? 'No Name',
      email: map['email'] ?? 'No Email',
    );
    if (map["watchlist"] != null) {
      ret.watchlist = List<int>.from(map["watchlist"]);
    }

    if (map["watched"] != null) {
      ret.watched = List<int>.from(map["watched"]);
    }
    return ret;
  }

  void updateBio(String bio) {
    this.bio = bio;
  }

  @override
  String toString() {
    return 'UserProfile{uid: $uid, bio: $bio, followers: $followers, following: $following, ranking: $ranking, photoURL: $photoURL, name: $name, email: $email}';
  }
}
