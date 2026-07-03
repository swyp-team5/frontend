import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ECrewPage.dart';
import 'package:dio/dio.dart';
import '../../common/auth/server_token_manager.dart';

class ECrewCodePage extends StatefulWidget {
  const ECrewCodePage({super.key});

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

  Future<void> _checkInviteCode() async {
    try {
      final token = await ServerTokenManager.getValidAccessToken();

      if (token == null) {
        setState(() {
          isMatched = false;
        });
        return;
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: "https://chackchack.shop",
        ),
      );

      final response = await dio.post(
        "/api/crew-invitations/$inviteCode/accept",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      debugPrint(response.data.toString());

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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                    (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: SizedBox(
                    width: 54,
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
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: borderColor,
                            width: 2,
                          ),
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                      ),
                      onChanged: (v) => _onChanged(index, v),
                    ),
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