import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:swarnakar/core/constants/app_strings.dart';
import 'package:swarnakar/core/theme/app_colors.dart';
import 'package:swarnakar/core/theme/app_text_styles.dart';
import 'package:swarnakar/shared/widgets/app_bottom_nav.dart';
import 'price_history_web_stub.dart'
    if (dart.library.html) 'price_history_web.dart';

class PriceHistoryScreen extends StatefulWidget {
  const PriceHistoryScreen({super.key});

  @override
  State<PriceHistoryScreen> createState() => _PriceHistoryScreenState();
}

class _PriceHistoryScreenState extends State<PriceHistoryScreen> {
  static const String _html = '''
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
      html, body {
        margin: 0;
        padding: 0;
        background: #0A0E21;
        color: #fff;
        height: 100%;
      }
      #goldr-widget-container {
        width: 100%;
        min-height: 100vh;
      }
    </style>
  </head>
  <body>
    <div id="goldr-widget-container"></div>
    <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
    <script src="https://www.goldr.org/widget.js?fixed"></script>
  </body>
</html>
''';

  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF0A0E21))
        ..loadHtmlString(_html);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = kIsWeb
        ? buildPriceHistoryWebView(_html)
        : (_controller == null
            ? const SizedBox.shrink()
            : WebViewWidget(controller: _controller!));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            context.go('/dashboard');
          },
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.gold,
            size: 18,
          ),
        ),
        title: Text(
          AppStrings.priceHistoryTitle,
          style: AppTextStyles.hindSiliguri(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.18),
              ),
            ),
            child: content,
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.getIndexFromRoute('/price-history'),
        onTap: (index) {},
      ),
    );
  }
}
