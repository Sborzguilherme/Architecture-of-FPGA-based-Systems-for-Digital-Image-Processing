# FPGA based Systems for Digital Image Processing

Since image processing algorithms are expensive to be executed in software, hardware accelerators can be developed to increase performance for those algorithms. **Hardware accelerators** can consume less energy and execute fast while achieving good results.

In this context, this worked tries to identify hardware architectures implementations that can be applied over different use cases, and measure its impact in system metrics such as **latency, silicon cost and power consuption**. The use cases chosen in this work are **ALPR** (Automatic License Plate Recognition) and **Gaussian filter** algorithms. 

## ALPR

<p align="center">
  <img src="https://github.com/Sborzguilherme/Architecture-of-FPGA-based-Systems-for-Digital-Image-Processing/blob/master/Images/en_alpr_steps.png" height="75%" width="75%">
</p>


An ALPR system can be divided into four steps: 
  - Image Acquisition 
  - Vehicle License Plate Detection – VLPD 
  - Character Segmentation – CS 
  - Character Recognition – CR

In this study we chose to implement the **VLPD** step, since its the most time consuming step in the whole process, and presents some characteristics that can be found in others image processing algorithms.

<p align="center">
  <img src="https://github.com/Sborzguilherme/Architecture-of-FPGA-based-Systems-for-Digital-Image-Processing/blob/master/Images/en_block_diagram.png" height="75%" width="75%">
</p>

After accelerating the VLPD process we were able to achieve an **speedup of almost 23 times over software implementation**, while running in a frequency more than 10 times lower.

To get more details about our design and results, please check it out our [paper](https://ieeexplore.ieee.org/abstract/document/8862314) 

## Gaussian Filter

The second algorithm implemented was the Gaussian Filter, a well-know implementation, usually used for image smoothing on initial stages of edge detection algorithms. Since its a widely used application, we chose to implement different **hardware architectures** for this filter, and compare system metrics, aiming to identify how each implementation impact the system.

We also explore techiniques to improve **hardware/software** communication in a SOC-FPGA.

<p align="center">
  <img src="https://github.com/Sborzguilherme/Architecture-of-FPGA-based-Systems-for-Digital-Image-Processing/blob/master/Images/DMA.png" height="75%" width="75%">
</p>

Here is link to the article, in case you want to get more details about out implementation: [white paper](https://sol.sbc.org.br/index.php/sbesc_estendido/article/view/13111)
