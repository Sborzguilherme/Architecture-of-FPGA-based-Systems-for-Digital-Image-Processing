# --------------------------------------------- Plot ----------------------------------------------------------------- #
# Author: Guilherme Sborz
# Date: 30/07/2019
# Script to plot figures and compare error metrics between implementations
# -------------------------------------------------------------------------------------------------------------------- #
import numpy as np
import cv2
import skimage.measure as sk
import matplotlib.pyplot as plt
import Library_txt_files as lib_txt
import Library_operations as lib_op
# ---------------------------------------------- Input parameters ---------------------------------------------------- #
input_directory = "../../Data/Input_Data/JPG_PNG/"
kernel_size = 3
sigma = 1
virtual_board_mode = 0
# -------------------------------------------------------------------------------------------------------------------- #
color_lena = cv2.imread(input_directory + "color_lena.jpg", cv2.IMREAD_COLOR)
gray_lena = cv2.cvtColor(color_lena, cv2.COLOR_BGR2GRAY)
#gaussian_result_opencv = cv2.GaussianBlur(gray_lena, (kernel_size,kernel_size), sigma)

gaussian_kernel = lib_op.gaussian_kernel_gen(kernel_size, sigma)
gaussian_result_lib = lib_op.floating_point_convolution_2D(gray_lena, gaussian_kernel, virtual_board_mode)
fixed_gaussian = lib_op.fixed_point_convolution_2D(gray_lena, gaussian_kernel, virtual_board_mode)

print(sk.compare_nrmse(gaussian_result_lib, fixed_gaussian))
print(sk.compare_psnr(gaussian_result_lib, fixed_gaussian))

plt.subplot(121)
plt.imshow(gaussian_result_lib, cmap='gray')
plt.subplot(122)
plt.imshow(fixed_gaussian, cmap='gray')
plt.show()


