import 'dart:math' as math;
import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/content_area.dart';
import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/layout_child_type.dart';
import 'package:easy_table/src/experimental/table_layout_parent_data_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TableLayoutRenderBoxExp<ROW> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableLayoutParentDataExp>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableLayoutParentDataExp> {
  TableLayoutRenderBoxExp(
      {required TableLayoutSettings layoutSettings,
      required TablePaintSettings paintSettings,
      required ColumnsMetricsExp leftPinnedColumnsMetrics,
      required ColumnsMetricsExp unpinnedColumnsMetrics,
      required ColumnsMetricsExp rightPinnedColumnsMetrics,
      required List<ROW> rows})
      : _layoutSettings = layoutSettings,
        _paintSettings = paintSettings,
        _leftPinnedContentArea = ContentArea(
            id: ContentAreaId.leftPinned,
            columnsMetrics: leftPinnedColumnsMetrics,
            headerAreaDebugColor: Colors.yellow[300]!,
            scrollbarAreaDebugColor: Colors.yellow[200]!),
        _unpinnedContentArea = ContentArea(
            id: ContentAreaId.unpinned,
            columnsMetrics: unpinnedColumnsMetrics,
            headerAreaDebugColor: Colors.lime[300]!,
            scrollbarAreaDebugColor: Colors.lime[200]!),
        _rightPinnedContentArea = ContentArea(
            id: ContentAreaId.rightPinned,
            columnsMetrics: rightPinnedColumnsMetrics,
            headerAreaDebugColor: Colors.orange[300]!,
            scrollbarAreaDebugColor: Colors.orange[200]!),
        _rows = rows;

  final ContentArea _leftPinnedContentArea;
  final ContentArea _unpinnedContentArea;
  final ContentArea _rightPinnedContentArea;

  late final Map<ContentAreaId, ContentArea> _contentAreaMap = {
    ContentAreaId.leftPinned: _leftPinnedContentArea,
    ContentAreaId.unpinned: _unpinnedContentArea,
    ContentAreaId.rightPinned: _rightPinnedContentArea
  };

  //TODO remove?
  List<ROW> _rows;
  set rows(List<ROW> value) {
    _rows = value;
  }

  TableLayoutSettings _layoutSettings;
  set layoutSettings(TableLayoutSettings value) {
    if (_layoutSettings != value) {
      _layoutSettings = value;
      markNeedsLayout();
    }
  }

  TablePaintSettings _paintSettings;
  set paintSettings(TablePaintSettings value) {
    if (_paintSettings != value) {
      _paintSettings = value;
      markNeedsPaint();
    }
  }

  set leftPinnedColumnsMetrics(ColumnsMetricsExp value) {
    if (_leftPinnedContentArea.columnsMetrics != value) {
      _leftPinnedContentArea.columnsMetrics = value;
      markNeedsLayout();
    }
  }

  set unpinnedColumnsMetrics(ColumnsMetricsExp value) {
    if (_unpinnedContentArea.columnsMetrics != value) {
      _unpinnedContentArea.columnsMetrics = value;
      markNeedsLayout();
    }
  }

  set rightPinnedColumnsMetrics(ColumnsMetricsExp value) {
    if (_rightPinnedContentArea.columnsMetrics != value) {
      _rightPinnedContentArea.columnsMetrics = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableLayoutParentDataExp) {
      child.parentData = TableLayoutParentDataExp();
    }
  }

  @override
  void performLayout() {
    _forEachContentArea((area) => area.clear());

    RenderBox? verticalScrollbar;
    List<RenderBox> children = [];
    visitChildren((child) {
      RenderBox renderBox = child as RenderBox;
      TableLayoutParentDataExp parentData = child._parentData();
      if (parentData.type == LayoutChildType.cell) {
        _contentAreaMap[parentData.contentAreaId]!.children.add(renderBox);
      } else if (parentData.type == LayoutChildType.horizontalScrollbar) {
        if (parentData.contentAreaId == ContentAreaId.unpinned) {
          _contentAreaMap[parentData.contentAreaId]!.scrollbar = renderBox;
        }
      } else if (parentData.type == LayoutChildType.verticalScrollbar) {
        verticalScrollbar = renderBox;
      }
      children.add(renderBox);
    });

    double height = 0;
    if (constraints.hasBoundedHeight) {
      height = constraints.maxHeight;
    } else {
      // unbounded height
      height = _layoutSettings.headerHeight +
          _layoutSettings.contentHeight +
          _layoutSettings.scrollbarHeight;
    }

    // vertical scrollbar
    //TODO scrollbarSize border?
    verticalScrollbar!.layout(
        BoxConstraints.tightFor(
            width: _layoutSettings.scrollbarWidth,
            height: math.max(
                0,
                height -
                    _layoutSettings.headerHeight -
                    _layoutSettings.scrollbarHeight)),
        parentUsesSize: true);
    verticalScrollbar!._parentData().offset = Offset(
        constraints.maxWidth - _layoutSettings.scrollbarWidth,
        _layoutSettings.headerHeight);

    _leftPinnedContentArea.bounds = Rect.fromLTWH(
        0, 0, _leftPinnedContentArea.columnsMetrics.maxWidth, height);
    _unpinnedContentArea.bounds = Rect.fromLTWH(
        _leftPinnedContentArea.bounds.right,
        0,
        _unpinnedContentArea.columnsMetrics.maxWidth,
        height);
    _rightPinnedContentArea.bounds = Rect.fromLTWH(
        _unpinnedContentArea.bounds.right,
        0,
        _rightPinnedContentArea.columnsMetrics.maxWidth,
        height);

    size = Size(constraints.maxWidth, height);

    _forEachContentArea(
        (area) => area.performLayout(layoutSettings: _layoutSettings));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height = 0;
    if (_layoutSettings.hasHeader) {
      height += _layoutSettings.headerHeight;
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double height = computeMinIntrinsicHeight(width);
    if (_layoutSettings.visibleRowsCount != null) {
      height += _layoutSettings.visibleRowsCount! * _layoutSettings.cellHeight;
    }
    return height;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
    if (_paintSettings.debugAreas) {
      if (_layoutSettings.hasHeader) {
        _forEachContentArea((area) => area.paintDebugAreas(
            canvas: context.canvas,
            offset: offset,
            layoutSettings: _layoutSettings));
      }
    }
  }

  void _forEachContentArea(_ContentAreaFunction function) {
    function(_leftPinnedContentArea);
    function(_unpinnedContentArea);
    function(_rightPinnedContentArea);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

typedef _ContentAreaFunction = void Function(ContentArea area);

/// Utility extension to facilitate obtaining parent data.
extension _TableLayoutParentDataGetter on RenderObject {
  TableLayoutParentDataExp _parentData() {
    return parentData as TableLayoutParentDataExp;
  }
}
