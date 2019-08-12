import Library_fixed_point as lib_fx
import numpy as np

def apx_sum(a, b, bits):

    sum = np.zeros(bits)
    a_bin = bin(int(a,bits))  # Convert hex value to bitstring
    b_bin = bin(int(b,bits))

    a_bin = a_bin[2:].zfill(bits)       # Remove chars 0b
    b_bin = b_bin[2:].zfill(bits)
    cin = 0

    for i in range(len(a_bin)):
        pos = int(bits-i-1)

        i_A = int(a_bin[pos])
        i_B = int(b_bin[pos])

        sum[pos] = int(cin &  ((i_A ^1) | i_B))
        #print(pos, '- a = ', i_A, ', b = ', i_B, 'cin = ', cin , ', sum = ', sum[pos], end=', ')
        cin = i_A
        #print('cout = ', cin)

    string = ''
    for i in sum:
        string += str(i)[0]     # Gets onçy the first position from float value (1.0 -> 1)

    return hex(int(string, 2))

def apx_mult(a, b, bits):
    # Truth table for the approximated multiplier
    lookup_table = {"0000" : '000', "0001" : '000', "0010" : '000', "0011" : '000',
                    "0100" : '000', "0101" : '001', "0110" : '010', "0111" : '011',
                    "1000" : '000', "1001" : '010', "1010" : '100', "1011" : '110',
                    "1100" : '000', "1101" : '011', "1110" : '110', "1111" : '111'}

    # List to hold the multiplication pairs (e.g. a(1 downto 0) * b(1 downto 0))
    pairs_a = []
    pairs_b = []

    a_bin = bin(int(a, bits))  # Convert hex value to bitstring
    b_bin = bin(int(b, bits))

    a_bin = a_bin[2:].zfill(bits)  # Remove chars 0b and fill with zeros until the number of bits is reached
    b_bin = b_bin[2:].zfill(bits)

    # Divide the bitstring of each input into pairs
    for i in range(int(len(a_bin)/2)):
        string_a = str(a_bin[i*2]) + str(a_bin[(i*2) + 1])
        string_b = str(b_bin[i*2]) + str(b_bin[(i*2) + 1])
        pairs_a.append(string_a)
        pairs_b.append(string_b)

    #print('PA = ', pairs_a)
    #print('PB = ', pairs_b)

    cont_i = 0
    sum_pairs = []

    # Make the multiplication pairs (Each pair in A has to be multiplied by each pair in B)
    # After that, all pair will be summed, but with shifts
    # The number of shifts is decided by the position of the pair
    for i in reversed(pairs_a):             # Run through lists backwards
        cont_j = 0
        for j in reversed(pairs_b):
            key = i+j                       # Get the pair
            shift = 2*(cont_i + cont_j)
            if(shift == 1):                 # There is no shift in the first case (first pair of each input)
                shift = 0

            #print('KEY = ', key, 'RES = ', lookup_table[key], 'CONT i = ', cont_i, 'CONT J = ',cont_j, 'SHIFT = ', shift,  'ASW = ', int(lookup_table[key], 2) << shift)

            #print(shift)
            sum_pairs.append(int(lookup_table[key], 2) << shift)  # Look for the result in the truth table and shift the number of times needed
            cont_j += 1
        cont_i+=1

    array_answers = np.asarray(sum_pairs)
    result = array_answers.sum()
    result = result/(2**16)
    return result

a_str = "0220"                                  # Hexadecimal values
b_str = "4544"

print("a = ", lib_fx.fixed_to_float(a_str))     # Values converted to fixed-point
print("b = ", lib_fx.fixed_to_float(b_str))
#
a = int(a_str,16)                               # Values as integers
b = int(b_str,16)

print("fx = ", lib_fx.fixed_point_mult(a, b))
print("apx = ", apx_mult(a_str, b_str, 16))