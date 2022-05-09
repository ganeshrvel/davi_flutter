import 'package:easy_table/src/theme/cell_theme_data.dart';
import 'package:easy_table/src/theme/header_cell_theme_data.dart';
import 'package:easy_table/src/theme/header_theme_data.dart';
import 'package:easy_table/src/theme/row_theme_data.dart';
import 'package:easy_table/src/theme/scroll_theme_data.dart';
import 'package:flutter/material.dart';

//TODO handle negative values
/// The [EasyTable] theme.
/// Defines the configuration of the overall visual [EasyTableThemeData] for a widget subtree within the app.
class EasyTableThemeData {
  /// Builds a theme data.
  const EasyTableThemeData(
      {this.columnDividerThickness =
          EasyTableThemeDataDefaults.columnDividerThickness,
      this.rowDividerThickness = EasyTableThemeDataDefaults.rowDividerThickness,
      this.decoration = EasyTableThemeDataDefaults.tableDecoration,
      this.topRightCornerDecoration =
          EasyTableThemeDataDefaults.topRightCornerDecoration,
      this.bottomRightCornerDecoration =
          EasyTableThemeDataDefaults.bottomRightCornerDecoration,
      this.row = const RowThemeData(),
      this.cell = const CellThemeData(),
      this.header = const HeaderThemeData(),
      this.headerCell = const HeaderCellThemeData(),
      this.scroll = const TableScrollThemeData()});

  final double columnDividerThickness;
  final double rowDividerThickness;
  final BoxDecoration? decoration;
  final CellThemeData cell;
  final HeaderThemeData header;
  final HeaderCellThemeData headerCell;
  final RowThemeData row;
  final TableScrollThemeData scroll;
  final BoxDecoration topRightCornerDecoration;
  final BoxDecoration bottomRightCornerDecoration;
}

class EasyTableThemeDataDefaults {
  static const double columnDividerThickness = 1;
  static const double rowDividerThickness = 0;
  static const BoxDecoration tableDecoration = BoxDecoration(
      border: Border(
          bottom: BorderSide(color: Colors.grey),
          top: BorderSide(color: Colors.grey),
          left: BorderSide(color: Colors.grey),
          right: BorderSide(color: Colors.grey)));
  static const BoxDecoration topRightCornerDecoration = BoxDecoration(
      color: Color(0xFFE0E0E0),
      border: Border(
          left: BorderSide(color: Colors.grey),
          bottom: BorderSide(color: Colors.grey)));
  static const BoxDecoration bottomRightCornerDecoration = BoxDecoration(
      color: Color(0xFFE0E0E0),
      border: Border(
          left: BorderSide(color: Colors.grey),
          top: BorderSide(color: Colors.grey)));
}
