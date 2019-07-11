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
  int present = 0;
  int perPage = 17;

  List<Post> originalItems;
  var items = List<Post>();

  loadMore() {
    return Future.delayed(Duration(milliseconds: 200)).then((value) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<List<Post>> fetchPost() async {
    final response = await http.get('https://jsonplaceholder.typicode.com/posts');
    List jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return jsonData.map((f) => Post.fromJson(f)).toList();
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
          child: FutureBuilder<List<Post>>(
            future: fetchPost(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                originalItems = snapshot.data;
                items.addAll(originalItems.getRange(present, present + perPage));
                if (items.length > originalItems.length) {
                  items.clear();
                  items.addAll(originalItems.getRange(present, originalItems.length));
                }
                return ListView.builder(
                    itemCount:
                        (items.length < originalItems.length) ? items.length + 1 : items.length,
                    itemBuilder: (context, index) {
                      return (index == items.length)
                          ? Container(
                              margin: EdgeInsets.all(8),
                              child: Center(child: CircularProgressIndicator()))
                          : ListTile(
                              title: Text(snapshot.data[index].id.toString()),
                              subtitle: Text(snapshot.data[index].title));
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
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({this.userId, this.id, this.title, this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}
