import 'package:flutter_test/flutter_test.dart';
import 'package:last_state/last_state.dart';

import 'mock.dart';

void main() {
  setupLastStateMocks();

  setUpAll(() async {
    await SavedLastStateData.init();
  });

  tearDownAll(() async {
    await SavedLastStateData.instance.clear();
    savedState.clear();
    methodCallLog.clear();
    channel.setMockMethodCallHandler(null);
  });

  testWidgets('test widget mixin', (WidgetTester tester) async {
    await tester.pumpWidget(myWidget);

    // Create the Finders.
    var counterFinder = find.text('0');
    final clickFinder = find.text('click');

    expect(counterFinder, findsOneWidget);
    expect(clickFinder, findsOneWidget);

    //simulate click
    await tester.tap(clickFinder);
    // Rebuild the widget after the state has changed.
    await tester.pump();

    counterFinder = find.text('1');
    expect(counterFinder, findsOneWidget);
    expect(SavedLastStateData.instance.getInt('counter'), 1);

    //rebuild widget to check if mixin restoreLast state worked fine
    await tester.tap(clickFinder);
    await tester.pump();//increment to 2

    counterFinder = find.text('2');
  });
}
