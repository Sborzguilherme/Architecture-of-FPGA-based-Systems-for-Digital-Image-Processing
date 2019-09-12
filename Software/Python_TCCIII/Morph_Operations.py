import numpy as np
import math
import matplotlib.pyplot as plt


def Erode(img, kernel_heigth, kernel_width):
    img_heigth = len(img)
    img_width = len(img[0])

    out_img_heigth = img_heigth - (kernel_heigth - 1)
    out_img_width = img_width - (kernel_width - 1)

    out_img = np.ndarray([out_img_heigth, out_img_width], dtype=np.uint8)  # Create matrix for output image

    for i in range(out_img_heigth):  # Run through lines
        for j in range(out_img_width):  # Run through collumns
            aux = 255
            for k in range(kernel_heigth):
                for l in range(kernel_width):
                    if (img[i + k][j + l] < aux):
                        aux = img[i + k][j + l]
            out_img[i][j] = aux
    out_img = np.uint8(out_img)
    return out_img


def Dilation(img, kernel_heigth, kernel_width):
    img_heigth = len(img)
    img_width = len(img[0])

    out_img_heigth = img_heigth - (kernel_heigth - 1)
    out_img_width = img_width - (kernel_width - 1)

    out_img = np.ndarray([out_img_heigth, out_img_width], dtype=np.uint8)  # Create matrix for output image

    for i in range(out_img_heigth):  # Run through lines
        for j in range(out_img_width):  # Run through collumns
            aux = 0
            for k in range(kernel_heigth):
                for l in range(kernel_width):
                    if (img[i + k][j + l] > aux):
                        aux = img[i + k][j + l]
            out_img[i][j] = aux

    out_img = np.uint8(out_img)
    return out_img


def Morphological_Opening(img, kernel_heigth, kernel_width):
    eroded_img = Erode(img, kernel_heigth, kernel_width)
    out_img = Dilation(eroded_img, kernel_heigth, kernel_width)

    out_img = np.uint8(out_img)

    return out_img


def Morphological_Closing(img, kernel_heigth, kernel_width):
    dilated_img = Dilation(img, kernel_heigth, kernel_width)
    out_img = Erode(dilated_img, kernel_heigth, kernel_width)

    out_img = np.uint8(out_img)

    return out_img


# Measuring difference between images
def psnr(img1, img2):
    mse = np.mean((img1 - img2) ** 2)
    if mse == 0:
        return 100
    PIXEL_MAX = 255.0
    return 20 * math.log10(PIXEL_MAX / math.sqrt(mse))


def template_matching(img, template):
    # Image dimensions
    img_heigth = len(img)
    img_width = len(img[0])

    # Template dimensions
    template_heigth = len(template)
    template_width = len(template[0])

    # Loop ranges
    max_width = img_width - (template_width - 1)
    max_heigth = img_heigth - (template_heigth - 1)

    max_pos_i = 0
    max_pos_j = 0
    most_sim = 0

    for i in range(max_heigth):
        for j in range(max_width):
            aux_img = img[i:(i + template_heigth), j:j + template_width]
            if(np.count_nonzero(aux_img==template) > most_sim):
                max_pos_i = i
                max_pos_j = j
                most_sim = np.count_nonzero(aux_img==template)

    return max_pos_i, max_pos_j, most_sim
