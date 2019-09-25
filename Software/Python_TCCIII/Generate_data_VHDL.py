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
            a = Lib_fx.float_to_fixed(kernel[i][j], hex_format=True) # 14 bits constant
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

def Generate_LUT_constants(kernel_size):

    kernel = Lib_op.gaussian_kernel_gen(kernel_size, 1)

    kernel = kernel.reshape(len(kernel[0])*len(kernel))

    fx_kernel = []
    for i in range(len(kernel)):
        fx_kernel.append(Lib_fx.float_to_fixed(kernel[i]))

    mylist = list(dict.fromkeys(fx_kernel)) # Remove duplicated items

    Lut = [[] for i in range(len(mylist))]

    for i in range(len(mylist)):
        a = Lib_fx.fixed_to_float(mylist[i])
        a = Lib_fx.float_to_integer_fx(a)
        for j in range(256):
            result = Lib_fx.fixed_point_mult(a, j)
            fx_result = Lib_fx.float_to_fixed(result*(2**8))
            Lut[i].append(fx_result[2:])

    string = ''
    for i in range(len(Lut)):
        cont = 0
        string += "constant c_Gaussian_Lut_"+ str(kernel_size)+"_W" + str(i) + ": fixed_vector(255 downto 0):= (\n"
        for j in range(len(Lut[0])):
            if(cont == 5):
                string+= str(j)+" => x\"" + Lut[i][j] + "\",\n"
                cont=0
            else:
                string+= str(j)+" => x\"" + Lut[i][j] + "\",\t"
                cont+=1
        string = string[:-2] + ");\n\n"

    with open("lut.txt", "w") as f:
        f.write(string)
    f.close()

def Generate_Gaussian_Constants_1D(size, sigma, factor):
    horizontal, vertical = Lib_op.gaussian_kernel_gen(size, sigma, True, factor)
    cont = 0

    string = "constant c_Gaussian_Kernel_" +str(size)+"_Hor : fixed_vector("+ str(size-1) + " downto 0) := (\n\t"

    for i in horizontal:
        a = Lib_fx.float_to_fixed(i,hex_format=False)
        string += str(cont) + "=>\"" + a + "\", "
        cont+=1

    string = string[:-2] + ");\n"
    string += "constant c_Gaussian_Kernel_" +str(size)+"_Ver : fixed_vector("+ str(size-1) + " downto 0) := (\n\t"
    cont = 0
    for i in vertical:
        a = Lib_fx.float_to_fixed(i,hex_format=False)
        string += str(cont) + "=>\"" + a + "\", "
        cont+=1
    string = string[:-2] + ");"

    with open("kernel.txt", "w") as f:
        f.write(string)
    f.close()


Generate_string_constant(3, 1)
#Generate_img_VHDL("lena", (5,5), 2, 16)
#Generate_LUT_constants(7)
#Generate_Gaussian_Constants_1D(7,1,100)
