import albumentations as A
import cv2
import os


which = 9
count = 0

transform = A.Compose([
    A.Blur(blur_limit=6, p=.2),
    A.Defocus(radius=(2, 2), p=.2),
    A.GlassBlur(sigma=.2, max_delta=1, iterations=1, p=.2),
    A.ZoomBlur(p=.5),
])

for img_path in os.listdir(f'./{which}'):
    img = cv2.cvtColor(cv2.imread(f'./{which}/'+img_path), cv2.COLOR_BGR2RGB)
    transformed = transform(image=img)['image']
    # cv2.imwrite(f'./{which}/{count}.jpg', transformed)
    cv2.imshow('transformed', transform(image=img)['image'])
    if cv2.waitKey(0) == ord('q'):
        break
    count+=1
