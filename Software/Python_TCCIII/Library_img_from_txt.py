import numpy as np
import cv2

# FUNCTIONS TO OPEN IMAGES FROM TXT
def open_img_from_txt_gray(filename, img_height, img_width):

    img_txt = []

    with open(filename, 'r') as f:
        data = f.readlines()
        for line in data:
            a = line
            img_txt.append(a[:-1])

    img_aux = np.ndarray(len(img_txt))

    for i in range(len(img_txt)):
        img_aux[i] = (int(img_txt[i], 2))

    img_aux = img_aux.reshape([img_height, img_width])

    img = np.ndarray([img_height, img_width])
    for i in range(img_height):
        for j in range(img_width):
            a = np.bitwise_and(int(img_aux[i][j]), 255)
            img[i][j] = a

    img = np.uint8(img)

    return img

# ------------------------------------------------------------------------------------------------------------ #
def open_img_from_txt_RBG(filename, img_height, img_width):
    img_txt = []

    with open(filename, 'r') as f:
        data = f.readlines()
        for line in data:
            a = line
            img_txt.append(a[:-1])

    img_aux = np.ndarray(len(img_txt))

    for i in range(len(img_txt)):
        img_aux[i] = (int(img_txt[i], 2))

    img_aux = img_aux.reshape([img_height, img_width])
    img = np.ndarray([img_height, img_width, 3])

    for i in range(img_height):
        for j in range(img_width):
            a = np.bitwise_and(int(img_aux[i][j]), 255)
            b = np.bitwise_and(int(img_aux[i][j]), 652820)
            c = np.bitwise_and(int(img_aux[i][j]), 16711680)
            img[i][j][0] = a
            img[i][j][1] = (b/2**8)
            img[i][j][2] = (c/2**16)

    img = np.uint8(img)
    return img

# ------------------------------------------------------------------------------------------------------------ #
def binary_img_to_txt(img, filename):
    img_heigth = len(img)
    img_width = len(img[0])

    size = img_heigth * img_width

    img = img.reshape(size)
    with open(filename, 'w') as f:
        for i in range(size):
            if(int(img[i]) == 255):
                a = '1'
            else:
                a = '0'
            f.write(a + '\n')
        f.close()

def open_img_from_txt_binary(filename, img_height, img_width):
    img_txt = []

    with open(filename, 'r') as f:
        data = f.readlines()
        for line in data:
            a = line
            img_txt.append(a[:-1])

    img_aux = np.ndarray(len(img_txt))

    for i in range(len(img_txt)):
        #print(i, " - ", img_txt[i])
        img_aux[i] = (int(img_txt[i], 2) * 255)

    img_aux = img_aux.reshape([img_height, img_width])

    img = np.ndarray([img_height, img_width])
    for i in range(img_height):
        for j in range(img_width):
            #a = (int(img_aux[i][j]), 2)
            img[i][j] = img_aux[i][j]
    return np.uint8(img)

def generate_dat_file(filename, data):
    file = open(filename + ".dat", 'w')
    for i in range(0, len(data)):
        if (i == len(data) - 1):
            file.write(str(int(data[i])))
        else:
            file.write(str(int(data[i])) + ",\n")

    file.close()


def read_txt_RGB_int_24bits(filename):
    img_txt = []

    with open(filename, 'r') as f:
        data = f.readlines()
        for line in data:
            a = line
            img_txt.append(a[:-1])

    img_aux = np.ndarray(len(img_txt))

    for i in range(len(img_txt)):
        img_aux[i] = np.uint32(((int(img_txt[i], 2))))

    return img_aux

