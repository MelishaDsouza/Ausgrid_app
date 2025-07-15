// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ausgrid_application/widgets/shared_widgets.dart'; // adjust path if needed

void main() {
  testWidgets('Background image and header render correctly', (WidgetTester tester) async {
    // Create a widget that includes backgroundImage and headerWithLogo
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TestWidget(),
        ),
      ),
    );

    // Expect background to be rendered
    expect(find.byType(DecoratedBox), findsWidgets); // backgroundImage uses Container with BoxDecoration

    // Expect logo and text to be present
    expect(find.byType(Image), findsWidgets);
    expect(find.text('Ausgrid AI'), findsOneWidget);
  });

  testWidgets('Permission box renders with text and buttons', (WidgetTester tester) async {
    final buttons = [
      permissionButton(
        tester.element(find.byType(MaterialApp)),
        'Allow',
        () {},
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: permissionBox(text: 'Allow access?', buttons: buttons),
        ),
      ),
    );

    expect(find.text('Allow access?'), findsOneWidget);
    expect(find.text('Allow'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}

// This widget is just for testing backgroundImage and headerWithLogo
class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        backgroundImage(),
        SafeArea(child: headerWithLogo()),
      ],
    );
  }
}

