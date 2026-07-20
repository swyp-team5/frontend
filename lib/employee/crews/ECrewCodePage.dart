import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ECrewPage.dart';
import 'package:dio/dio.dart';
import '../../common/auth/server_token_manager.dart';

class ECrewCodePage extends StatefulWidget {
  final String? initialCode;

  const ECrewCodePage({super.key, this.initialCode});

  @override
  State<ECrewCodePage> createState() => _ECrewCodePageState();
}

class _ECrewCodePageState extends State<ECrewCodePage> {
  final List<TextEditingController> controllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
  List.generate(6, (_) => FocusNode());

  /// true = 파란색(성공)
  /// false = 빨간색(실패)
  bool isMatched = true;

  bool get isCompleted =>
      controllers.every((e) => e.text.isNotEmpty);

  @override
  void initState() {
    super.initState();

    final code = widget.initialCode;

    // 딥링크로 들어온 6자리 숫자 코드가 있으면 자동으로 채워넣기
    if (code != null && code.length == 6 && int.tryParse(code) != null) {
      for (int i = 0; i < 6; i++) {
        controllers[i].text = code[i];
      }

      // 화면이 다 그려진 직후 자동으로 검증까지 진행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkInviteCode();
      });
    }
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get inviteCode =>
      controllers.map((e) => e.text).join();

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    setState(() {});
  }

  // 코드 초대 검증
  Future<void> _checkInviteCode() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();

      if (token == null) {
        setState(() {
          isMatched = false;
        });
        return;
      }

      final dio = ServerTokenManager.authorizedDio;

      final response = await dio.post(
        "/api/crew-invitations/$inviteCode/accept",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      debugPrint("========== ACCEPT ==========");
      debugPrint(response.data.toString());

      // ✅ 방금 가입한 매장을 홈 화면에서 우선 보여주기 위해,
      // accept 응답의 workPlaceId/workPlaceName을 selectedWorkPlaceId로 저장한다.
      // (EHomePage._loadMyWorkPlace()가 이 값을 우선 사용하도록 이미 구현되어 있음)
      //
      // accept 성공 응답 예시:
      // {
      //   "crewId": 20,
      //   "workPlaceId": 10,
      //   "workPlaceName": "스위프",
      //   "joinStatus": "APPROVED",
      //   "crewRole": "WORKER",
      //   "status": "ACTIVE"
      // }
      final data = response.data;
      final int? joinedWorkPlaceId =
      data is Map ? data['workPlaceId'] as int? : null;
      final String? joinedWorkPlaceName =
      data is Map ? data['workPlaceName'] as String? : null;

      if (joinedWorkPlaceId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("selectedWorkPlaceId", joinedWorkPlaceId);

        if (joinedWorkPlaceName != null) {
          await prefs.setString(
            "selectedWorkPlaceName",
            joinedWorkPlaceName,
          );
        }

        debugPrint(
          "✅ 가입한 매장을 selectedWorkPlaceId로 저장: "
              "$joinedWorkPlaceId ($joinedWorkPlaceName)",
        );
      } else {
        debugPrint("⚠️ accept 응답에 workPlaceId가 없습니다: $data");
      }

      setState(() {
        isMatched = true;
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const ECrewPage(),
        ),
            (route) => false,
      );
    } on DioException catch (e) {
      debugPrint("status = ${e.response?.statusCode}");
      debugPrint("body = ${e.response?.data}");

      setState(() {
        isMatched = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isMatched = false;
      });
    }
  }

  Color get borderColor =>
      isMatched ? const Color(0xFF0084FF) : const Color(0xFFFF4B4B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
            ),

            const Spacer(),

            if (!isMatched)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.info,
                    color: Color(0xFFFF4B4B),
                    size: 20,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "초대 코드가 일치하지 않습니다",
                    style: TextStyle(
                      color: Color(0xFFFF4B4B),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

            if (!isMatched) const SizedBox(height: 28),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 384),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      for (int index = 0; index < 6; index++) ...[
                        if (index > 0) const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 80,
                            child: TextField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: const Color(0xFFF4F4F4),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: borderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onChanged: (v) => _onChanged(index, v),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              "6자리의 초대 코드를 입력하고\n크루에 입장하세요",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                22,
                0,
                22,
                32,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isCompleted
                      ? _checkInviteCode
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                    const Color(0xFF0084FF),
                    disabledBackgroundColor:
                    const Color(0xFF8DC2FF),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "크루 입장하기",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
