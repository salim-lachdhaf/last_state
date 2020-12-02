<h1 align="center">
  Flutter Last State handler
  <br>
</h1>

<h4 align="center">
  <a href="https://flutter.io" target="_blank">Flutter</a> Simple and robust state saver which allows restoring state after the app process is killed while in the background.
</h4>

<p align="center">
    <a href="https://github.com/salim-lachdhaf/last_state/workflows/build/badge.svg"><img src="https://github.com/salim-lachdhaf/last_state/workflows/build/badge.svg"/></a>
    <a href="https://pub.dartlang.org/packages/last_state"><img src="https://img.shields.io/pub/v/last_state.svg?logo=flutter"/></a>
    <a href="https://codecov.io/gh/salim-lachdhaf/last_state"><img src="https://codecov.io/gh/salim-lachdhaf/last_state/branch/master/graph/badge.svg?token=QSZ3TQ5T6R"/></a>
</p>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="https://github.com/salim-lachdhaf/last_state/blob/master/example">Examples</a> •
  <a href="#license">License</a>
</p>

## Key Features
* Handle last state data
* Easy to implement
* Auto saving for the last route
* Restoring data auto or onDemand

## Example implementation
```

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

///[with LastStateRestoration] is optional, it's is called if we have a
///restored state
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


```

## What this plugin is for
Since mobile devices are resource constrained, both Android and iOS use a trick to make it look like apps like always running in
the background: whenever the app is killed in the background, an app has an opportunity to save a small amount of data
that can be used to restore the app to a state, so that it _looks_ like the app was never killed.

For example, consider a sign up form that a user is filling in. When the user is filling in this form, and a phone call comes in,
the OS may decide that there's not enough resources to keep the app running and will kill the app. By default, Flutter does not
restore any state when relaunching the app after that phone call, which means that whatever the user has entered has now been lost.
Worse yet, the app will just restart and show the home screen which can be confusing to the user as well.

## Saving state
First of all: the term "state" may be confusing, since it can mean many things. In this case _state_ means: the *bare minimum*
amount of data you need to make it appear that the app was never killed. Generally this means that you should only persist things like
data being entered by the user, or an id that identifies whatever was displayed on the screen. For example, if your app is showing
a shopping cart, only the shopping cart id should be persisted using this plugin, the shopping cart contents related to this id
should be loaded by other means (from disk, or from the network).

### Integrating with Flutter projects on Android
This plugin uses Kotlin, make sure your Flutter project has Kotlin configured for that reason.
No other setup is required.

Note that as of version 1.1.0, Flutter version 1.12 or up is required and you should [migrate your project](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects)
before updating from an older version of this plugin.

### Integrating with Flutter project on iOS
This plugin uses Swift, make sure your project is configured to use Swift for that reason.

Your `AppDelegate.swift` in the `ios/Runner` directory should look like this:

```swift
   import UIKit
   import Flutter
   // add this line
   import last_state

   @UIApplicationMain
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
     ) -> Bool {
       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }

     // add these methods
     override func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
         StateStorage.instance.restore(coder: coder)
     }

     override func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
         StateStorage.instance.save(coder: coder)
     }

     override func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
         return true
     }

     override func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
         return true
     }
   }
```

## FAQ
### Why do I need this at all? My apps never get killed in the background
Lucky you! Your phone must have infinite memory :)

### Why not save _all_ state to a file
Two reasons: you are wasting resources (disk and battery) when saving all app state, using `last_state` is more efficient as it only saves the bare
minimum amount of data and only when the OS requests it. State is kept in memory so there are no disk writes at all.

Secondly, even though the app state might have saved, the OS might
choose not to restore it. For example, when the user has killed your app from the task switcher, or after some amount of time when
it doesn't really make sense any more to restore the app state. This is up to the discretion of the OS, and it is good practice
to respect that, in stead of _always_ restoring the app state.

### How do I test this is working?
For both Android and iOS: start your app and send it to the background by pressing the home button or using a gesture. Then
from XCode or Android Studio, kill the app process and restart the app from the launcher. The app should resume from the same
state as when it was killed.

### When is state cleared by the OS
For Android: when the user "exits" the app by pressing back, and at the discretion of the OS when the app is in the background.

For iOS: users cannot really "exit" an app on iOS, but state is cleared when the user swipes away the app in the app switcher.

## License
MIT