'''
board = [
    [0,4,0,6,0,0,2,0,3],
    [0,0,0,0,0,0,0,6,0],
    [8,0,0,0,2,0,0,1,0],
    [0,0,0,0,6,0,0,0,0],
    [0,6,3,0,7,0,5,9,8],
    [1,0,0,0,3,0,0,2,7],
    [0,0,5,2,0,0,8,0,0],
    [0,0,1,5,9,4,0,0,0],
    [0,2,0,3,8,0,0,0,0]
]
'''


def solve(bo):
    find = find_empty(bo)
    if find:
        row, col = find
    else:
        return True

    for i in range(1, 10):
        if valid(bo, i, (row, col)):
            bo[row][col] = i

            if solve(bo):
                return True

            bo[row][col] = 0

    return False


def valid(bo, num, pos):
    # Check row
    for i in range(len(bo[0])):
        if bo[pos[0]][i] == num and pos[1] != i:
            return False

    # Check column
    for i in range(len(bo)):
        if bo[i][pos[1]] == num and pos[0] != i:
            return False

    # Check inner-box
    box_x = pos[0] // 3
    box_y = pos[1] // 3

    for i in range(box_x * 3, box_x * 3 + 3):
        for j in range(box_y * 3, box_y * 3 + 3):
            if bo[i][j] == num and (i, j) != pos:
                return False

    return True


def print_board(bo):
    for i in range(len(bo)):
        for j in range(len(bo[0])):
            print(bo[i][j], end=' ')
        print()


def find_empty(bo):
    for i in range(len(bo)):
        for j in range(len(bo[0])):
            if bo[i][j] == 0:
                return (i, j)  # row,column
    return None


'''
if __name__ == '__main__':
    solve(board)
    print_board(board)
'''
