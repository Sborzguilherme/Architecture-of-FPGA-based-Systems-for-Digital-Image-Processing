# --------------------------------------------- Library Fixed-Point -------------------------------------------------- #
# Author: Guilherme Sborz
# Date: 29/07/2019
# Functions to deal with fixed-point <--> floating-point conversion
# -------------------------------------------------------------------------------------------------------------------- #
import numpy as np
import math
import Library_fixed_point as fx
import approximate_adder as APX
import scipy.linalg as la
# ---------------------------------------- Treat virtual board ------------------------------------------------------- #
# Parameters
#   img: input numpy array
#   kernel_height: used to define how many lines have to added to the image
#   kernel_width: used to define how many columns have to added to the image
#   approach: defines how to approach the virtual board problem
#       0 = create virtual board with zeros
#       1 = create virtual board with 255
#       2 = create virtual board repeting nearest pixel
#       3 = ignore virtual board and generate image with smaller size than the input image
def treat_virtual_board(img, kernel_heigth, kernel_width, approach = 3):

    img_heigth = len(img)
    img_width = len(img[0])

    num_lines   = (kernel_heigth-1)//2  # Number of extra lines (virtual board)
    num_columns = (kernel_width-1)//2   # Number of extra columns (virtual board)

    if(approach == 0):

        # Define the array that will be attached to the img
        column_start = np.zeros(shape=(img_heigth, num_columns))
        # Number of lines has to be alterated because is inserted after the collumns
        lines_start = np.zeros(shape=(num_lines, img_width+num_columns))
        column_end  = np.zeros(shape=(img_heigth+num_lines, num_columns))
        lines_end   = np.zeros(shape=(num_lines, img_width+(num_columns*2)))

    elif(approach == 1):
        # Define the array that will be attached to the img
        column_start = np.array([[255]*num_columns] * img_heigth)
        lines_start = np.array([[255]*(img_width+num_columns)]*num_lines)
        column_end = np.array([[255]*num_columns]*(img_heigth + num_lines))
        lines_end = np.array([[255] * (img_width + (num_columns*2))]*num_lines)

    elif(approach == 2):
        column_start = img[:,0]     # Get first column from image -> size is equal to the original img_height

        lines_start = img[0]        # Get first line from image   -> size is equal to the original img_width
        start_col_lin_start = np.array([lines_start[0]]*num_columns) # After inserting a new column is necessary to adjust the line width
        lines_start = np.append(start_col_lin_start, lines_start)

        column_end = img[:,-1]      # Get last column from image
        first_lin_col_end = np.array([column_end[0]] * num_lines)
        column_end = np.append(first_lin_col_end, column_end)

        lines_end = img[-1]         # Get last line from image
        first_col_lin_end = np.array([lines_end[0]] * (num_columns))
        last_col_lin_end = np.array([lines_end[-1]] * (num_columns))
        lines_end = np.append(first_col_lin_end, lines_end)
        lines_end = np.append(lines_end, last_col_lin_end)

        column_start = column_start.reshape([img_heigth, 1])
        lines_start = lines_start.reshape([1, img_width+num_columns])
        column_end = column_end.reshape([img_heigth+num_lines, 1])
        lines_end = lines_end.reshape([1, img_width+(num_columns*2)])

        aux_col_start = column_start
        aux_col_end = column_end
        aux_lines_start = lines_start
        aux_lines_end = lines_end

        for i in range(num_columns-1):
            column_start=np.append(column_start, aux_col_start, axis=1)
            column_end = np.append(column_end,aux_col_end, axis=1)
        for j in range(num_lines-1):
            lines_start = np.append(lines_start, aux_lines_start, axis=0)
            lines_end   = np.append(lines_end, aux_lines_end, axis=0)
    else:
        return img

    img = np.append(column_start, img, axis=1)  # Put zeros before first image columns
    img = np.append(lines_start, img, axis=0)  # Put zeros before first image lines
    img = np.append(img, column_end, axis=1)  # Put zeros after last image columns
    img = np.append(img, lines_end, axis=0)  # Put zeros after last image lines

    return img

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------- Floating point convolution -------------------------------------------------- #
# Parameters
#   img: input numpy array
#   kernel: input numpy array (defines the operation to be done)
def floating_point_convolution_2D(img, kernel, virtual_board):

    # Find kernel dimensions
    kernel_height = len(kernel)
    kernel_width = len(kernel[0])
    # Treat virtual board as specified in the parameter
    img = treat_virtual_board(img, kernel_height, kernel_width, virtual_board)

    # Define dimensions for output img
    output_img_width  = len(img[0]) - (kernel_width - 1)
    output_img_height = len(img)    - (kernel_height - 1)

    out_img = np.zeros([output_img_height, output_img_width])

    for i in range(output_img_height):          # Run through img lines
        for j in range(output_img_width):       # Run through img columns
            for k in range(kernel_height):        # Run through kernel lines
                for l in range(kernel_width):
                    out_img[i][j] += img[i + k][j + l] * kernel[k][l]
            if(out_img[i][j] > 255.0):
                out_img[i][j] = 255.0

    return out_img
