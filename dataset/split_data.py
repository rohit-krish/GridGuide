from random import shuffle
import os
from shutil import copy

train_pct = .92
test_pct = .06
# val_pct   = .02


def copy_data(src, dst, data):
    for img in data:
        copy(f'{src}/{img}', f'{dst}/{img}')


for i in range(10):
    cls_data = os.listdir(f'./data_v2/{i}')
    shuffle(cls_data)
    train_len = int(len(cls_data) * train_pct)
    test_len = int(len(cls_data) * test_pct)
    # val_len = len(cls_data) - (train_len + test_len)

    train_data = cls_data[:train_len]
    copy_data(f'./data_v2/{i}', f'./train_data/{i}', train_data)

    test_data = cls_data[train_len:train_len+test_len]
    copy_data(f'./data_v2/{i}', f'./test_data/{i}', test_data)

    val_data = cls_data[train_len + test_len:]
    copy_data(f'./data_v2/{i}', f'./validation_data/{i}', val_data)

    print(i)
