#include <iostream>

#define N 9
using namespace std;

namespace solver
{
    // check if a num is valid in (row, col) of the grid
    bool isValid(int row, int col, int num, int grid[N][N])
    {
        for (int row = 0; row < N; row++)
            if (grid[row][col] == num)
                return false; // present in row

        for (int row = 0; row < N; row++)
            if (grid[row][col] == num)
                return false; // present in col

        int boxStartRow = row - row % 3;
        int boxStartCol = col - col % 3;

        for (int row = 0; row < 3; row++)
            for (int col = 0; col < 3; col++)
                if (grid[row + boxStartRow][col + boxStartCol] == num)
                    return false; // present in 3x3 box

        return true;
    }

    // get empty location and update row and column
    bool findEmptyPlace(int &row, int &col, int grid[N][N])
    {
        for (row = 0; row < N; row++)
            for (col = 0; col < N; col++)
                if (grid[row][col] == 0) // marked with 0 is empty
                    return true;
        return false;
    }

    bool solveSudoku(int grid[N][N])
    {
        int row, col;
        if (!findEmptyPlace(row, col, grid))
            return true; // when all places are filled

        for (int num = 1; num <= 9; num++)
        {
            if (isValid(row, col, num, grid))
            {
                grid[row][col] = num;
                if (solveSudoku(grid))
                    return true;

                // turn to unassigned space when conditions are not satisfied
                grid[row][col] = 0;
            }
        }
        return false;
    }

    // print the sudoku grid after solve
    void printGrid(int grid[N][N])
    {
        for (int row = 0; row < N; row++)
        {
            for (int col = 0; col < N; col++)
            {
                if (col == 3 || col == 6)
                    cout << " | ";
                cout << grid[row][col] << " ";
            }
            if (row == 2 || row == 5)
            {
                cout << endl;
                for (int i = 0; i < N; i++)
                    cout << "---";
            }
            cout << endl;
        }
    }

}

int test()
{
    int grid[9][9] = {
        {3, 0, 6, 5, 0, 8, 4, 0, 0},
        {5, 2, 0, 0, 0, 0, 0, 0, 0},
        {0, 8, 7, 0, 0, 0, 0, 3, 1},
        {0, 0, 3, 0, 1, 0, 0, 8, 0},
        {9, 0, 0, 8, 6, 3, 0, 0, 5},
        {0, 5, 0, 0, 9, 0, 6, 0, 0},
        {1, 3, 0, 0, 0, 0, 2, 5, 0},
        {0, 0, 0, 0, 0, 0, 0, 7, 4},
        {0, 0, 5, 2, 0, 6, 3, 0, 0}};

    if (solver::solveSudoku(grid) == true)
        solver::printGrid(grid);
    else
        cout << "No solution exists";
    return 0;
}