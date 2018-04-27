function [Data sources]=extractROIs(img,depths,returnN)
sources=[];
makeMasks=0;
if nargin<3;
    returnN=100;
end

SizeThreshold = 250;
nd=numel(depths);
width=100:400;
height=1:512;
thresh=[];

% preprocess
filt=(fspecial('gaussian',[30 30],2));

for j = 1:nd  % for each depth
    z=zeros(512,512);
    temp=squeeze(img(:,:,j,2));
    temp2=conv2(temp,filt,'same');
    z(height,width)=temp2(height,width);
    Data(j).raw=z;
    Data(j).thresh=mean(temp(:))+std(temp(:));
end;

imageSizeX = 512;
imageSizeY = 512;
[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
radius = 6;
for k = 1:nd;
    clear OC;
    tic
    disp(['Segmenting Depth ' num2str(k)]);
    
    [output]  =FastPeakFind(Data(k).raw);
    OC(:,1)=output(1:2:end);
    OC(:,2)=output(2:2:end);
    
    for j = 1:length(OC);
        circlePixels = (rowsInImage  - OC(j,2)).^2 + (columnsInImage - OC(j,1)).^2 <= radius.^2;
        Flo=circlePixels.*Data(k).raw;
        Flo=Flo(:);
        Flo(Flo==0)=[];
        OC(j,3)=mean(Flo);
    end
    
    
    OC(OC(:,3)<Data(k).thresh,:)=[];
    
    OC=sortrows(OC,3);
    OC=flipud(OC);    %brightest first
    
    
    if size(OC,1)>returnN;
        try
            Data(k).OC=OC(1:returnN,:);
        catch
            Data(k).OC=OC;
        end
    else
        Data(k).OC=OC;
    end
    
    radius=7;
    if makeMasks
        sources = zeros(512,512,size(Data.OC,1));
        SE=strel('disk',radius,4);
        
        for n = 1:size(sources,3);
            sources(Data.OC(n,1),Data.OC(n,2),n)=1;
            sources(:,:,n)=imdilate(sources(:,:,n),SE);
        end
        
        
    end
    
    toc
end