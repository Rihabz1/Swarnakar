// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';

const String _viewType = 'price-history-iframe';
bool _registered = false;
String _latestHtml = '';

Widget buildPriceHistoryWebView(String htmlContent) {
  _latestHtml = htmlContent;
  if (!_registered) {
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final element = html.IFrameElement()
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#0A0E21'
        ..srcdoc = _latestHtml;
      return element;
    });
    _registered = true;
  }
  return const HtmlElementView(viewType: _viewType);
}
