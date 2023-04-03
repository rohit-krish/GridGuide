bool isValid(List<List<int>> board, int row, int col, int num) {
  if (num == 0) {
    return true;
  }
  for (int c = 0; c < 9; c++) {
    if ((board[row][c] == num) && (c != col)) {
      return false;
    }
  }
  for (int r = 0; r < 9; r++) {
    if ((board[r][col] == num) && (r != row)) {
      return false;
    }
  }
  int boxRow = row - row % 3;
  int boxCol = col - col % 3;
  for (int r = boxRow; r < boxRow + 3; r++) {
    for (int c = boxCol; c < boxCol + 3; c++) {
      if ((board[r][c] == num) && (r != row) && (c != col)) {
        return false;
      }
    }
  }
  return true;
}

List<List<int>> to2D(List<int> board) {
  List<List<int>> res = List.filled(9, List.filled(9, 0));
  for (int i = 0; i < 9; i++) {
    res[i] = board.sublist(i * 9, (i * 9) + 9);
  }
  return res;
}

List<int> checkUnvalidPlaces(List<int> board) {
  var board2d = to2D(board);
  var unvalidPlaces = List.filled(81, 0);
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (isValid(board2d, i, j, board2d[i][j]) == false) {
        unvalidPlaces[(i * 9) + j] = 1;
      }
    }
  }
  return unvalidPlaces;
}
