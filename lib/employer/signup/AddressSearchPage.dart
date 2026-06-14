import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() =>
      _AddressSearchPageState();
}

class _AddressSearchPageState
    extends State<AddressSearchPage> {

  late InAppWebViewController webViewController;

  final String htmlData = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<style>
html, body {
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
}

#postcode {
  width: 100%;
  height: 100%;
}
</style>
</head>

<body>

<div id="postcode"></div>

<script>

new daum.Postcode({

  oncomplete: function(data) {

    window.flutter_inappwebview.callHandler(
      'onSelectedAddress',
      {
        roadAddress: data.roadAddress,
        buildingName: data.buildingName,
        zonecode: data.zonecode
      }
    );
  }

}).embed(
  document.getElementById('postcode')
);

</script>

</body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30), // 앱바 위의 공간 height 30

            /// 커스텀 헤더 (앱바 역할)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '주소 검색',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24), // 중앙 정렬을 맞추기 위한 더미 공간
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: InAppWebView(
                initialData: InAppWebViewInitialData(
                  data: htmlData,

                  /// 추가
                  baseUrl: WebUri(
                    "https://localhost",
                  ),
                ),

                onWebViewCreated: (controller) {

                  webViewController = controller;

                  controller.addJavaScriptHandler(
                    handlerName:
                    'onSelectedAddress',

                    callback: (args) {

                      print(
                        "주소 선택 args = $args",
                      );

                      if (args.isNotEmpty) {

                        try {

                          final data =
                          Map<String, dynamic>.from(
                            args[0],
                          );

                          Navigator.pop(
                            context,
                            {
                              'roadAddress':
                              data['roadAddress'],
                              'buildingName':
                              data['buildingName'],
                              'zonecode':
                              data['zonecode'],
                            },
                          );

                        } catch (e) {

                          print(
                            "주소 변환 오류 : $e",
                          );
                        }
                      }

                      return null;
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}