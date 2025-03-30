import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html;

String getQuerySelectorAttr(html.Element ele, String selector, String attr) {
  var res = '';
  try {
    if (ele.querySelector(selector) == null) return '';
    res = ele.querySelector(selector)!.attributes[attr] ?? '';
  } catch (e) {
    debugPrint('$selector: ${e.toString()}');
  }
  return res;
}

String getQuerySelectorText(html.Element ele, String selector) {
  var res = '';
  try {
    if (ele.querySelector(selector) == null) return '';
    res = ele.querySelector(selector)!.text;
  } catch (e) {
    debugPrint('$selector: ${e.toString()}');
  }
  return res;
}
