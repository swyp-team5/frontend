import 'dart:convert';
import 'dart:io';

import 'package:chack_chack/common/onboarding/providers/signup_provider.dart';
import 'package:chack_chack/common/onboarding/signup/CommonSignUpPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../api/auth_sociallLogin_api.dart';
import '../../service/social_login_service.dart';
import '../auth/server_token_manager.dart';
import '../login/KakaoLoginService.dart';
import 'models/signup_request.dart';


class OnboardingBottomSheet extends ConsumerWidget {
  const OnboardingBottomSheet({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //----------------------------------
              // Drag Handle
              //----------------------------------

              Container(
                width: 56,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xffE5E5E5),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 28),

              //----------------------------------
              // Title
              //----------------------------------

              const Text(
                "스케줄 관리를 더 쉽고 간편하게",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              const Divider(
                height: 1,
                color: Color(0xffECECEC),
              ),

              const SizedBox(height: 20),

              //----------------------------------
              // Kakao
              //----------------------------------

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final result = await KakaoLoginService.login();

                      // 1. 이미 가입된 유저인 경우 서버 토큰이 바로 오므로 저장
                      if (result["serverAccessToken"] != null) {
                        await ServerTokenManager.saveTokens(
                          accessToken: result["serverAccessToken"],
                          refreshToken: result["serverRefreshToken"],
                        );
                      }

                      final notifier = ref.read(signupProvider.notifier);
                      notifier.setProvider(SocialProvider.KAKAO);

                      // 2. 가입에 필요한 카카오 액세스 토큰 저장
                      notifier.setAccessToken(result["kakaoAccessToken"]);

                      // 3. 디바이스 정보 저장
                      notifier.setDevice(
                        deviceId: result["deviceId"] ?? "",
                        platform: result["platform"] ?? "",
                        appVersion: result["appVersion"] ?? "",
                      );

                      if (!context.mounted) return;

                      // 회원가입 페이지(이름 입력)로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CommonSignUpPage(),
                        ),
                      );
                    } catch (e) {
                      debugPrint(e.toString());

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("카카오 로그인 실패\n$e"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFFEB3B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Image.asset(
                    "assets/images/logo/kakaotalk.png",
                    width: 40,
                    height: 40,
                  ),
                  label: const Text(
                    "카카오로 시작하기",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // //----------------------------------
              // // Google
              // //----------------------------------
              //
              // SizedBox(
              //   width: double.infinity,
              //   height: 56,
              //   child: OutlinedButton(
              //       onPressed: () async {
              //         // try {
              //         //   final result = await KakaoLoginService.login();
              //         //
              //         //   debugPrint("===== Kakao Login Success =====");
              //         //   debugPrint(result.toString());
              //         //
              //         //   // 서버 JWT 저장
              //         //   await ServerTokenManager.saveTokens(
              //         //     accessToken: result["serverAccessToken"],
              //         //     refreshToken: result["serverRefreshToken"],
              //         //   );
              //         //
              //         //   final notifier = ref.read(signupProvider.notifier);
              //         //
              //         //   notifier.setProvider(SocialProvider.KAKAO);
              //         //
              //         //   // Provider에도 서버 JWT 저장
              //         //   notifier.setAccessToken(result["serverAccessToken"]);
              //         //   notifier.setRefreshToken(result["serverRefreshToken"]);
              //         //
              //         //   notifier.setDevice(
              //         //     deviceId: result["deviceId"],
              //         //     platform: result["platform"],
              //         //     appVersion: result["appVersion"],
              //         //   );
              //         //
              //         //   // 저장 확인
              //         //   final token = await ServerTokenManager.getAccessToken();
              //         //   debugPrint("===== SAVED TOKEN =====");
              //         //   debugPrint(token);
              //         //
              //         //   if (!context.mounted) return;
              //         //
              //         //   Navigator.push(
              //         //     context,
              //         //     MaterialPageRoute(
              //         //       builder: (_) => const CommonSignUpPage(),
              //         //     ),
              //         //   );
              //         // } catch (e) {
              //         //   debugPrint(e.toString());
              //         //
              //         //   if (!context.mounted) return;
              //         //
              //         //   ScaffoldMessenger.of(context).showSnackBar(
              //         //     SnackBar(
              //         //       content: Text("카카오 로그인 실패\n$e"),
              //         //     ),
              //         //   );
              //         // }
              //       },
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Image.asset(
              //           "assets/images/logo/google.png",
              //           width: 22,
              //           height: 22,
              //         ),
              //         const SizedBox(width: 12),
              //         const Text(
              //           "Google로 시작하기",
              //           style: TextStyle(
              //             color: Colors.black,
              //             fontSize: 16,
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //       ],
              //     )
              //   ),
              // ),
              //
              // const SizedBox(height: 14),
              //
              // //----------------------------------
              // // Apple
              // //----------------------------------
              //
              // SizedBox(
              //   width: double.infinity,
              //   height: 56,
              //   child: OutlinedButton(
              //       onPressed: () async {
              //         try {
              //           final result = await SocialLoginService.appleLogin();
              //
              //           print(result);
              //
              //         } catch (e) {
              //           debugPrint(e.toString());
              //         }
              //       },
              //     style: OutlinedButton.styleFrom(
              //       side: const BorderSide(
              //         color: Color(0xffE5E5E5),
              //       ),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Image.asset(
              //           "assets/images/logo/apple.png",
              //           width: 22,
              //           height: 22,
              //         ),
              //         const SizedBox(width: 12),
              //         const Text(
              //           "Apple로 시작하기",
              //           style: TextStyle(
              //             color: Colors.black,
              //             fontSize: 16,
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //       ],
              //     )
              //   ),
              // ),
              //
              // const SizedBox(height: 32),

              //----------------------------------
              // 로그인
              //----------------------------------

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "이미 계정이 있거나 초대받았다면 ",
                    style: TextStyle(
                      color: Color(0xff505050),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CommonSignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "바로 시작하기",
                      style: TextStyle(
                        color: Color(0xff0084FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}