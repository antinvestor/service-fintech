// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antinvestor_api_common/antinvestor_api_common.dart' show Money;
import 'package:antinvestor_ui_limits/antinvestor_ui_limits.dart';
import 'package:fixnum/fixnum.dart';

void main() {
  testWidgets('renders KES with 2 decimals', (tester) async {
    final m = Money()
      ..currencyCode = 'KES'
      ..units = Int64(1234)
      ..nanos = 560000000;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CurrencyAmountText(amount: m)),
      ),
    );
    expect(find.text('1234.56 KES'), findsOneWidget);
  });

  testWidgets('renders JPY with 0 decimals', (tester) async {
    final m = Money()
      ..currencyCode = 'JPY'
      ..units = Int64(500)
      ..nanos = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CurrencyAmountText(amount: m)),
      ),
    );
    expect(find.text('500 JPY'), findsOneWidget);
  });

  testWidgets('renders KWD with 3 decimals', (tester) async {
    final m = Money()
      ..currencyCode = 'KWD'
      ..units = Int64(1)
      ..nanos = 234000000;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CurrencyAmountText(amount: m)),
      ),
    );
    expect(find.text('1.234 KWD'), findsOneWidget);
  });

  testWidgets('null renders em-dash', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CurrencyAmountText(amount: null))),
    );
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('renders negative USD correctly', (tester) async {
    final m = Money()
      ..currencyCode = 'USD'
      ..units = Int64(-2)
      ..nanos = -500000000;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CurrencyAmountText(amount: m)),
      ),
    );
    expect(find.text('-2.50 USD'), findsOneWidget);
  });

  testWidgets('hides currency when showCurrency=false', (tester) async {
    final m = Money()
      ..currencyCode = 'KES'
      ..units = Int64(100)
      ..nanos = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CurrencyAmountText(amount: m, showCurrency: false),
        ),
      ),
    );
    expect(find.text('100.00'), findsOneWidget);
  });
}
