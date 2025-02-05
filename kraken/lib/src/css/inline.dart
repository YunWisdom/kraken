// https://www.w3.org/TR/css-inline-3/



import 'package:kraken/css.dart';

/// Sets vertical alignment of an inline, inline-block
enum VerticalAlign {
  /// Aligns the baseline of the element with the baseline of its parent.
  baseline,

  /// Aligns the top of the element and its descendants with the top of the entire line.
  top,

  /// Aligns the bottom of the element and its descendants with the bottom of the entire line.
  bottom,

  /// Aligns the middle of the element with the baseline plus half the x-height of the parent.
  /// @TODO not supported
  ///  middle,
}

mixin CSSInlineMixin on RenderStyleBase {
  VerticalAlign _verticalAlign = VerticalAlign.baseline;
  VerticalAlign get verticalAlign => _verticalAlign;
  set verticalAlign(VerticalAlign value) {
    if (_verticalAlign != value) {
      renderBoxModel!.markNeedsLayout();
      _verticalAlign = value;
    }
  }

  void updateVerticalAlign(String value) {
    verticalAlign = parseVerticalAlign(value);
  }

  static VerticalAlign parseVerticalAlign(String verticalAlign) {
    switch (verticalAlign) {
      case TOP:
        return VerticalAlign.top;
      case BOTTOM:
        return VerticalAlign.bottom;
    }
    return VerticalAlign.baseline;
  }
}
