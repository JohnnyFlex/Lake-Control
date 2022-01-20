import 'dart:async';
import 'dart:ffi';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lakecontrol/utils/constants.dart';
import 'package:lakecontrol/utils/widget_functions.dart';

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
      theme: ThemeData(primaryColor: Colors.white, textTheme: TEXT_THEME_DEFAULT, fontFamily: "Montserrat"),
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
  bool _gate = false;
  String gateStatus = '';
  String _update = '';
  String _ph = '';
  String _temperature = '';
  final _database = FirebaseDatabase.instance.reference();
  late StreamSubscription _stream;

  void checkGateStatus() {
    if (_gate) {
      gateStatus = 'Geöffnet';
    } else {
      gateStatus = 'Geschlossen';
    }
  }

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ThemeData = Theme.of(context);
    final double padding = 25;
    final sidePadding = EdgeInsets.symmetric(horizontal: padding);
    checkGateStatus();
    return SafeArea(
      child: Scaffold(
          body: Container(
              width: size.width,
              height: size.height,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addVerticalSpace(padding + 10),
                    Padding(
                      padding: sidePadding,
                      child: Text("Lake Control", style: ThemeData.textTheme.headline2,),
                    ),
                    addVerticalSpace(2),
                    Padding(
                      padding: sidePadding,
                      child: Text("Übersicht", style: ThemeData.textTheme.headline1,),
                    ),
                    addVerticalSpace(padding),
                    Padding(
                      padding: sidePadding,
                      child: TBox(icon: 'assets/images/temperature.png', status: _temperature),
                    ),
                    addVerticalSpace(15),
                    Padding(
                      padding: sidePadding,
                      child: PBox(icon: 'assets/images/pressure-gauge.png', status: _ph),
                    ),
                    addVerticalSpace(15),
                    Padding(
                      padding: sidePadding,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: COLOR_GREEN
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                'assets/images/gate.png',
                                height: 100,
                                width: 100,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(gateStatus, style: ThemeData.textTheme.headline4),
                                  Transform.scale(
                                    scale: 1.1,
                                    child: Switch(
                                      value: _gate,
                                      //activeColor: COLOR_SWITCH,
                                      onChanged: (v) {
                                        setState(() async {
                                          try {
                                            await _database.update({'isGateOpened': !_gate});
                                            print('Data has been successfully written to database!');
                                          }catch(e) {
                                            print('You got an error! $e');
                                          }
                                          _gate = v;
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                    ),
                    addVerticalSpace(15),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        children: [
                          Text('Letztes Update:', style: ThemeData.textTheme.subtitle1),
                          Text(_update, style: ThemeData.textTheme.subtitle1)
                        ],
                      ),
                    )
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
      final ph = data['phValue'] as dynamic;
      final temperature = data['temperature'] as dynamic;
      setState(() {
        _gate = gate;
        _update = update;
        _ph = '$ph';
        _temperature = '$temperature';
      });
    });
  }

  @override
  void deactivate() {
    _stream.cancel();
    super.deactivate();
  }

}

@override
class TBox extends StatelessWidget {
  final String icon;
  final String status;

  const TBox({Key? key, required this.status, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: COLOR_RED
      ),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            icon,
            height: 100,
            width: 100,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(status + "°", style: themeData.textTheme.headline3),
              Text("Temperatur", style: themeData.textTheme.bodyText2)
            ],
          )
        ],
      )
    );
  }
}

@override
class PBox extends StatelessWidget {
  final String icon;
  final String status;

  const PBox({Key? key, required this.status, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: COLOR_BLUE
        ),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              icon,
              height: 100,
              width: 100,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(status, style: themeData.textTheme.headline3),
                Text("PH-Wert", style: themeData.textTheme.bodyText2)
              ],
            )
          ],
        )
    );
  }
}
