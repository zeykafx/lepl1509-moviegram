class SearchMovie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;

  SearchMovie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory SearchMovie.fromJson(Map<String, dynamic> json) {
    return SearchMovie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'] != null
          ? "https://image.tmdb.org/t/p/w500${json['poster_path']}"
          : null,
      backdropPath: json['backdrop_path'] != null
          ? "https://image.tmdb.org/t/p/w500${json['backdrop_path']}"
          : null,
      overview: json['overview'],
      voteAverage: json['vote_average'].toDouble(),
      releaseDate: json['release_date'],
    );
  }
}
