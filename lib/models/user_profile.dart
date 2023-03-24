class UserProfile {
  final String? uid;
  String? bio;
  List<String> watched;
  int followers;
  int following;
  int ranking;
  String photoURL;
  String name;
  String email;

  UserProfile({
    this.uid,
    this.bio,
    required this.watched,
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
      watched: map['watched'] != null ? List<String>.from(map['watched']) : [''],
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
      ranking: map['ranking'] ?? 0,
      photoURL: map['photoURL'] != "" ? map['photoURL'] ?? 'http://www.gravatar.com/avatar/?d=mp' : 'http://www.gravatar.com/avatar/?d=mp',
      name: map['name'] ?? 'No Name',
      email: map['email'] ?? 'No Email',
    );
    return ret;
  }

  void updateBio(String bio) {
    this.bio = bio;
  }

  @override
  String toString() {
    return 'UserProfile{uid: $uid, bio: $bio, followers: $followers, following: $following, ranking: $ranking, photoURL: $photoURL, name: $name, email: $email, watched: $watched}';
  }

  toMap() {
    return {
      'uid': uid,
      'bio': bio,
      'watched': watched,
      'followers': followers,
      'following': following,
      'ranking': ranking,
      'photoURL': photoURL,
      'name': name,
      'email': email,
    };
  }
}