# -------------------------------------- Generate Gaussian kernel ---------------------------------------------------- #
def gaussian_kernel_gen(size, sigma, Separable=False, factor = 10):

    gkernel = np.zeros(shape=(size,size))
    for_range = (size-1)//2
    s = 2*sigma**2
    sum = 0

    for x in range(for_range*-1, for_range+1):
        for y in range(for_range*-1, for_range+1):
            r = math.sqrt((x**2) + (y**2))
            gkernel[x+for_range][y+for_range] = (math.exp(-(r**2)/s)) / (math.pi*s)
            sum+=gkernel[x+for_range][y+for_range]

    for i in range(size):
        for j in range(size):
            gkernel[i][j] /= sum

    if(Separable):
        horizontal_kernel = gkernel[0]*factor                   # Horizontal
        vertical_kernel = np.zeros(size)

        for i in range(size):
            vertical_kernel[i] = gkernel[i][i] / horizontal_kernel[i]  # Acess main diagonal

        return horizontal_kernel, vertical_kernel

    return gkernel
# ------------------------------------------ Fixed-Point Convolution ------------------------------------------------- #
def fixed_point_convolution_2D(img, kernel, virtual_board):

    # Find kernel dimensions
    kernel_height = len(kernel)
    kernel_width = len(kernel[0])
    # Treat virtual board as specified in the parameter
    img = treat_virtual_board(img, kernel_height, kernel_width, virtual_board)

    # Define dimensions for output img
    output_img_width = len(img[0]) - (kernel_width - 1)
    output_img_height = len(img) - (kernel_height - 1)

    out_img = np.zeros([output_img_height, output_img_width])

    for i in range(output_img_height):                                  # Run through img lines
        for j in range(output_img_width):                               # Run through img columns
            for k in range(len(kernel)):                                # Run through kernel lines
                for l in range(len(kernel[0])):
                    img_fx = fx.float_to_integer_fx(img[i + k][j + l])  # Convert image value to int
                    kernel_fx = fx.float_to_integer_fx(kernel[k][l])    # Convert kernel value to int
                    out_img[i][j] += fx.fixed_point_mult(img_fx, kernel_fx)
    return out_img

def APX_Convolution(img, kernel, virtual_board):

    # Find kernel dimensions
    kernel_height = len(kernel)
    kernel_width = len(kernel[0])
    # Treat virtual board as specified in the parameter
    img = treat_virtual_board(img, kernel_height, kernel_width, virtual_board)

    # Define dimensions for output img
    output_img_width = len(img[0]) - (kernel_width - 1)
    output_img_height = len(img) - (kernel_height - 1)

    out_img = np.zeros([output_img_height, output_img_width])

    for i in range(output_img_height):                                              # Run through img lines
        for j in range(output_img_width):                                           # Run through img columns
            aux = []
            for k in range(len(kernel)):                                            # Run through kernel lines
                for l in range(len(kernel[0])):
                    img_fx = fx.float_to_integer_fx(img[i + k][j + l])              # Convert image value to int
                    kernel_fx = fx.float_to_integer_fx(kernel[k][l])                # Convert kernel value to int
                    aux.append(fx.float_to_fixed(APX.apx_mult(img_fx, kernel_fx)))  # Return a fixed-point value

                    #print("IMG_FX = ", img_fx, "\tKernel_fx = ", kernel_fx, "\tAux_Mult = ", fx.float_to_fixed(aux_mult), "\t\tAux = ", aux)
            out_img[i][j] = fx.fixed_to_float(APX.adder_tree_3_apx(aux))
    return out_img

# h, v = gaussian_kernel_gen(7, 1, True, 100)
# print("Horizontal = \n", h)
# print("Vertical = \n", v)