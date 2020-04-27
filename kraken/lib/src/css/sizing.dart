/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Box Sizing: https://drafts.csswg.org/css-sizing-3/

final RegExp spaceRegExp = RegExp(r' ');

double _getDisplayPortedLength(input) {
  if (isEmptyStyleValue(input)) {
    // Null is not equal with 0.0
    return null;
  }
  if (input is num) {
    input = input.toString();
  }
  return CSSLength.toDisplayPortValue(input as String);
}

List<String> _getShorttedProperties(String input) {
  assert(input != null);
  return input.trim().split(spaceRegExp);
}

Padding _getPaddingFromStyle(CSSStyleDeclaration style) {
  double left = 0.0;
  double top = 0.0;
  double right = 0.0;
  double bottom = 0.0;

  if (style != null) {
    String padding = style['padding'];
    double paddingLeft;
    double paddingTop;
    double paddingRight;
    double paddingBottom;
    if (padding != null) {
      List<String> splitedpadding = _getShorttedProperties(padding);
      if (splitedpadding.length == 1) {
        paddingLeft = paddingRight = paddingTop =
            paddingBottom = _getDisplayPortedLength(splitedpadding[0]);
      } else if (splitedpadding.length == 2) {
        paddingTop =
            paddingBottom = _getDisplayPortedLength(splitedpadding[0]);
        paddingLeft =
            paddingRight = _getDisplayPortedLength(splitedpadding[1]);
      } else if (splitedpadding.length == 3) {
        paddingTop = _getDisplayPortedLength(splitedpadding[0]);
        paddingRight =
            paddingLeft = _getDisplayPortedLength(splitedpadding[1]);
        paddingBottom = _getDisplayPortedLength(splitedpadding[2]);
      } else if (splitedpadding.length == 4) {
        paddingTop = _getDisplayPortedLength(splitedpadding[0]);
        paddingRight = _getDisplayPortedLength(splitedpadding[1]);
        paddingBottom = _getDisplayPortedLength(splitedpadding[2]);
        paddingLeft = _getDisplayPortedLength(splitedpadding[3]);
      }
    }

    if (style.contains('paddingLeft'))
      paddingLeft = _getDisplayPortedLength(style['paddingLeft']);

    if (style.contains('paddingTop'))
      paddingTop = _getDisplayPortedLength(style['paddingTop']);

    if (style.contains('paddingRight'))
      paddingRight = _getDisplayPortedLength(style['paddingRight']);

    if (style.contains('paddingBottom'))
      paddingBottom = _getDisplayPortedLength(style['paddingBottom']);

    left = paddingLeft ?? left;
    top = paddingTop ?? top;
    right = paddingRight ?? right;
    bottom = paddingBottom ?? bottom;
  }

  return Padding(left, top, right, bottom);
}

