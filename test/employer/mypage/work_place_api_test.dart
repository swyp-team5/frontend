import 'package:chack_chack/employer/mypage/api/work_place_api.dart';
import 'package:chack_chack/employer/mypage/RWorkPlaceCreatePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkPlaceApi payload helpers', () {
    test('normalizes phone number by keeping digits only', () {
      expect(WorkPlaceApi.normalizePhoneNumber('02-1234-5678'), '0212345678');
      expect(WorkPlaceApi.normalizePhoneNumber('1588 1234'), '15881234');
    });

    test('normalizes blank phone number to null', () {
      expect(WorkPlaceApi.normalizePhoneNumber(''), isNull);
      expect(WorkPlaceApi.normalizePhoneNumber('   '), isNull);
    });

    test('creates additional workplace payload with optional phone number', () {
      final request = WorkPlaceCreateRequest(
        size: 'FIVE_TO_NINE',
        name: '강남점',
        roadAddress: '서울 강남구 테헤란로 1',
        detailAddress: '3층',
        phoneNumber: '02-1234-5678',
      );

      expect(request.toJson(), {
        'size': 'FIVE_TO_NINE',
        'name': '강남점',
        'roadAddress': '서울 강남구 테헤란로 1',
        'detailAddress': '3층',
        'phoneNumber': '0212345678',
      });
    });

    test('parses workplace response including nullable phone number', () {
      final workPlace = WorkPlaceSummary.fromJson({
        'workPlaceId': 7,
        'name': '강남점',
        'size': 'FIVE_TO_NINE',
        'roadAddress': '서울 강남구 테헤란로 1',
        'detailAddress': null,
        'phoneNumber': null,
        'ownerMemberId': 1,
        'crewId': 9,
        'crewRole': 'OWNER',
        'joinStatus': 'APPROVED',
        'crewStatus': 'ACTIVE',
        'workPlaceStatus': 'ACTIVE',
      });

      expect(workPlace.workPlaceId, 7);
      expect(workPlace.phoneNumber, isNull);
      expect(workPlace.displayPhoneNumber, '등록된 번호 없음');
    });
  });

  testWidgets('workplace creation only shows backend-supported sizes', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RWorkPlaceCreatePage()));

    expect(find.text('18~23명'), findsOneWidget);
    expect(find.text('24명 이상'), findsNothing);
  });
}
