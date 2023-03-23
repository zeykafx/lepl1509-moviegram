class UserProfile {
  final String? uid;
  int followers;
  int following;
  int ranking;
  String? bio;
  String photoURL;
  String name;
  String email;

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
    return UserProfile(
      uid: map['uid'],
      bio: map['bio'] ?? "No Bio",
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
      ranking: map['ranking'] ?? 0,
      photoURL: map['photoURL'] != ""
          ? map['photoURL'] ?? 'http://www.gravatar.com/avatar/?d=mp'
          : 'http://www.gravatar.com/avatar/?d=mp',
      name: map['name'] ?? 'No Name',
      email: map['email'] ?? 'No Email',
    );
  }

  void updateBio(String bio) {
    this.bio = bio;
  }

  @override
  String toString() {
    return 'UserProfile{uid: $uid, bio: $bio, followers: $followers, following: $following, ranking: $ranking, photoURL: $photoURL, name: $name, email: $email}';
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'bio': bio,
      'followers': followers,
      'following': following,
      'ranking': ranking,
      'photoURL': photoURL,
      'name': name,
      'email': email,
    };
  }
}
