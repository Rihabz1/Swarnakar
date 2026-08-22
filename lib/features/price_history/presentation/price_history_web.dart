import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

const String _viewType = 'price-history-iframe';
bool _registered = false;
String _latestHtml = '';

Widget buildPriceHistoryWebView(String htmlContent) {
  _latestHtml = htmlContent;
  if (!_registered) {
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final element = web.HTMLIFrameElement()
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#0A0E21'
        ..setAttribute('srcdoc', _latestHtml);
      return element;
    });
    _registered = true;
  }
  return const HtmlElementView(viewType: _viewType);
}
