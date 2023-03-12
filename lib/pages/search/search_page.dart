import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/models/movies.dart';
import 'package:projet_lepl1509_groupe_17/models/review.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/create_review_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/home_page.dart';
import 'package:projet_lepl1509_groupe_17/pages/movie/movie_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    getAllMovies();
  }

  var db = FirebaseFirestore.instance.collection('films');
  List<Movie> movies = [];
  List<Movie> displayList = [];

  Future<void> getAllMovies() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('films').get();
    setState(() {
      for (var doc in querySnapshot.docs) {
        Movie movie = Movie.fromMap(doc.data() as Map<String, dynamic>);
        movies.add(movie);
      }
      displayList = List.from(movies);
    });
  }

  void updateList(String value) {
    setState(() {
      displayList = movies
          .where((element) =>
              element.title.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1f1545),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1f1545),
        elevation: 0.0,
        actions: [
          IconButton(
              color: Colors.white,
              alignment: AlignmentDirectional.topStart,
              onPressed: () {
                Get.to(() => const HomePage());
              },
              icon: const Icon(Icons.arrow_back))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Search for a movie",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                onChanged: (value) {
                  updateList(value);
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 65, 47, 129),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  prefixIconColor: Colors.purple.shade900,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: displayList.isEmpty
                    ? const Center(
                        child: Text(
                        "No result found",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold),
                      ))
                    : ListView.builder(
                        itemCount: displayList.length,
                        itemBuilder: (context, index) => ListTile(
                          contentPadding: const EdgeInsets.all(0.9),
                          onTap: () =>
                              Get.to(MoviePage(movie: displayList[index])),
                          title: Text(
                            displayList[index].title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${displayList[index].release_date.toDate().year}",
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          leading: Image.network(displayList[index].url),
                        ),
                      ),
              ),
            ]),
      ),
    );
  }
}
