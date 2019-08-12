# --------------------------------------------- Library Fixed-Point -------------------------------------------------- #
# Author: Guilherme Sborz
# Date: 29/07/2019
# Functions to deal with fixed-point <--> floating-point conversion
# -------------------------------------------------------------------------------------------------------------------- #
# Library from python to deal with bits
from bitstring import Bits
import math

# Fixed-point format (8.12)
MSB = 8                                         # Bit signal + integer part (0 + 8)
LSB = 8                                         # Fract part

# Maximum value (considering 0 bits for signal)
MAX_VALUE = 2**(MSB+LSB)-1

# ---------------------------------- Algorithm to convert float to fixed-point --------------------------------------- #
# 1. X = floating_input * 2^(fractional_bits)
# 2. round x to nearest whole number
# 3. store x in a integer container

# Convert float value to fixed-point(string of bits)
# Parameters
#   val: float value to be converted,
#   print_msg: [optional, Default = False] choose if the warning overflow message will be printed
#   hex_format: [optional, Default = True] choose the output format of the string (True = hex, False = binary
def float_to_fixed(val: float, print_msg=False, hex_format=True) -> str:
    x = val * (2**(LSB))                            # Step 1 from the algorithm
    x = round(x)                                    # Step 2 from the algorithm
    if(x > MAX_VALUE):                              # Verify overflow
        if(print_msg):
            print("WARNING: ROUNDED VALUE")
            return_value = str(bin(MAX_VALUE))[2:]  # Round to MAX_VALUE (as a string format)([2:] -> remove the 0b from the start of the string)
    else:
        x = str(bin(int(x)))                        # Convert integer value to a string of bits
        return_value = x[2:].zfill(MSB+LSB)         # Complete with zeros in the left until the fixed length is reached
    if(hex_format):
        return_value = hex(int(return_value, 2))    # Convert binary string to hexadecimal string
        return_value = "0x" + return_value[2:].zfill(int(math.ceil((MSB+LSB)/4)))  # Complete the number of zeros until all the bits are
                                                                    #    represented in the hexadecimal format

    return return_value                             # Return the string value in binary format
# ---------------------------------- Algorithm to convert fixed-point to float --------------------------------------- #
# 1. Convert string bits received to a integer value
# 2. Divide integer value by the fract part of the fixed-point format
# Parameters
#   val: fixed value to be converted
#   str_format: indicate the format of the string (2: for string in binary format, 16: for string in hexadecimal format)
def fixed_to_float(val:str, str_format=16) -> float:
    x = int(val,str_format)                             # Convert string received to interger value
    return x/(2**LSB)                                   # Return integer value divided by the fractionary part
# ------------------------- Function to convert float to integer (fixed point notation) ------------------------------ #
def float_to_integer_fx(num):
    num *= (2 ** (LSB))    # Step 1 from the algorithm
    return round(num)      # Step 2 from the algorithm
# ----------------------------------------- Fixed-Point Multiplication ----------------------------------------------- #
def fixed_point_mult(a, b):
    mult = (a * b)/(2**LSB)
    return mult/(2**LSB)

#print(float_to_fixed(0.20417996))
#print(fixed_to_float('0101', 16))
#print(float_to_fixed(fixed_point_mult(0.203125, 255)))


