import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html;

String getQuerySelectorAttr(html.Element ele, String selector, String attr) {
  var res = '';
  try {
    if (ele.querySelector(selector) == null) return '';
    res = ele.querySelector(selector)!.attributes[attr] ?? '';
    res = res.trim();
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
    res = res.trim();
  } catch (e) {
    debugPrint('$selector: ${e.toString()}');
  }
  return res;
}

String getQuerySelectorTextDom(html.Document dom, String selector) {
  var res = '';
  try {
    if (dom.querySelector(selector) == null) return '';
    res = dom.querySelector(selector)!.text;
    res = res.trim();
  } catch (e) {
    debugPrint('$selector: ${e.toString()}');
  }
  return res;
}
