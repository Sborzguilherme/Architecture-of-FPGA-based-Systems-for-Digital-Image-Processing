# --------------------------------------------- Plot ----------------------------------------------------------------- #
# Author: Guilherme Sborz
# Date: 31/07/2019
# Script to plot figures and compare error metrics between implementations
# -------------------------------------------------------------------------------------------------------------------- #
import matplotlib.pyplot as plt
import Library_txt_files as Lib_txt
import Library_operations as Lib_op
import numpy as np
# -------------------------------------------------------------------------------------------------------------------- #
virtual_board_approach = 2
kernel = (3,3)
img_tested = "lena"
input_directory = "../../Data/Input_Data/TXT/"
output_directory = "../../Data/Output_Data/VB_" + str(virtual_board_approach)+"/"
img_name = "lena"

img_heigth = img_width = 512

normalized_img_width  = img_heigth - (kernel[0]-1//2)
normalized_img_heigth = img_width -  (kernel[1]-1//2)

hw_result = Lib_txt.open_txt_values(output_directory+img_name+"hw_"+str(virtual_board_approach), img_heigth, img_width)
img = Lib_txt.open_txt_values(input_directory+img_name+str(virtual_board_approach), normalized_img_heigth, normalized_img_width)
sw_result = Lib_op.fixed_point_convolution_2D(img, kernel, virtual_board_approach)

plt.subplot(121)
plt.imshow(sw_result, cmap='gray')
plt.subplot(122)
plt.imshow(hw_result, cmap='gray')
plt.show()

plt.figure("Difference")
plt.imshow(np.diff(sw_result, hw_result))
plt.show()



