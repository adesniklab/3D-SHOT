function [ img ] = function_Loadjpg( filename, NX,NY,FF );

h = double(imread(filename)); h = mean(h,3); 
[LX,LY] = size(h);
scale = min(NX*FF/LX,LY*NY/LY);
h = imresize(h,scale);
[LX,LY] = size(h);
h = h-min(h(:));
h = h/max(h(:));
BX = max(1,floor((NX-LX)/2));
BY = max(1,floor((NY-LY)/2));
EX = BX+LX-1;
EY = BY+LY-1;
img = zeros(NX,NY);

try
    img(BX:EX,BY:EY) = h;
catch;
disp('Bad')
end

end

