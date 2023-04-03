int getCorrespondingIndex(int index) {
  int row = (index / 9).floor();
  int col = index % 9;
  int boxRow = (row / 3).floor();
  int boxCol = (col / 3).floor();
  int boxIndex = boxRow * 3 + boxCol;
  int cellIndex = (row % 3) * 3 + (col % 3);
  int correspondingIndex = boxIndex * 9 + cellIndex;

  return correspondingIndex;
}