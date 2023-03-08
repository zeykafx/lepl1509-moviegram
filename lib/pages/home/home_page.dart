import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/components/review/movie_page.dart';
import 'package:projet_lepl1509_groupe_17/models/review.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerComponent(),
      appBar: AppBar(
        title: const Text('MovieGram'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Get.to(() => const MoviePage());
                    },
                    child: const Text('Create review')),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child:
                            Text("Most recent reviews", style: TextStyle(fontSize: 20)),
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('reviews')
                              .snapshots(),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.docs.length,
                                  itemBuilder: (context, index) {
                                    // get the review from the snapshot
                                    Review review =
                                        Review.fromMap(snapshot.data.docs[index].data());

                                    // return a tile for each review
                                    return ListTile(
                                      leading: review.posterUrl != ""
                                          ? Image.network(
                                              review.posterUrl,
                                              fit: BoxFit.contain,
                                            )
                                          : const Icon(Icons.movie,
                                              size: 35), // TODO: add placeholder image
                                      title: RichText(
                                        text: TextSpan(
                                          text: review.title,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: ' - ${review.username}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.normal,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color)),
                                          ],
                                        ),
                                      ),
                                      isThreeLine: true,
                                      subtitle: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                              child: Text(
                                            review.comment ?? "No comment...",
                                            softWrap: true,
                                          )),
                                          const Icon(Icons.star,
                                              color: Colors.orangeAccent, size: 15),
                                          Text(review.rating.toString() ?? "No rating"),
                                        ],
                                      ),
                                    );
                                  });
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