/// - width
/// - height
/// - max-width
/// - max-height
/// - min-width
/// - min-height
mixin CSSSizingMixin {
  RenderConstrainedBox renderConstrainedBox;
  RenderMargin renderMargin;
  RenderPadding renderPadding;
  Padding oldPadding;
  Padding oldMargin;
  SizedConstraints oldConstraints;

  static double getDisplayPortedLength(input) {
    return _getDisplayPortedLength(input);
  }

  void updateConstraints(CSSStyleDeclaration style, Map<String, CSSTransition> transitionMap) {
    if (renderConstrainedBox != null) {
      CSSTransition allTransition,
          widthTransition,
          heightTransition,
          minWidthTransition,
          maxWidthTransition,
          minHeightTransition,
          maxHeightTransition;
      if (transitionMap != null) {
        allTransition = transitionMap['all'];
        widthTransition = transitionMap['width'];
        heightTransition = transitionMap['height'];
        minWidthTransition = transitionMap['min-width'];
        maxWidthTransition = transitionMap['max-width'];
        minHeightTransition = transitionMap['min-height'];
        maxHeightTransition = transitionMap['max-height'];
      }

      SizedConstraints newConstraints = _getConstraints(style);

      if (allTransition != null ||
          widthTransition != null ||
          heightTransition != null ||
          minWidthTransition != null ||
          maxWidthTransition != null ||
          minHeightTransition != null ||
          maxHeightTransition != null) {
        double diffWidth =
            (newConstraints.width ?? 0.0) - (oldConstraints.width ?? 0.0);
        double diffHeight =
            (newConstraints.height ?? 0.0) - (oldConstraints.height ?? 0.0);
        double diffMinWidth =
            (newConstraints.minWidth ?? 0.0) - (oldConstraints.minWidth ?? 0.0);
        double diffMaxWidth =
            (newConstraints.maxWidth ?? 0.0) - (oldConstraints.maxWidth ?? 0.0);
        double diffMinHeight = (newConstraints.minHeight ?? 0.0) -
            (oldConstraints.minHeight ?? 0.0);
        double diffMaxHeight = (newConstraints.maxHeight ?? 0.0) -
            (oldConstraints.maxHeight ?? 0.0);

        SizedConstraints progressConstraints = SizedConstraints(
            oldConstraints.width,
            oldConstraints.height,
            oldConstraints.minWidth,
            oldConstraints.maxWidth,
            oldConstraints.minHeight,
            oldConstraints.maxHeight);

        SizedConstraints baseConstraints = SizedConstraints(
            oldConstraints.width,
            oldConstraints.height,
            oldConstraints.minWidth,
            oldConstraints.maxWidth,
            oldConstraints.minHeight,
            oldConstraints.maxHeight);

        allTransition?.addProgressListener((progress) {
          if (widthTransition == null) {
            progressConstraints.width =
                diffWidth * progress + (baseConstraints.width ?? 0.0);
          }
          if (heightTransition == null) {
            progressConstraints.height =
                diffHeight * progress + (baseConstraints.height ?? 0.0);
          }
          if (minWidthTransition == null) {
            progressConstraints.minWidth =
                diffMinWidth * progress + (baseConstraints.minWidth ?? 0.0);
          }
          if (maxWidthTransition == null) {
            progressConstraints.maxWidth = diffMaxWidth * progress +
                (baseConstraints.maxWidth ?? double.infinity);
          }
          if (minHeightTransition == null) {
            progressConstraints.minHeight =
                diffMinHeight * progress + (baseConstraints.minHeight ?? 0.0);
          }
          if (maxHeightTransition == null) {
            progressConstraints.maxHeight = diffMaxHeight * progress +
                (baseConstraints.maxHeight ?? double.infinity);
          }
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
        widthTransition?.addProgressListener((progress) {
          progressConstraints.width =
              diffWidth * progress + (baseConstraints.width ?? 0.0);
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
        heightTransition?.addProgressListener((progress) {
          progressConstraints.height =
              diffHeight * progress + (baseConstraints.height ?? 0.0);
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
        minHeightTransition?.addProgressListener((progress) {
          progressConstraints.minHeight =
              diffWidth * progress + (baseConstraints.minHeight ?? 0.0);
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
        minWidthTransition?.addProgressListener((progress) {
          progressConstraints.minWidth =
              diffWidth * progress + (baseConstraints.minWidth ?? 0.0);
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
        maxHeightTransition?.addProgressListener((progress) {
          progressConstraints.maxHeight = diffWidth * progress +
              (baseConstraints.maxHeight ?? double.infinity);
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
        maxWidthTransition?.addProgressListener((progress) {
          progressConstraints.maxWidth = diffWidth * progress +
              (baseConstraints.maxWidth ?? double.infinity);
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
      } else {
        renderConstrainedBox.additionalConstraints =
            newConstraints.toBoxConstraints();
      }

      // Remove inline element dimension
      if (style['display'] == 'inline') {
        renderConstrainedBox.additionalConstraints = BoxConstraints();
      }

      oldConstraints = newConstraints;
    }
  }

  RenderObject initRenderConstrainedBox(
      RenderObject renderObject, CSSStyleDeclaration style) {
    if (style != null) {
      oldConstraints = _getConstraints(style);
      return renderConstrainedBox = RenderConstrainedBox(
        additionalConstraints: oldConstraints.toBoxConstraints(),
        child: renderObject,
      );
    } else {
      return renderObject;
    }
  }

  SizedConstraints _getConstraints(CSSStyleDeclaration style) {
    if (style != null) {
      double width = getDisplayPortedLength(style['width']);
      double height = getDisplayPortedLength(style['height']);
      double minHeight = getDisplayPortedLength(style['minHeight']);
      double maxWidth = getDisplayPortedLength(style['maxWidth']);
      double maxHeight = getDisplayPortedLength(style['maxHeight']);
      double minWidth = getDisplayPortedLength(style['minWidth']);
      return SizedConstraints(
        width, height, minWidth, maxWidth, minHeight, maxHeight);
    } else {
      return null;
    }
  }

  static List<String> getShorttedProperties(String input) {
    return _getShorttedProperties(input);
  }

  RenderObject initRenderMargin(
      RenderObject renderObject, CSSStyleDeclaration style) {
    EdgeInsets edgeInsets = getMarginInsetsFromStyle(style);
    return renderMargin = RenderMargin(
      margin: edgeInsets,
      child: renderObject,
    );
  }

  Padding getMarginFromStyle(CSSStyleDeclaration style) {
    double left = 0.0;
    double top = 0.0;
    double right = 0.0;
    double bottom = 0.0;

    if (style != null) {
      var margin = style['margin'];
      if (margin is! String) {
        margin = margin.toString();
      }

      double marginLeft;
      double marginTop;
      double marginRight;
      double marginBottom;
      if (margin != null) {
        List<String> splitedMargin = getShorttedProperties(margin);
        if (splitedMargin.length == 1) {
          marginLeft = marginRight = marginTop =
              marginBottom = getDisplayPortedLength(splitedMargin[0]);
        } else if (splitedMargin.length == 2) {
          marginTop = marginBottom = getDisplayPortedLength(splitedMargin[0]);
          marginLeft = marginRight = getDisplayPortedLength(splitedMargin[1]);
        } else if (splitedMargin.length == 3) {
          marginTop = getDisplayPortedLength(splitedMargin[0]);
          marginRight = marginLeft = getDisplayPortedLength(splitedMargin[1]);
          marginBottom = getDisplayPortedLength(splitedMargin[2]);
        } else if (splitedMargin.length == 4) {
          marginTop = getDisplayPortedLength(splitedMargin[0]);
          marginRight = getDisplayPortedLength(splitedMargin[1]);
          marginBottom = getDisplayPortedLength(splitedMargin[2]);
          marginLeft = getDisplayPortedLength(splitedMargin[3]);
        }
      }

      if (style.contains('marginLeft'))
        marginLeft = getDisplayPortedLength(style['marginLeft']);

      if (style.contains('marginTop'))
        marginTop = getDisplayPortedLength(style['marginTop']);

      if (style.contains('marginRight'))
        marginRight = getDisplayPortedLength(style['marginRight']);

      if (style.contains('marginBottom'))
        marginBottom = getDisplayPortedLength(style['marginBottom']);

      left = marginLeft ?? left;
      top = marginTop ?? top;
      right = marginRight ?? right;
      bottom = marginBottom ?? bottom;
    }
    return Padding(left, top, right, bottom);
  }

  EdgeInsets getMarginInsetsFromStyle(CSSStyleDeclaration style) {
    oldMargin = getMarginFromStyle(style);
    return EdgeInsets.fromLTRB(
        oldMargin.left, oldMargin.top, oldMargin.right, oldMargin.bottom);
  }

  void updateRenderMargin(CSSStyleDeclaration style, [Map<String, CSSTransition> transitionMap]) {
    assert(renderMargin != null);
    CSSTransition all, margin, marginLeft, marginRight, marginBottom, marginTop;
    if (transitionMap != null) {
      all = transitionMap["all"];
      margin = transitionMap["margin"];
      marginLeft = transitionMap["margin-left"];
      marginRight = transitionMap["margin-right"];
      marginBottom = transitionMap["margin-bottom"];
      marginTop = transitionMap["margin-top"];
    }
    if (all != null ||
        margin != null ||
        marginBottom != null ||
        marginLeft != null ||
        marginRight != null ||
        marginTop != null) {
      Padding newMargin = getMarginFromStyle(style);

      double marginLeftInterval = newMargin.left - oldMargin.left;
      double marginRightInterval = newMargin.right - oldMargin.right;
      double marginTopInterval = newMargin.top - oldMargin.top;
      double marginBottomInterval = newMargin.bottom - oldMargin.bottom;

      Padding progressMargin = Padding(
          oldMargin.left, oldMargin.top, oldMargin.right, oldMargin.bottom);
      Padding baseMargin = Padding(
          oldMargin.left, oldMargin.top, oldMargin.right, oldMargin.bottom);

      all?.addProgressListener((progress) {
        if (margin == null) {
          if (marginTop == null) {
            progressMargin.top = progress * marginTopInterval + baseMargin.top;
          }
          if (marginBottom == null) {
            progressMargin.bottom =
                progress * marginBottomInterval + baseMargin.bottom;
          }
          if (marginLeft == null) {
            progressMargin.left =
                progress * marginLeftInterval + baseMargin.left;
          }
          if (marginRight == null) {
            progressMargin.right =
                progress * marginRightInterval + baseMargin.right;
          }
          _updateMargin(
              EdgeInsets.fromLTRB(progressMargin.left, progressMargin.top,
                  progressMargin.right, progressMargin.bottom));
        }
      });

      margin?.addProgressListener((progress) {
        if (marginTop == null) {
          progressMargin.top = progress * marginTopInterval + baseMargin.top;
        }
        if (marginBottom == null) {
          progressMargin.bottom =
              progress * marginBottomInterval + baseMargin.bottom;
        }
        if (marginLeft == null) {
          progressMargin.left = progress * marginLeftInterval + baseMargin.left;
        }
        if (marginRight == null) {
          progressMargin.right =
              progress * marginRightInterval + baseMargin.right;
        }
        _updateMargin(
            EdgeInsets.fromLTRB(progressMargin.left, progressMargin.top,
                progressMargin.right, progressMargin.bottom));
      });
      marginTop?.addProgressListener((progress) {
        progressMargin.top = progress * marginTopInterval + baseMargin.top;
        renderMargin.margin = EdgeInsets.fromLTRB(progressMargin.left,
            progressMargin.top, progressMargin.right, progressMargin.bottom);
      });
      marginBottom?.addProgressListener((progress) {
        progressMargin.bottom =
            progress * marginBottomInterval + baseMargin.bottom;
        _updateMargin(
            EdgeInsets.fromLTRB(progressMargin.left, progressMargin.top,
                progressMargin.right, progressMargin.bottom));
      });
      marginLeft?.addProgressListener((progress) {
        progressMargin.left = progress * marginLeftInterval + baseMargin.left;
        _updateMargin(
            EdgeInsets.fromLTRB(progressMargin.left, progressMargin.top,
                progressMargin.right, progressMargin.bottom));
      });
      marginRight?.addProgressListener((progress) {
        progressMargin.right =
            progress * marginRightInterval + baseMargin.right;
        _updateMargin(
            EdgeInsets.fromLTRB(progressMargin.left, progressMargin.top,
                progressMargin.right, progressMargin.bottom));
      });
      oldMargin = newMargin;
    } else {
      _updateMargin(getMarginInsetsFromStyle(style));
    }
  }

  void _updateMargin(EdgeInsets margin) {
    renderMargin.margin = margin;
  }

  RenderObject initRenderPadding(RenderObject renderObject, CSSStyleDeclaration style) {
    EdgeInsets edgeInsets = getPaddingInsetsFromStyle(style);
    return renderPadding =
        RenderPadding(padding: edgeInsets, child: renderObject);
  }

  Padding getPaddingFromStyle(CSSStyleDeclaration style) {
    return _getPaddingFromStyle(style);
  }

  EdgeInsets getPaddingInsetsFromStyle(CSSStyleDeclaration style) {
    oldPadding = getPaddingFromStyle(style);
    return EdgeInsets.fromLTRB(
        oldPadding.left, oldPadding.top, oldPadding.right, oldPadding.bottom);
  }

  void updateRenderPadding(CSSStyleDeclaration style,
      [Map<String, CSSTransition> transitionMap]) {
    assert(renderPadding != null);
    CSSTransition all,
        padding,
        paddingLeft,
        paddingRight,
        paddingBottom,
        paddingTop;
    if (transitionMap != null) {
      all = transitionMap["all"];
      padding = transitionMap["padding"];
      paddingLeft = transitionMap["padding-left"];
      paddingRight = transitionMap["padding-right"];
      paddingBottom = transitionMap["padding-bottom"];
      paddingTop = transitionMap["padding-top"];
    }
    if (all != null ||
        padding != null ||
        paddingBottom != null ||
        paddingLeft != null ||
        paddingRight != null ||
        paddingTop != null) {
      Padding newPadding = getPaddingFromStyle(style);

      double paddingLeftInterval = newPadding.left - oldPadding.left;
      double paddingRightInterval = newPadding.right - oldPadding.right;
      double paddingTopInterval = newPadding.top - oldPadding.top;
      double paddingBottomInterval = newPadding.bottom - oldPadding.bottom;

      Padding progressPadding = Padding(
          oldPadding.left, oldPadding.top, oldPadding.right, oldPadding.bottom);
      Padding basePadding = Padding(
          oldPadding.left, oldPadding.top, oldPadding.right, oldPadding.bottom);

      all?.addProgressListener((progress) {
        if (padding == null) {
          if (paddingTop == null) {
            progressPadding.top =
                progress * paddingTopInterval + basePadding.top;
          }
          if (paddingBottom == null) {
            progressPadding.bottom =
                progress * paddingBottomInterval + basePadding.bottom;
          }
          if (paddingLeft == null) {
            progressPadding.left =
                progress * paddingLeftInterval + basePadding.left;
          }
          if (paddingRight == null) {
            progressPadding.right =
                progress * paddingRightInterval + basePadding.right;
          }

          renderPadding.padding = EdgeInsets.fromLTRB(
              progressPadding.left,
              progressPadding.top,
              progressPadding.right,
              progressPadding.bottom);
        }
      });
      padding?.addProgressListener((progress) {
        if (paddingTop == null) {
          progressPadding.top = progress * paddingTopInterval + basePadding.top;
        }
        if (paddingBottom == null) {
          progressPadding.bottom =
              progress * paddingBottomInterval + basePadding.bottom;
        }
        if (paddingLeft == null) {
          progressPadding.left =
              progress * paddingLeftInterval + basePadding.left;
        }
        if (paddingRight == null) {
          progressPadding.right =
              progress * paddingRightInterval + basePadding.right;
        }

        renderPadding.padding = EdgeInsets.fromLTRB(progressPadding.left,
            progressPadding.top, progressPadding.right, progressPadding.bottom);
      });
      paddingTop?.addProgressListener((progress) {
        progressPadding.top = progress * paddingTopInterval + basePadding.top;
        renderPadding.padding = EdgeInsets.fromLTRB(progressPadding.left,
            progressPadding.top, progressPadding.right, progressPadding.bottom);
      });
      paddingBottom?.addProgressListener((progress) {
        progressPadding.bottom =
            progress * paddingBottomInterval + basePadding.bottom;
        renderPadding.padding = EdgeInsets.fromLTRB(progressPadding.left,
            progressPadding.top, progressPadding.right, progressPadding.bottom);
      });
      paddingLeft?.addProgressListener((progress) {
        progressPadding.left =
            progress * paddingLeftInterval + basePadding.left;
        renderPadding.padding = EdgeInsets.fromLTRB(progressPadding.left,
            progressPadding.top, progressPadding.right, progressPadding.bottom);
      });
      paddingRight?.addProgressListener((progress) {
        progressPadding.right =
            progress * paddingRightInterval + basePadding.right;
        renderPadding.padding = EdgeInsets.fromLTRB(progressPadding.left,
            progressPadding.top, progressPadding.right, progressPadding.bottom);
      });
      oldPadding = newPadding;
    }

    EdgeInsets edgeInsets = getPaddingInsetsFromStyle(style);

    // Update renderPadding.
    renderPadding.padding = edgeInsets;
  }
}

class Padding {
  double left;
  double top;
  double right;
  double bottom;

  Padding(this.left, this.top, this.right, this.bottom);
}

class SizedConstraints {
  double width;
  double height;
  double minWidth;
  double maxWidth;
  double minHeight;
  double maxHeight;

  SizedConstraints(this.width, this.height, this.minWidth, this.maxWidth,
      this.minHeight, this.maxHeight);

  BoxConstraints toBoxConstraints() {
    return BoxConstraints(
      minWidth: minWidth ?? width ?? 0.0,
      minHeight: minHeight ?? height ?? 0.0,
      maxWidth: maxWidth ?? width ?? double.infinity,
      maxHeight: maxHeight ?? height ?? double.infinity,
    );
  }

  @override
  String toString() {
    return 'SizedConstraints(width:$width, height: $height, minWidth: $minWidth, maxWidth: $maxWidth, minHeight: $minHeight, maxHeight: $maxHeight)';
  }
}
