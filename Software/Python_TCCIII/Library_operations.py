# --------------------------------------------- Library Fixed-Point -------------------------------------------------- #
# Author: Guilherme Sborz
# Date: 29/07/2019
# Functions to deal with fixed-point <--> floating-point conversion
# -------------------------------------------------------------------------------------------------------------------- #
import numpy as np
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

    num_lines   = (kernel_heigth-1)//2
    num_columns = (kernel_width-1)//2

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
        last_col_lin_start = np.array([lines_start[0]]*num_columns)
        lines_start = np.append(last_col_lin_start, lines_start)

        column_end = img[:,-1]      # Get last column from image
        first_lin_col_end = np.array([column_end[0]] * num_lines)
        column_end = np.append(first_lin_col_end, column_end)

        lines_end = img[-1]         # Get last line from image
        first_col_lin_end = np.array([lines_end[0]] * (num_columns))
        last_col_lin_end = np.array([lines_end[-1]] * (num_columns))
        lines_end = np.append(first_col_lin_end, lines_end)
        lines_end = np.append(lines_end, last_col_lin_end)

        column_start = column_start.reshape([img_heigth, num_columns])
        lines_start = lines_start.reshape([num_lines, img_width+num_columns])
        column_end = column_end.reshape([img_heigth+num_lines, num_columns])
        lines_end = lines_end.reshape([num_lines, img_width+(num_columns*2)])

        for i in range(num_columns-1):
            column_start=np.append(column_start, column_start, axis=1)
            column_end = np.append(column_end,column_end, axis=1)
        for j in range(num_lines-1):
            lines_start = np.append(lines_start, lines_start, axis=0)
            lines_end   = np.append(lines_end, lines_end, axis=0)

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
def open_txt_values(img, kernel, virtual_board = 3):
    pass

# -------------------------------------------------------------------------------------------------------------------- #

a = np.array([[1,3,5], [2,4,6]])
b = a[:,-1]
print(treat_virtual_board(a, 3, 3, 2))