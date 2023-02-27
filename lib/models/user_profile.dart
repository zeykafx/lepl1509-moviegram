class UserProfile {
  final String? uid;
  final String? name;
  final String? email;
  final String? photoURL;
  final int followers;
  final int following;
  final int ranking;
  final String bio;

  UserProfile(this.followers, this.following, this.ranking, this.bio,
      {this.uid, this.name, this.email, this.photoURL});

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(map['followers'], map['following'], map['ranking'], map['bio'],
        uid: map['uid'],
        name: map['name'],
        email: map['email'],
        photoURL: map['photoURL']);
  }
}
