import 'package:flutter/material.dart';
import 'package:last_state/last_state.dart';

///FOUR easy steps to use thing plugin
///1-  first step: init
///2- second step: setUp navigation observer
///3- third step: set initial route
///DONE
///4- Put or Get data:
/// `SavedLastStateData.instance.put(key,value)`
/// `SavedLastStateData.instance.get(key)`

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //1- first step: init
  await SavedLastStateData.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint("rebuild app");
    // Navigator will set up the correct route history if they are structured in a hierarchical way.
    // See https://api.flutter.dev/flutter/widgets/Navigator/initialRoute.html
    return MaterialApp(
      // Setup an observer that will save the current route into the saved state
      //2- second step: setUp navigation observer
      navigatorObservers: [SavedLastStateData.instance.navigationObserver],
      routes: {
        DummyPage.route: (context) => DummyPage(),
      },
      // restore the route or default to the home page
      //3- third step: set initial route
      initialRoute: SavedLastStateData.instance.lastRoute ?? "/",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with LastStateRestoration {
  //use this counter to demo the use of StateRestoration
  var _counter = 0;

  //use this counter to demo a normal uses of lastState (restore on demand)
  var _counter2 = 0;

  void _increment() {
    setState(() {
      _counter++;
      _counter2 += 5;
      SavedLastStateData.instance.putInt("counter", _counter);
      SavedLastStateData.instance.putInt("counter2", _counter2);
    });
  }

  @override
  void lastStateRestored() {
    print('lastStateRestored');
    setState(() {
      _counter = SavedLastStateData.instance.getInt("counter") ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
                'Count (auto restored) = $_counter  <>   Count2 (restore on demand) =$_counter2'),
            MaterialButton(
              child: Text("Increment"),
              onPressed: () => _increment(),
            ),
            RaisedButton(
              child: Text("restore count 2"),
              onPressed: () {
                setState(() {
                  _counter2 =
                      SavedLastStateData.instance.getInt("counter2") ?? 0;
                });
              },
            ),
            RaisedButton(
              child: Text("Go next page"),
              onPressed: () => Navigator.of(context).pushNamed("/intermediate"),
            ),
          ],
        ),
      ),
    );
  }
}

class DummyPage extends StatelessWidget {
  static const route = "/intermediate";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Another page'),
      ),
      body: RaisedButton(
        child: Text("Onwards"),
        onPressed: () {},
      ),
    );
  }
}
