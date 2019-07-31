# --------------------------------------------- Generate Data VHDL --------------------------------------------------- #
# Author: Guilherme Sborz
# Date: 30/07/2019
# Script to generate txt within the images in the fixed-point format
# -------------------------------------------------------------------------------------------------------------------- #
import Library_txt_files as Lib_txt
import Library_fixed_point as Lib_fx
import Library_operations as Lib_op
import cv2
import matplotlib.pyplot as plt
import numpy as np
# -------------------------------------------------------------------------------------------------------------------- #
kernel = (7,7)
virtual_board_approach = 2

# Open original img
input_directory = "../../Data/Input_Data/JPG_PNG/"
output_directory = "../../Data/Input_Data/TXT/VB_"+str(virtual_board_approach)+"/"
img_name = "lena"
color_lena = cv2.imread(input_directory + "color_"+img_name+".jpg", cv2.IMREAD_COLOR)
gray_lena = cv2.cvtColor(color_lena, cv2.COLOR_BGR2GRAY)

# Treat Virtual Board
treated_img = Lib_op.treat_virtual_board(gray_lena, kernel[0], kernel[1], virtual_board_approach)

x, y = np.shape(treated_img)

# # Write in a file
Lib_txt.generate_txt_fixed_point_img(treated_img, output_directory+img_name+"_"+str(kernel[0])+".txt")

# Verify if image was write correctly
txt_img = Lib_txt.open_txt_values(output_directory+img_name+"_"+str(kernel[0])+".txt", x, y)

# plt.imshow(txt_img, cmap='gray')
# plt.show()



