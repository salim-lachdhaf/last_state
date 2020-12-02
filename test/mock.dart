import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:last_state/last_state.dart';

typedef Callback(MethodCall call);

final List<MethodCall> methodCallLog = <MethodCall>[];
const MethodChannel channel = MethodChannel('last_state');
Map<dynamic, dynamic> savedState = {};
final Widget myWidget = MyWidget();

setupLastStateMocks([Callback call]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    methodCallLog.add(methodCall);
    switch (methodCall.method) {
      case 'getState':
        return savedState;
      case 'setState':
        savedState = methodCall.arguments['state'];
        return savedState;
    }
    return null;
  });
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with LastStateRestoration {
  int counter = 0;

  @override
  void lastStateRestored() {
    setState(() {
      counter = SavedLastStateData.instance.getInt('counter') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter widget test',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hello into Testing'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('$counter'),
              RaisedButton(
                  child: Text('click'),
                  onPressed: () async {
                    counter++;
                    await SavedLastStateData.instance
                        .putInt('counter', counter);
                    setState(() {});
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
