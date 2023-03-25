import 'package:flutter/material.dart';

import '../providers/board_provider_models.dart';

Color getWhichBoardBoxColorToDisplay(int boxIdx, bool isDarkMode) {
  if (isDarkMode) {
    if (boxIdx % 2 == 0) {
      return Colors.grey.shade800;
    } else {
      return Colors.grey.shade700;
    }
  } else {
    if (boxIdx % 2 == 0) {
      return Colors.grey.shade100;
    } else {
      return Colors.blueGrey.shade50;
    }
  }
}

String getWhichDigitToDisplay(BoardCell currentWidget, int count) {
  if (currentWidget.digit == 0) {
    return '';
  } else {
    return currentWidget.digit.toString();
  }
}

double getWhichCellBorderWidthToDisplay(
  bool isBoardCompletelySolvedbyUser,
  int count,
  Function getCurrentPressedCount,
  bool? isDigitValid,
) {
  // if the board is completley solved then make the border of all cell's width to normal
  if (isBoardCompletelySolvedbyUser) {
    return 1.0;
  }

  if (count == getCurrentPressedCount() || isDigitValid == false) {
    return 3.0;
  } else {
    return 1.0;
  }
}

Color getWhichCellBorderColorToDisplay(
  bool isBoardCompletelySolvedbyUser,
  BoardCell currentWidget,
  int count,
  Function getCurrentPressedCount,
  bool isDarkMode,
) {
  // if the board is completley solved then make the border of all cell's color to normal
  if (isBoardCompletelySolvedbyUser) {
    if (isDarkMode) {
      return Colors.grey.shade600;
    } else {
      return Colors.blueGrey.shade200;
    }
  }
  if (count == getCurrentPressedCount()) {
    if (currentWidget.isDigitValid == false) {
      return Colors.red.shade200;
    } else {
      if (isDarkMode) {
        return Colors.blueGrey.shade400;
      } else {
        return Colors.indigo.shade200;
      }
    }
  } else if (currentWidget.isDigitValid == false) {
    return Colors.red.shade200;
  } else {
    if (isDarkMode) {
      return Colors.grey.shade600;
    } else {
      return Colors.blueGrey.shade200;
    }
  }
}

Color getWhichTextColorToDisplay(BoardCell currentWidget, bool isDarkMode) {
  if (isDarkMode) {
    if (currentWidget.isDetection) {
      return Colors.blue.shade600;
    }
    if (currentWidget.isSolution && !currentWidget.isMarked) {
      return Colors.green.shade700;
    }
    if (currentWidget.isMarked) {
      return Colors.teal.shade400;
    } else {
      return Colors.grey.shade400;
    }
  } else {
    if(currentWidget.isDetection && !currentWidget.isSolution && !currentWidget.isMarked) {
      return Colors.blue.shade600;
    }
    if (currentWidget.isSolution) {
      return Colors.lightGreen;
    }
    if (currentWidget.isMarked) {
      return Colors.teal;
    } else {
      return Colors.black;
    }
  }
}
