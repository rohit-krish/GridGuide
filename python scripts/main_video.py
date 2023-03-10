from tensorflow import keras

# from tensorflow.keras.models import load_model

import cv2
from mylib.show import stackIt
from utils import *
import numpy as np
from solver import solve

img = cv2.imread('./assets/20_board.jpg')
img = cv2.resize(img, (810, 810))
img_blank = np.zeros_like(img)
model = keras.models.load_model('./model')

cap = cv2.VideoCapture(0)

while True:
    _, img = cap.read()

    img_h, img_w, _ = img.shape
    img_preprocessed = preprocess(img)
    img_contours = img.copy()
    img_biggest_contour = img.copy()

    # find all contours
    contours, _ = cv2.findContours(
        img_preprocessed, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE
    )

    # find the biggest contour
    biggest_contour, area = find_biggest_contour(contours)
    if area == 0:
        continue
    biggest_contour = reorder(biggest_contour)

    # warp perspective
    pts1 = np.float32(biggest_contour)
    pts2 = np.float32(
        [[0, 0], [img_w, 0], [0, img_h], [img_w, img_h]]
    )
    matrix = cv2.getPerspectiveTransform(pts1, pts2)
    img_warp = cv2.warpPerspective(
        img, matrix, (img_w, img_h)
    )
    img_warp = cv2.cvtColor(img_warp, cv2.COLOR_BGR2GRAY)

    cv2.drawContours(img_contours, contours, -1, (0, 0, 255), 5)
    cv2.drawContours(img_biggest_contour, biggest_contour, -1, (0, 0, 255), 20)

    images = [
        [img, img_preprocessed, img_contours,],
        [img_biggest_contour, img_warp, img_blank],
        [img_blank, img_blank, img_blank]
    ]
    labels = [
        ['img', 'thresholded', 'all contours'],
        ['biggest contour', 'warp', 'detected digits',],
        ['solved board', 'inv warp', 'inv perspective']
    ]

    cv2.imshow(
        'img', stackIt(
            images, labels, fontFace=cv2.FONT_HERSHEY_SIMPLEX,
            fontScale=.8, color=(0, 255, 0), thickness=1, img_scale=.4
        )
    )

    key = cv2.waitKey(0)
    if key == ord('q'):
        break
    elif key == ord(' '):
        pass
    else:
        continue

    # splitting the boxes
    boxes = split_boxes(img_warp)
    # predicting the numbers
    numbers = prediction(boxes, model)

    detected_digits = display_numbers(img_blank.copy(), numbers)
    numbers = np.asarray(numbers)

    pos_array = np.where(numbers > 0, 0, 1)

    # find solution
    board = np.array_split(numbers, 9)
    solve(board)

    pos_array = np.array(np.array_split(pos_array, 9))
    solved_numbers = board * pos_array

    solved_numbers = np.ravel(solved_numbers)

    img_solved_numbers = display_numbers(img_blank.copy(), solved_numbers)

    # over the solution onto the image
    pts2 = np.float32(biggest_contour)
    pts1 = np.float32(
        [[0, 0], [img_w, 0], [0, img_h], [img_w, img_h]]
    )

    matrix = cv2.getPerspectiveTransform(pts1, pts2)
    img_inv_warp = img.copy()
    img_inv_warp = cv2.warpPerspective(
        img_solved_numbers, matrix, (img_w, img_h))
    inv_perspective = cv2.addWeighted(img_inv_warp, 1, img, 0.5, 1)

    images = [
        [img, img_preprocessed, img_contours,],
        [img_biggest_contour, img_warp, detected_digits],
        [img_solved_numbers, img_inv_warp, inv_perspective]
    ]
    labels = [
        ['img', 'thresholded', 'all contours'],
        ['biggest contour', 'warp', 'detected digits',],
        ['solved board', 'inv warp', 'inv perspective']
    ]

    cv2.imshow(
        'img', stackIt(
            images, labels, fontFace=cv2.FONT_HERSHEY_SIMPLEX,
            fontScale=.8, color=(0, 255, 0), thickness=1, img_scale=.4
        )
    )
    if cv2.waitKey(0) == ord('q'):
        break

    # print(boxes[0][...,None].shape)
    # cv2.imshow("box", boxes[3][..., None])
