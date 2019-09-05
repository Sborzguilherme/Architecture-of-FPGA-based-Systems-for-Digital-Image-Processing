import matplotlib.pyplot as plt
import Library_img_from_txt as lib_txt
import Morph_Operations as MO
import numpy as np
import cv2 as cv

img_height = 212
img_width  = 252

filename = "../../Data/Output_Data/ALPR/MKE-6858_Result.txt"
ori_img = lib_txt.open_img_from_txt_binary(filename, img_height, img_width)

backtorgb = cv.cvtColor(ori_img,cv.COLOR_GRAY2RGB)

# Mask size  = 40x100
# Plate region = 30x80
plate_region = np.array([[255]*80]*30)

col_countours_start = np.zeros(shape=(30, 10))
lin_countours_start = np.zeros(shape=(5,90))
col_countours_end = np.zeros(shape=(35, 10))
lin_countours_end = np.zeros(shape=(5, 100))

mask = np.append(col_countours_start, plate_region, axis=1)
mask = np.append(lin_countours_start, mask, axis=0)
mask = np.append(mask, col_countours_end, axis=1)
mask = np.append(mask, lin_countours_end,axis=0)


# Find plate position within the image
i,j = MO.template_matching(ori_img, mask)
print(i,j)

cv.rectangle(backtorgb,(j,i),(j+100,i+40),(255,0,0),2)

#cv.rectangle(backtorgb,(110,100),(220,160),(0,255,0),2)

# img_SUB_height = 224
# img_SUB_width = 284
#
# img_MC_height = 212
# img_MC_width = 252
#
# filename_result = "../Data/MKE-6858_MC_out.txt"
# img_MC_result = lib_txt.open_img_from_txt_binary(filename_result, img_MC_height, img_MC_width)
# filename_VHDL = "../Data/MKE-6858_Result_MC.txt"
# img_MC_VHDL = lib_txt.open_img_from_txt_binary(filename_VHDL, img_MC_height, img_MC_width)
#
# diff = cv.absdiff(img_MC_result, img_MC_VHDL)
#
# print(MO.psnr(img_MC_result, img_MC_VHDL))
#
# #plt.subplot(211)
plt.figure(num="MASK")
plt.title("Máscara de Comparação")
plt.imshow(mask, cmap='gray')
plt.xlabel("Largura da Máscara")
plt.ylabel("Altura da Máscara")

plt.figure(num="Comparação de Template")
plt.title("Resultado da Operação de Comparação de Template")
plt.imshow(backtorgb)
# plt.figure(num = "DIFFERENCE")
# plt.imshow(diff, cmap='gray')

plt.show()