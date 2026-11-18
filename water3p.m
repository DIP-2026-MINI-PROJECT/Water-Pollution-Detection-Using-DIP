clc;
clear;
close all;
I = imread(fullfile('data','water3.jpg'));
if size(I,3)==1
I=repmat(I,1,1,3);
end
I=imresize(I,[500 700]);
gray=rgb2gray(I);
grayDouble=im2double(gray);
sampled=imresize(gray,0.5);
sampledBack=imresize(sampled,size(gray));
samplingError=mean(abs(double(gray(:))-double(sampledBack(:))));
quantized=uint8(floor(double(gray)/32)*32);
quantizationError=mean(abs(double(gray(:))-double(quantized(:))));
figure;
subplot(2,2,1); imshow(I); title('RGB Image');
subplot(2,2,2); imshow(gray); title('Grayscale Image');
subplot(2,2,3); imshow(sampled); title('Sampling');
subplot(2,2,4); imshow(quantized); title('Quantization');
figure;
imhist(gray);
title('Pixel Intensity Histogram');
F=fft2(double(gray));
Fshift=fftshift(F);
spectrum=log(1+abs(Fshift));
figure;
imshow(spectrum,[]);
title('2-D FFT Magnitude Spectrum');
[M,N]=size(gray);
[X,Y]=meshgrid(1:N,1:M);
distance=sqrt((X-(floor(N/2)+1)).^2+(Y-(floor(M/2)+1)).^2);
highFreqMask=distance>80;
highFreq=Fshift.*highFreqMask;
highFreqImage=real(ifft2(ifftshift(highFreq)));
highFreqImage=mat2gray(abs(highFreqImage));
detailValue=std(highFreqImage(:));
smoothImage=imgaussfilt(grayDouble,1);
noiseImage=abs(grayDouble-smoothImage);
noiseLevel=std(noiseImage(:))*255;
figure;
subplot(1,2,1); imshow(highFreqImage); title('High-Frequency Details');
subplot(1,2,2); imshow(noiseImage,[]); title('High-Frequency Residual');
enhanced=imadjust(grayDouble);
equalized=histeq(grayDouble);
claheImage=adapthisteq(gray,'NumTiles',[8 8],'ClipLimit',0.01);
avgFilter=fspecial('average',[5 5]);
averaged=imfilter(enhanced,avgFilter,'replicate');
denoised=medfilt2(enhanced,[3 3]);
lowPass=imgaussfilt(enhanced,2);
highPass=enhanced-lowPass;
sharpened=imsharpen(enhanced);
edges=edge(denoised,'Canny');
figure;
subplot(2,4,1); imshow(grayDouble); title('Original Grayscale');
subplot(2,4,2); imshow(enhanced); title('Contrast Enhancement');
subplot(2,4,3); imshow(equalized); title('Histogram Equalization');
subplot(2,4,4); imshow(claheImage); title('CLAHE');
subplot(2,4,5); imshow(averaged); title('Averaging Filter');
subplot(2,4,6); imshow(denoised); title('Median Denoising');
subplot(2,4,7); imshow(highPass,[]); title('High-Pass Residual');
subplot(2,4,8); imshow(sharpened); title('Sharpening');
figure;
imshow(edges);
title('Canny Edge Detection');
claheDouble=im2double(claheImage);
topHatImage=imtophat(claheDouble,strel('disk',10,0));
figure;
subplot(1,3,1); imshow(claheImage); title('CLAHE Image');
subplot(1,3,2); imshow(topHatImage,[]); title('Top-Hat Transformation');
subplot(1,3,3); imshow(imadjust(topHatImage),[]); title('Top-Hat Enhanced');
figure;
h=imshow(I);
axis image;
title({'Draw polygon around water area','Exclude walls, buildings and plants; double-click to finish'});
waterROI=drawpolygon('Color','y');
wait(waterROI);
waterRegion=createMask(waterROI,h);
if ~any(waterRegion(:))
error('No analysis area selected.');
end
[yy,xx]=find(waterRegion);
xmin=min(xx); xmax=max(xx);
ymin=min(yy); ymax=max(yy);
waterArea=I(ymin:ymax,xmin:xmax,:);
waterRegion=waterRegion(ymin:ymax,xmin:xmax);
figure;
imshow(waterArea);
title('Selected Water Area');
while true
refFig=figure;
imshow(waterArea);
axis image;
title('Select clean-looking water reference patch');
refROI=drawrectangle('Color','g');
wait(refROI);
pos=refROI.Position;
rx1=max(1,floor(pos(1)));
ry1=max(1,floor(pos(2)));
rx2=min(size(waterArea,2),ceil(pos(1)+pos(3)));
ry2=min(size(waterArea,1),ceil(pos(2)+pos(4)));
if rx2>rx1 && ry2>ry1
refRegion=waterRegion(ry1:ry2,rx1:rx2);
if any(refRegion(:))
break;
end
end
close(refFig);
disp('Select a reference patch inside the water area.');
end
close(refFig);
reference=waterArea(ry1:ry2,rx1:rx2,:);
refPixels=im2double(reference);
refPixels=reshape(refPixels,[],3);
refPixels=refPixels(refRegion(:),:);
if isempty(refPixels)
error('Invalid reference patch.');
end
refColor=median(refPixels,1);
waterRGB=im2double(waterArea);
colorDiff=sqrt(sum((waterRGB-reshape(refColor,1,1,3)).^2,3));
refColorDiff=sqrt(sum((refPixels-refColor).^2,2));
colorThreshold=max(0.10,prctile(refColorDiff,95)+0.03);
colorCandidate=colorDiff>colorThreshold;
waterGray=im2double(rgb2gray(waterArea));
waterSmooth=imgaussfilt(imadjust(waterGray),1);
waterTexture=stdfilt(waterSmooth,true(5));
refTexture=waterTexture(ry1:ry2,rx1:rx2);
refTexture=refTexture(refRegion);
refTextureValue=median(refTexture(:));
textureDiff=abs(waterTexture-refTextureValue);
refTextureDiff=abs(refTexture-refTextureValue);
textureThreshold=max(0.025,prctile(refTextureDiff,95)+0.01);
textureCandidate=textureDiff>textureThreshold;
edgeImage=edge(waterSmooth,'Canny');
edgeImage=edgeImage & waterRegion;
edgeNearWaste=imdilate(edgeImage,strel('disk',2,0));
waterCLAHE=adapthisteq(im2uint8(waterGray),'NumTiles',[8 8],'ClipLimit',0.01);
waterCLAHE=im2double(waterCLAHE);
waterTopHat=imtophat(waterCLAHE,strel('disk',10,0));
topHatThreshold=graythresh(waterTopHat);
topHatCandidate=waterTopHat>topHatThreshold;
candidate=colorCandidate & (textureCandidate | edgeNearWaste | topHatCandidate);
candidate=candidate & waterRegion;
candidate=imopen(candidate,strel('disk',1,0));
candidate=imclose(candidate,strel('disk',2,0));
candidate=bwareaopen(candidate,15);
candidate=candidate & waterRegion;
totalWaterPixels=nnz(waterRegion);
candidatePixels=nnz(candidate);
if totalWaterPixels==0
error('Selected water area is empty.');
end
candidatePercentage=100*candidatePixels/totalWaterPixels;
if candidatePercentage<5
pollutionLevel='Low';
recommendation='Continue regular water surface monitoring.';
elseif candidatePercentage<20
pollutionLevel='Moderate';
recommendation='Inspect suspicious areas and remove visible floating waste if confirmed.';
else
pollutionLevel='High';
recommendation='Prioritize inspection and cleaning of confirmed visible waste areas.';
end
figure;
imshow(waterArea);
hold on;
redOverlay=cat(3,ones(size(candidate)),zeros(size(candidate)),zeros(size(candidate)));
overlayHandle=imshow(redOverlay);
set(overlayHandle,'AlphaData',0.35*double(candidate));
hold off;
title(sprintf('Possible Candidate Area: %.2f%%',candidatePercentage));
figure;
subplot(2,3,1); imshow(colorDiff,[]); title('Color Difference');
subplot(2,3,2); imshow(textureDiff,[]); title('Texture Difference');
subplot(2,3,3); imshow(edgeImage); title('Canny Edges');
subplot(2,3,4); imshow(waterTopHat,[]); title('Top-Hat Features');
subplot(2,3,5); imshow(candidate); title('Combined Candidate Map');
subplot(2,3,6); imshow(waterArea); title('Original Water Area');
colorPercent=100*nnz(colorCandidate & waterRegion)/totalWaterPixels;
texturePercent=100*nnz(textureCandidate & waterRegion)/totalWaterPixels;
edgePercent=100*nnz(edgeImage)/totalWaterPixels;
topHatPercent=100*nnz(topHatCandidate & waterRegion)/totalWaterPixels;
fprintf('\n========== FINAL WATER POLLUTION ANALYSIS ==========\n');
fprintf('\nIMAGE FUNDAMENTALS\n');
fprintf('Sampling Error: %.2f\n',samplingError);
fprintf('Quantization Error: %.2f\n',quantizationError);
fprintf('\nFREQUENCY ANALYSIS\n');
fprintf('Frequency Detail Level: %.4f\n',detailValue);
fprintf('High Frequency Residual: %.4f\n',noiseLevel);
fprintf('\nIMAGE ENHANCEMENT\n');
fprintf('Original Contrast: %.4f\n',std(grayDouble(:)));
fprintf('CLAHE Contrast: %.4f\n',std(im2double(claheImage(:))));
fprintf('\nFEATURE ANALYSIS\n');
fprintf('Reference Texture: %.4f\n',refTextureValue);
fprintf('Color Threshold: %.4f\n',colorThreshold);
fprintf('Texture Threshold: %.4f\n',textureThreshold);
fprintf('Color Candidate Area: %.2f%%\n',colorPercent);
fprintf('Texture Candidate Area: %.2f%%\n',texturePercent);
fprintf('Edge Area: %.2f%%\n',edgePercent);
fprintf('Top-Hat Candidate Area: %.2f%%\n',topHatPercent);
fprintf('\nFINAL DETECTION RESULTS\n');
fprintf('Analyzed Water Pixels: %d\n',totalWaterPixels);
fprintf('Candidate Pixels: %d\n',candidatePixels);
fprintf('Candidate Area Percentage: %.2f%%\n',candidatePercentage);
fprintf('Possible Visible Pollution Level: %s\n',pollutionLevel);
fprintf('Cleaning Recommendation: %s\n',recommendation);
fprintf('\nINTERPRETATION\n');
fprintf('Candidate pixels are possible suspicious areas.\n');
fprintf('Candidate percentage is not verified pollution percentage.\n');
fprintf('Low: Below 5%% candidate area.\n');
fprintf('Moderate: 5%% to below 20%% candidate area.\n');
fprintf('High: 20%% or above candidate area.\n');
fprintf('Classification thresholds are proposed project thresholds.\n');
fprintf('Reflections, shadows and natural texture may be detected.\n');
fprintf('Image processing cannot confirm chemical water quality.\n');
fprintf('====================================================\n');
imwrite(waterArea,'selected_water_area.jpg');
imwrite(colorDiff,'color_difference.jpg');
imwrite(textureDiff,'texture_difference.jpg');
imwrite(waterTopHat,'top_hat_features.jpg');
imwrite(candidate,'combined_candidate_image.png');
outputFolder = fullfile(pwd,'outputs');

if ~exist(outputFolder,'dir')
    mkdir(outputFolder);
end

figures = findall(groot,'Type','figure');

for k = 1:length(figures)
    exportgraphics(figures(k), ...
        fullfile(outputFolder,sprintf('result_%02d.png',k)));
end
