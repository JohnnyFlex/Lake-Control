import 'dart:async';
import 'dart:ffi';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(LakeControl());
}

class LakeControl extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lake Control',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: _fbApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print ('You have an error! ${snapshot.error.toString()}');
            return Text('Something went wrong!');
          } else if (snapshot.hasData) {
            return HomePage();
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              )
            );
          }
        },
      )
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _gate = '';
  String _update = '';
  String _ph = '';
  String _temperature = '';

  final _database = FirebaseDatabase.instance.reference();
  late StreamSubscription _stream;

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          body: Container(
              width: size.width,
              height: size.height,
              child: Column(
                  children: [
                      Text(_gate),
                      Text(_update),
                      Text(_ph),
                      Text(_temperature)
                  ]
              )
          ),
      )
    );
  }

  void _activateListeners() {
    _stream = _database
        .onValue
        .listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final gate = data['isGateOpened'] as bool;
      final update = data['lastUpdated'] as String;
      final ph = data['phValue'] as int;
      final temperature = data['temperature'] as int;
      setState(() {
        _gate = 'Is Gate opened: $gate';
        _update = 'Letztes Update: ' + update;
        _ph = 'PH-Wert: $ph';
        _temperature = 'Temperatur: $temperature';
      });
    });
  }

  @override
  void deactivate() {
    _stream.cancel();
    super.deactivate();
  }
}


