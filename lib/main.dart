import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Latigo Tiranico CAIN',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(title: 'Latigo Tiranico CAIN'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int latigazos = 0;
  bool latiguear = false;
  bool waitLatigazo = false;
  List<double> accelerometerValues = [0,0,0];
  List<StreamSubscription<dynamic>> streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  // audio play
  AudioCache audioCache;
  AudioPlayer advancedPlayer;


  bool isLatigazoMovement(){
    if ( accelerometerValues[0].abs() > 8.3 && accelerometerValues[1].abs() < 8.3) {
      return true;
    }
    return false;
  }

  void hadleAccelerometerChange(AccelerometerEvent event){
    // actualiza el valor del sensor
    setState(() {
      accelerometerValues = <double>[event.x, event.y, event.z];
    });
    
    latiguear = isLatigazoMovement();

    if (latiguear && !waitLatigazo) {
      latiguearEsclavo();
    }
  }

  void initPlayer(){
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);
  }

  @override
  void initState(){
    super.initState();
    initPlayer();
    //accelerometer events
    streamSubscriptions.add(accelerometerEvents.listen(hadleAccelerometerChange));
  }

  @override
  void dispose() {
    for (StreamSubscription<dynamic> sub in streamSubscriptions) {
      sub.cancel();
    }
    audioCache = null;
    advancedPlayer = null;
    super.dispose();
  }

  void latiguearEsclavo() {
    setState(() {
      //deshabilitamos el latigazo un rato
      waitLatigazo = true;
      latigazos++;
    });
    audioCache.play('audio/latigazo.mp3');
    Future.delayed(const Duration(milliseconds: 1350), () {
        //print("se libera el latigazo");
        habilitarLatigazo();
      }
    );
  }

  void latigazoManual(){
    if (!waitLatigazo) {
      latiguearEsclavo();
    }
  }

  void habilitarLatigazo(){
    setState(() {
      waitLatigazo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    /*
    lo convierte a un string mas corto
    final List<String> accelerometer = accelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();
    */
    //final String xAxis = accelerometerValues[0].toString();
    //final String yAxis = accelerometerValues[1].toString();
    //final String zAxis = accelerometerValues[2].toString();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Text('Accelerometer: $latiguear'),
            //Text('x : $xAxis'),
            //Text('y : $yAxis'),
            //Text('z : $zAxis'),
            Text(
              'Has dado :',
            ),
            Text(
              '$latigazos',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              'Latigazos'
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: latigazoManual,
        tooltip: 'Increment',
        child: Icon(Icons.whatshot),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
