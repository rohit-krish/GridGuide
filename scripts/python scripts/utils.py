import cv2
import numpy as np


def preprocess(img):
    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img_g_blur = cv2.GaussianBlur(img_gray, (3, 3), 1)
    img_threshold = cv2.adaptiveThreshold(
        img_g_blur, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 1, 11, 2
    )
    return img_threshold


def prediction(boxes, model):
    result = []

    for box in boxes:
        img = np.asarray(box)
        img = img[10:img.shape[0]-10, 10:img.shape[1]-10]
        img = cv2.resize(img, (70, 70))
        # img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
        # img = img / 255
        img = img.reshape(1, 70, 70, 3)

        preds = model.predict(img)

        class_idx = np.argmax(preds, axis=-1)[0]
        score = np.amax(preds)
        if score > 0.7:
            result.append(class_idx)
        else:
            result.append(0)

    return result


def display_numbers(img, numbers):
    h, w = int(img.shape[0]/9), int(img.shape[1]/9)
    for x in range(9):
        for y in range(9):
            # print(numbers[(y*9)+x])
            if numbers[(y*9)+x] != 0:
                cv2.putText(
                    img, str(numbers[(y*9)+x]), (x*w+int(w/2)-10, int((y+.8)*h)),
                    cv2.FONT_HERSHEY_SIMPLEX, 3, (0, 255, 0), 2
                )
    return img


def find_biggest_contour(contours):
    max_area = 0
    biggest = []

    for cnt in contours:
        area = cv2.contourArea(cnt)

        if area > 50:
            peri = cv2.arcLength(cnt, True)
            approx = cv2.approxPolyDP(cnt, 0.02*peri, True)

            if area > max_area and len(approx) == 4:
                biggest = approx
                max_area = area

    return biggest, max_area


def reorder(points):
    # points = points.reshape((4,2))
    points = np.reshape(points, (4, 2))
    result = np.zeros((4, 1, 2), dtype=np.int32)

    sum_points = np.sum(points, axis=1)
    diff_points = np.diff(points, axis=1)


    result[0] = points[np.argmin(sum_points)]
    result[3] = points[np.argmax(sum_points)]
    result[1] = points[np.argmin(diff_points)]
    result[2] = points[np.argmax(diff_points)]

    return result


def split_boxes(img):
    # img = img[1:img.shape[1]-1, 1:img.shape[0]-1]
    # print(img.shape)
    img = cv2.resize(img, (810, 810))
    rows = np.vsplit(img, 9)
    boxes = []

    for r in rows:
        print(r.shape)
        cols = np.hsplit(r, 9)
        for box in cols:
            boxes.append(box)

    return np.array(boxes)
