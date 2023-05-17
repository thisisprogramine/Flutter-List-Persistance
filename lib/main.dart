import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:list_persistence/data/database.dart';
import 'package:list_persistence/model/Feed.dart';
import 'package:list_persistence/model/model.dart';
import 'package:list_persistence/model/modelList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:list_persistence/provider/connectivity.dart';
import 'package:provider/provider.dart';

enum ConnectivityResult {
  /// WiFi: Device connected via Wi-Fi
  wifi,

  /// Mobile: Device connected to cellular network
  mobile,

  /// None: Device not connected to any network
  none
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) {
          ConnectivityChangeNotifier changeNotifier =
              ConnectivityChangeNotifier();
          //Inital load is an async function, can use FutureBuilder to show loading
          //screen while this function running. This is not covered in this tutorial
          changeNotifier.initialLoad();
          return changeNotifier;
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Network Connectivity',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: HomeScreen(),
        ));
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Model>> data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    FeedDatabase.instance.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feed"),
      ),
      body: Container(
        child: Consumer<ConnectivityChangeNotifier>(
            builder:(context, connectivityChangeNotifier, child) {
              return connectivityChangeNotifier.isOnline ? remoteDataSource() : localDataSource();
            }
        ),
      ),
    );
  }

  Widget remoteDataSource() {
    try{
      data = fetchData();
      data.then((list) {
        for (var i in list) {
          addFeed(i as Model);
        }
      });
    }catch(e) {
      print(e.toString());
    }
    return FutureBuilder<List<Model>>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var l = FeedDatabase.instance.readAllNotes().then((value) {
            for (var i in value) {
              print(i.name);
            }
          });
          return snapshot.data?.isNotEmpty ?? false ? ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data?[index].name ?? " "),
                  subtitle: Text(snapshot.data?[index].country ?? " "),
                  leading: CircleAvatar(
                    child: ClipOval(
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/user_placeholder.png',
                        image: snapshot.data?[index].picture ?? " ",
                        fit: BoxFit.cover,
                        height: 80,
                        width: 80,
                      ),
                    ),
                  ),
                  trailing: Text(snapshot.data?[index].age ?? " "),
                );
              }) : Center(child: Text("List is empty"),);
        } else if (snapshot.hasError) {
          Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget localDataSource() {
    return FutureBuilder<List<Feed>>(
      future: FeedDatabase.instance.readAllNotes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var l = FeedDatabase.instance.readAllNotes().then((value) {
            for (var i in value) {
              print(i.name);
            }
          });
          return snapshot.data?.isNotEmpty ?? false ? ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data?[index].name ?? " "),
                  subtitle: Text(snapshot.data?[index].country ?? " "),
                  leading: CircleAvatar(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/user_placeholder.png',
                        fit: BoxFit.cover,
                        height: 80,
                        width: 80,
                      ),
                    ),
                  ),
                  trailing: Text(snapshot.data?[index].age ?? " "),
                );
              }) : Center(child: Text("List is empty"),);
        } else if (snapshot.hasError) {
          Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<List<Model>> fetchData() async {
    final response =
        await http.get(Uri.parse('https://randomuser.me/api/?results=5'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return ResultModel.fromJson(jsonDecode(response.body)).listModel;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future addFeed(Model m) async {
    final feed = Feed(
      name: m.name,
      picture: m.picture,
      age: m.age,
      country: m.country,
    );

    await FeedDatabase.instance.create(feed);
  }
}
