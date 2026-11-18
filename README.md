# Water Pollution Detection Using Digital Image Processing

### Project Description:

#### Summary -
This project detects visible pollution on the surface of water using Digital Image Processing techniques in MATLAB. It calculates the percentage of polluted area, classifies the pollution level as LOW, MODERATE or HIGH, and provides suitable cleaning recommendations.

#### Course concepts used -
1. RGB to Grayscale Image Conversion, Sampling and Quantization.
2. 2-D Fourier Transform (FFT), Magnitude Spectrum and Histogram Processing.
3. Image Enhancement, Spatial Filtering, Morphological Operations and Color Image Processing.

#### Additional concepts used -
1. Texture Analysis and Color Difference Analysis.
2. Pollution Percentage Calculation and Pollution Level Classification.

#### Dataset -
Five or more original water-surface images are stored in the `data` folder. The images are used to evaluate visible pollution such as floating waste, debris and other surface variations.

Image source: Add the original image source or dataset link here.

#### Novelty -
1. Combines color, texture and frequency-domain features for visible water pollution detection.
2. Calculates the percentage of the detected polluted area.
3. Classifies pollution levels and provides suitable cleaning recommendations.

### Contributors:
1. JL Charan Teja -PES1UG24EC092
2. K Nada Kishan  -PES1UG24EC105
3. Diganth        -PES1UG24EC072

### Steps:

1. Clone Repository

```bash
git clone https://github.com/DIP-2026-MINI-PROJECT/Water-Pollution-Detection-Using-DIP.git
```

2. Open the project folder in MATLAB.

3. Ensure the input images are available inside the `data` folder.

4. Run the required MATLAB program (`waterp.m`, `water2p.m`, `water3p.m`, `water4p.m` or `water5p.m`) from MATLAB.

5. View the generated results and saved output images inside the `outputs` folder.

### Outputs:
- Original RGB water images.
- Grayscale and sampling results.
- Quantization and histogram results.
- 2-D FFT magnitude spectrum.
- Enhanced and filtered images.
- Morphological processing results.
- Color and texture analysis.
- Final pollution detection results.
- Pollution percentage and pollution classification.
- Cleaning recommendations.

### References:
1. Digital Image Processing – Rafael C. Gonzalez and Richard E. Woods.
2. MATLAB Image Processing Toolbox Documentation – https://www.mathworks.com/help/images/

### Limitations and Future Work:
- Detection is limited to visible surface pollution.
- Lighting conditions and water reflections may affect detection accuracy.
- Future work can include real-time water pollution monitoring and improved detection using additional image datasets.