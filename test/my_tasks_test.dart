import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meco/screens/my_tasks_screen.dart';

/// Pumps the My Tasks screen with a logged-in demo session.
Future<void> pumpMyTasks(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    'logged_in': true,
    'login_id': 'accounts@meco.com',
    'department': 'Accounts & Finance',
    'name': 'Accounts User',
    'user_id': '10001',
  });
  await tester.pumpWidget(const MaterialApp(home: MyTasksScreen()));
  await tester.pump(); // let the session load complete
}

/// Taps the sidebar menu item (the content header shows the same label once
/// a category is selected, so always target the first match in the tree).
Future<void> tapMenu(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle();
}

/// The count text that sits in the same row as the given submenu title.
Finder countOf(Finder title, String count) => find.descendant(
      of: find.ancestor(of: title, matching: find.byType(Row)).first,
      matching: find.text(count),
    );

void main() {
  testWidgets('Task sections are initially collapsed', (WidgetTester tester) async {
    await pumpMyTasks(tester);

    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.text('Tasks for me'), findsOneWidget);
    expect(find.text('Tasks by me'), findsOneWidget);
    expect(find.text('My Requests'), findsOneWidget);
    expect(find.text('My Approvals'), findsOneWidget);
    expect(find.text('My Comments'), findsOneWidget);

    // No child items visible before any expansion.
    expect(find.text('Active'), findsNothing);
    expect(find.text('Archived'), findsNothing);
    expect(find.text('Pending Requests'), findsNothing);
    expect(find.text('Draft Requests'), findsNothing);
    expect(find.text('Archived Requests'), findsNothing);
  });

  testWidgets('Tasks for me expands and collapses its submenu', (
    WidgetTester tester,
  ) async {
    await pumpMyTasks(tester);

    await tapMenu(tester, 'Tasks for me');

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Archived'), findsOneWidget);
    expect(countOf(find.text('Active'), '0'), findsOneWidget);
    expect(countOf(find.text('Archived'), '0'), findsOneWidget);
    expect(find.text('Pending Requests'), findsNothing);

    await tapMenu(tester, 'Tasks for me');

    expect(find.text('Active'), findsNothing);
    expect(find.text('Archived'), findsNothing);
  });

  testWidgets('Tasks by me expands and collapses its submenu', (
    WidgetTester tester,
  ) async {
    await pumpMyTasks(tester);

    await tapMenu(tester, 'Tasks by me');

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Archived'), findsOneWidget);
    expect(countOf(find.text('Active'), '0'), findsOneWidget);
    expect(countOf(find.text('Archived'), '0'), findsOneWidget);

    await tapMenu(tester, 'Tasks by me');

    expect(find.text('Active'), findsNothing);
    expect(find.text('Archived'), findsNothing);
  });

  testWidgets('My Requests shows the expected counts', (WidgetTester tester) async {
    await pumpMyTasks(tester);

    await tapMenu(tester, 'My Requests');

    expect(find.text('Pending Requests'), findsOneWidget);
    expect(find.text('Draft Requests'), findsOneWidget);
    expect(find.text('Archived Requests'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // Pending Requests 1
    expect(countOf(find.text('Draft Requests'), '0'), findsOneWidget); // Draft 0
    expect(countOf(find.text('Archived Requests'), '22'), findsOneWidget);
    expect(find.text('22'), findsOneWidget); // Archived Requests 22

    await tapMenu(tester, 'My Requests');

    expect(find.text('Pending Requests'), findsNothing);
    expect(find.text('Draft Requests'), findsNothing);
    expect(find.text('Archived Requests'), findsNothing);
  });

  testWidgets('Sections expand and collapse independently', (
    WidgetTester tester,
  ) async {
    await pumpMyTasks(tester);

    await tapMenu(tester, 'Tasks for me');
    expect(find.text('Active'), findsOneWidget);

    await tapMenu(tester, 'My Requests');
    expect(find.text('Active'), findsOneWidget); // still expanded
    expect(find.text('Pending Requests'), findsOneWidget);

    // Tasks by me remains collapsed while the other two are expanded.
    expect(find.text('Tasks by me'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);

    await tapMenu(tester, 'Tasks for me');
    expect(find.text('Active'), findsNothing);
    expect(find.text('Pending Requests'), findsOneWidget); // unaffected
  });

  testWidgets('Counts align right and long labels stay inside the panel', (
    WidgetTester tester,
  ) async {
    await pumpMyTasks(tester);

    await tapMenu(tester, 'My Requests');

    // Count sits to the right of the longest label, inside the viewport.
    final double countRight = tester.getRect(find.text('22')).right;
    final double titleRight =
        tester.getRect(find.text('Archived Requests')).right;
    expect(countRight, greaterThan(titleRight));
    expect(countRight, lessThanOrEqualTo(800));
    expect(titleRight, lessThanOrEqualTo(800));

    // Expand the two other sections too: every submenu count must share the
    // same right edge (consistent right alignment across sections).
    await tapMenu(tester, 'Tasks for me');
    await tapMenu(tester, 'Tasks by me');

final List<Finder> zeroCounts = <Finder>[
      countOf(find.text('Active').first, '0'),
      countOf(find.text('Archived').first, '0'),
      countOf(find.text('Active').at(1), '0'),
      countOf(find.text('Archived').at(1), '0'),
      countOf(find.text('Draft Requests'), '0'),
      countOf(find.text('Archived Requests'), '22'),
    ];
    final double zeroRight = tester.getRect(zeroCounts.first).right;
    for (final Finder zero in zeroCounts.skip(1)) {
      expect(tester.getRect(zero).right, closeTo(zeroRight, 0.1));
    }
  });
}
