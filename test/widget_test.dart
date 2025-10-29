import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bussv1/main.dart';

void main() {
  testWidgets('App inicializa com tela de onboarding', (WidgetTester tester) async {
    // Monta o app principal
    await tester.pumpWidget(const MyApp());

    // Verifica se o texto "Bem-vindo ao BusSV!" aparece na tela
    expect(find.text('Bem-vindo ao BusSV!'), findsOneWidget);
  });
}
