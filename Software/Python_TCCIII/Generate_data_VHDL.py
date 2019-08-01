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
def Generate_img_VHDL(img_name, kernel, virtual_board_approach, bits):

    # Open original img
    input_directory = "../../Data/Input_Data/JPG_PNG/"
    output_directory = "../../Data/Input_Data/TXT/VB_"+str(virtual_board_approach)+"/" + str(bits) + "_bits/"
    color_lena = cv2.imread(input_directory + "color_"+img_name+".jpg", cv2.IMREAD_COLOR)
    gray_lena = cv2.cvtColor(color_lena, cv2.COLOR_BGR2GRAY)

    # Treat Virtual Board
    treated_img = Lib_op.treat_virtual_board(gray_lena, kernel[0], kernel[1], virtual_board_approach)

    x, y = np.shape(treated_img)

    # Write in a file
    Lib_txt.generate_txt_fixed_point_img(treated_img, output_directory+img_name+"_"+str(kernel[0])+".txt")

    # Verify if image was write correctly
    txt_img = Lib_txt.open_txt_values(output_directory+img_name+"_"+str(kernel[0])+".txt", x, y)

def Generate_string_constant(size, sigma):
    kernel = Lib_op.gaussian_kernel_gen(size, sigma)
    cont = 0
    cont_l = 0
    string = ""
    for i in range(len(kernel)):
        for j in range(len(kernel[0])):
            a = Lib_fx.float_to_fixed(kernel[i][j], hex_format=False) # 14 bits constant
            print(a)
            #a = Lib_fx.float_to_fixed(kernel[i][j])
            if(cont_l < size):
                #string += str(cont) + "=> x\"" + a[2:] + "\", "
                string += str(cont) + "=>\"" + a + "\", "      # 14 bits constant

            else:
                cont_l = 0
                #string += str(cont) + "=> x\"" + a[2:] + "\",\n"
                string += str(cont) + "=>\"" + a + "\",\n"     # 14 bits constant
            cont   +=1
            cont_l +=1

    with open("kernel.txt", "w") as f:
        f.write(string)
    f.close()

Generate_string_constant(3, 1)
#Generate_img_VHDL("lena", (3,3), 3, 14)


