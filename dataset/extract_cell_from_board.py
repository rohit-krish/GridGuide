# %%
import cv2
from utils import preprocess, find_biggest_contour, reorder, split_boxes
import numpy as np
import os
import shutil
from mylib.show import stackIt

base_path = './dataset/board/'

def doit():
    for count, img_name in enumerate(os.listdir(base_path)):
        img = cv2.imread(base_path+img_name)
        key = cv2.waitKey(0)
        if key == ord('q'):
            break
        elif key == ord('m'):
            shutil.move(base_path+img_name, './dataset/tmp/'+img_name)

        img = cv2.resize(img, (810, 810))
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
        # if area == 0: continue
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

        # splitting the boxes
        boxes = split_boxes(img_warp)

        cv2.imshow('img_warp', stackIt(
            [[img_warp]], [[img_name]],
            fontFace=cv2.FONT_HERSHEY_SIMPLEX, fontScale=.8,
            color=(0, 255, 0), thickness=2
        ))

        base_box = './dataset/cells/generated'
        pad = 10
        token = img_name.split('.')[0].strip()
        for cnt, box in enumerate(boxes):
            box = box[pad:box.shape[1]-pad, pad:box.shape[0]-pad]
            box = cv2.resize(box, (70, 70)).astype(np.uint8)

            cv2.imshow('box', box)
            key = cv2.waitKey(0)
            if chr(key).isnumeric():
                dst = f'{base_box}/{chr(key)}/{token}_{count}_{cnt}.{chr(key)}.jpg'
                cv2.imwrite(dst, box)
                print(dst)
            elif chr(key) == 'q':
                cv2.destroyAllWindows()
                return

    cv2.destroyAllWindows()

#%%
doit()
