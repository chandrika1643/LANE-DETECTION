clc;
clear all;
close all;
%reading the vedio
vid=VideoReader('chase.mp4');
%number of frames in vedio
n=vid.NumberOfFrames;
r1=399;
r2=522;
c1=1;
c2=1280;
for z =1:50:n    %reading each frame
    image=read(vid,z);
    %low light image correction 
    AInv = imcomplement(image);
    source = imreducehaze(AInv);
    source= imcomplement(source);
       
    %region of interest from the image
    roi=source(r1:r2,c1:c2,:);
   % figure,imshow(roi)
    %EDGE DETECTION
    %convert to grayscale for the processing
    I = rgb2gray(roi);
    %gaussian blur,sharpening and canny
    G=imgaussfilt(I,0.5);
    I_G = imsharpen(G,'Radius',0.5,'Amount',1.5);
     %  figure, imshow(I_G);
    t=graythresh(I_G);
    BW = imbinarize(I_G,'adaptive','ForegroundPolarity','dark','Sensitivity',0.8);
   %   imshow(BW);

   %edge detection on the image and processing on it for noise suppressions
    [~,threshold] = edge(BW,'canny');
    fudgeFactor = t;
    BWs = edge(BW,'canny',threshold * fudgeFactor);
    se90 = strel('line',3,90);
    se0 = strel('line',3,0);
    BWsdil = imdilate(BWs,[se90 se0]);
    BWdfill = imfill(BWsdil,'holes');
   % BWdfill = imfill(BWdfill);
   %{
    seD = strel('rectangle',[3 2]);
    BWfinal = imerode(BWdfill,seD);
      %}
    BWfinal=bwareaopen(BWdfill,15);
    %size of orginal image and resizing the roi to fit with the orginal
    %image
    [i,j,d]=size(image);
    final=[zeros((r1-1),c2);BWfinal;zeros((i-r2),c2)];
    %imshow(labeloverlay(source,final));
    
   %applying hough transform
   %theta value 
    a1=-79:0.5:30;
    a2=30:0.5:89;
    a=[a1, a2];
  %hough
    [H,T,R]=hough(final,'RhoResolution',1,'Theta',a);
    P_Y=houghpeaks(H,5,'threshold',0.2.*max(H(:)));
    
    lane=houghlines(final,T,R,P_Y,'FillGap',5,'MinLength',10);
    %ploting image
    imshow(image)
    hold on;
    %ploting hough lanes to the iamge
    for h=1:length(lane)
        p=[lane(h).point1;lane(h).point2];
        plot(p(:,1),p(:,2),'lineWidth',3,'Color','blue')
    end
  
end
       