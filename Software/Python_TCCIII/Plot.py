# --------------------------------------------- Plot ----------------------------------------------------------------- #
# Author: Guilherme Sborz
# Date: 31/07/2019
# Script to plot figures and compare error metrics between implementations
# -------------------------------------------------------------------------------------------------------------------- #
import matplotlib.pyplot as plt
import Library_txt_files as Lib_txt
import Library_operations as Lib_op
import numpy as np
import skimage.measure as sk
# -------------------------------------------------------------------------------------------------------------------- #
virtual_board_approach = 2
kernel = (3,3)
img_tested = "lena"
input_directory = "../../Data/Input_Data/TXT/VB_3/"
output_directory = "../../Data/Output_Data/VB_" + str(virtual_board_approach)+"/"
img_name = "lena"

img_heigth = img_width = 512

hw_result = Lib_txt.open_txt_values(output_directory+img_name+"_"+str(kernel[0])+".txt", img_heigth, img_width)
img = Lib_txt.open_txt_values(input_directory+img_name+".txt", img_heigth, img_width)


kernel_gaussian = Lib_op.gaussian_kernel_gen(kernel[0], 1)
sw_result = Lib_op.fixed_point_convolution_2D(img, kernel_gaussian, virtual_board_approach)

plt.subplot(121)
plt.imshow(sw_result, cmap='gray')
plt.subplot(122)
plt.imshow(hw_result, cmap='gray')
plt.show()

diff = np.absolute(np.subtract(sw_result, hw_result))

print("RMSE = ", sk.compare_nrmse(sw_result, hw_result))
print("PSNR = ", sk.compare_psnr(sw_result, hw_result, 2**8))

plt.figure("Difference")
plt.imshow(diff)
plt.show()



