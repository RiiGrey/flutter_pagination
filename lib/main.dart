import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int page = 1;

  Post originalItems;
  Future<Post> posts;

  loadMore() async {
    if (page > originalItems.totalPages) {
      print('we reach limit');
    } else {
      page += 1;
      Post post = await fetchPost(page);
      setState(() {
        originalItems.data.addAll(post.data);
      });
    }
  }

  @override
  void initState() {
    posts = fetchPost(page);
    super.initState();
  }

  Future<Post> fetchPost(int page) async {
    final response = await http.get('https://reqres.in/api/users?page=$page');
    if (response.statusCode == 200) {
      print(response.body);
      return Post.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              loadMore();
            }
            return true;
          },
          child: FutureBuilder<Post>(
            future: posts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                originalItems = snapshot.data;
                return ListView.builder(
                    itemCount: originalItems.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(originalItems.data[index].firstName),
                        subtitle: Text(originalItems.data[index].email),
                      );
                    });
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}

class Post {
  int page;
  int perPage;
  int total;
  int totalPages;
  List<Data> data;

  Post({
    this.page,
    this.perPage,
    this.total,
    this.totalPages,
    this.data,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        page: json["page"] == null ? null : json["page"],
        perPage: json["per_page"] == null ? null : json["per_page"],
        total: json["total"] == null ? null : json["total"],
        totalPages: json["total_pages"] == null ? null : json["total_pages"],
        data: json["data"] == null ? null : List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "page": page == null ? null : page,
        "per_page": perPage == null ? null : perPage,
        "total": total == null ? null : total,
        "total_pages": totalPages == null ? null : totalPages,
        "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Data {
  int id;
  String email;
  String firstName;
  String lastName;
  String avatar;

  Data({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.avatar,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] == null ? null : json["id"],
        email: json["email"] == null ? null : json["email"],
        firstName: json["first_name"] == null ? null : json["first_name"],
        lastName: json["last_name"] == null ? null : json["last_name"],
        avatar: json["avatar"] == null ? null : json["avatar"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "email": email == null ? null : email,
        "first_name": firstName == null ? null : firstName,
        "last_name": lastName == null ? null : lastName,
        "avatar": avatar == null ? null : avatar,
      };
}
