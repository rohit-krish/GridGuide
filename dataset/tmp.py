# import matplotlib.pyplot as plt
# import os

# counts = [len(os.listdir('./cells/'+str(i))) for i in range(10)]
# plt.figure(figsize=(8, 6))

# plt.bar([*range(10)], counts)
# plt.title('Data Distribution')
# plt.xlabel('classes')
# plt.ylabel('count')
# plt.show()

import cv2
import os

base_dir = './train_data/'

for dir in os.listdir(base_dir):
    for img_name in os.listdir(base_dir+dir):
        img = cv2.imread(f"{base_dir}{dir}/{img_name}")
        print(img.shape)
    break
        # img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        # print(img.shape, end='\t')

        # try:
        #     cv2.imwrite(f'{base_dir}{dir}/{img_name}', img)
        # except:
        #     print(f'{base_dir}{dir}/{img_name}')
