import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http_api/models/repo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

Future<All> fetchRepos() async {
  final response =
      await http.get(Uri.parse('https://api.github.com/users/flutter/repos'));

  if (response.statusCode == 200) {
    print(response.body);
    return All.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to fetch repos!');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<All>? futureRepo;

  @override
  void initState() {
    super.initState();
    futureRepo = fetchRepos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub API!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: FutureBuilder<All>(
            future: futureRepo,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Repo> repos = <Repo>[];
                for (int i = 0; i < snapshot.data!.repos.length; i++) {
                  repos.add(
                    Repo(
                      name: snapshot.data!.repos[i].name,
                      description: snapshot.data!.repos[i].description,
                      htmlUrl: snapshot.data!.repos[i].htmlUrl,
                      stargazerCount: snapshot.data!.repos[i].stargazerCount,
                    ),
                  );
                }
                return ListView(
                  children: repos
                      .map(
                        (r) => Card(
                          color: Colors.blue[300],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      r.name,
                                      style: const TextStyle(fontSize: 30.0),
                                    ),
                                    Text(r.stargazerCount.toString()),
                                  ],
                                ),
                                Text(
                                  r.description,
                                  style: const TextStyle(fontSize: 23.0),
                                ),
                                Text(r.htmlUrl),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error!'),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
