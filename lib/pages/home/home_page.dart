import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:projet_lepl1509_groupe_17/components/drawer/drawer.dart';
import 'package:projet_lepl1509_groupe_17/models/review.dart';
import 'package:projet_lepl1509_groupe_17/pages/home/create_review_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Review> reviews = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  void fetchReviews() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance.collection("reviews").get().then((value) {
      value.docs.forEach((element) {
        setState(() {
          reviews.add(Review.fromMap(element.data()));
        });
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerComponent(),
      appBar: AppBar(
        title: const Text('MovieGram'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  Get.to(() => const CreateReviewPage());
                },
                child: const Text('Create review')),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(reviews[index].title),
                            subtitle: Text(reviews[index].comment),
                          );
                        }))
          ],
        ),
      ),
    );
  }
}
