// PS-FLOW-08 회귀 방지 테스트.
//
// 온보딩(프로필 입력) 화면은 `_RootGate`(main.dart)가 "세션 있음 + 프로필 없음"일 때
// 무조건 띄우는 화면이라, 여기서 빠져나갈 수단이 사라지면 사용자가 스스로 복구할 수
// 없는 데드엔드가 된다(S2). 아래 세 케이스가 그 탈출 경로를 고정한다.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pray_story/l10n/app_localizations.dart';
import 'package:pray_story/screens/auth/signup_step2_screen.dart';
import 'package:pray_story/screens/auth/widgets/profile_form.dart';

Widget _app({required Widget home}) => ProviderScope(
      child: MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

void main() {
  setUpAll(() {
    // 테스트 중 폰트 네트워크 페치 금지(폴백 폰트로 렌더).
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
      'PS-FLOW-08: 온보딩 프로필 화면에 로그아웃 수단이 노출된다',
      (tester) async {
    await tester.pumpWidget(_app(home: const SignupStep2Screen()));
    await tester.pumpAndSettle();

    // 이 액션이 사라지면 세션은 있고 프로필은 없는 사용자가 다른 계정·다른
    // 로그인 수단으로 전환할 방법이 앱 전체에서 없어진다.
    expect(find.byType(OnboardingLogoutAction), findsOneWidget);
    expect(find.text('로그아웃'), findsOneWidget);
  });

  testWidgets(
      'OnboardingExitGuard: pop 가능한 화면(Step3 상당)은 종료 다이얼로그 없이 뒤로 간다',
      (tester) async {
    await tester.pumpWidget(_app(
      home: const Scaffold(body: Text('root')),
    ));

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(MaterialPageRoute(
      builder: (_) => const OnboardingExitGuard(
        child: Scaffold(body: Text('pushed')),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('pushed'), findsOneWidget);

    // AppBar 뒤로가기·시스템 뒤로가기가 모두 타는 경로.
    navigator.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('앱을 종료할까요?'), findsNothing,
        reason: '쌓인 화면에서 뒤로가기는 앱 종료가 아니라 이전 단계 복귀여야 한다');
    expect(find.text('root'), findsOneWidget);
  });

  testWidgets(
      'OnboardingExitGuard: 루트 화면에서는 즉시 종료되지 않고 확인을 묻는다',
      (tester) async {
    await tester.pumpWidget(_app(
      home: const OnboardingExitGuard(
        child: Scaffold(body: Text('onboarding root')),
      ),
    ));
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('앱을 종료할까요?'), findsOneWidget);
    expect(find.text('onboarding root'), findsOneWidget);
  });
}
