# --------------------------------------------- Library Fixed-Point -------------------------------------------------- #
# Author: Guilherme Sborz
# Date: 29/07/2019
# Functions to deal with files opening
# -------------------------------------------------------------------------------------------------------------------- #
import numpy as np
import Library_fixed_point as fx
# -------------------------------------- Function to open txt file --------------------------------------------------- #
# Open txt with image in fixed-point format (always binary values)
def open_txt_values(filename, img_height, img_width):
    img_txt = []                                        # Create list to receive the values read from file
    with open(filename, 'r') as f:                      # Open file
        data = f.readlines()                            # Read all lines
        for line in data:                               # Run through all lines
            img_txt.append(line[:-1])                   # Read binary strings while removing "\n"
    f.close()
    img_aux = np.ndarray(len(img_txt))                  # Convert list to numpy array

    for i in range(len(img_txt)):                       # Run through all pixels
        img_aux[i] = fx.fixed_to_float(img_txt[i], 2)   # Convert image from fixed-point to float for plot

    img_aux = img_aux.reshape([img_height, img_width])  # Convert 1-D array into 2-D array

    return img_aux
# -------------------------------------------------------------------------------------------------------------------- #

# ----------------------------- Function to generate txt file (fixed-point image) ------------------------------------ #
def generate_txt_fixed_point_img(img, filename):
    img_height = len(img)           # Find image dimensions
    img_width = len(img[0])

    string_txt = ''                 # String to be written in the file

    for i in range(img_height):     # Run through lines
        for j in range(img_width):  # Run through collumns
            string_txt += str(fx.float_to_fixed(img[i][j],hex_format=False)) + '\n' # Append in the string the fixed value + "\n"

    with open(filename, 'w') as f: # After all img has been read, open file
        f.write(string_txt)        # And write the string
    f.close()                      # Close file
# -------------------------------------------------------------------------------------------------------------------- #
