clear all;close all;clc;
[Setup ] = function_loadparameters();
load([Setup.Datapath '\05_XYZ_Alignment_Holograms.mat'])
load([Setup.Datapath '\04_All_Z_Calibration_Data.mat'],'COC')
try; load([Setup.Datapath '\07_XYZ_Calibration.mat'],'COC','Points'); catch; disp('COC not found'); end;
Ucalibs  =input('Enter the ID number of the calibration you would like to do/redo -> '); %place here the number of number of calibrations you want to do
try
    load([ Setup.Datapath '\DATA_05_Calibration.mat'], 'COC');
    disp(['Existing calibration found and loaded, we will overwrite or add calibrations # :' int2str(Ucalibs)]);
catch
    disp('No existing calibration found');
end
thezoom = Calibrations.Zooms{Ucalibs};

% Build list of datapaths
for ii = Ucalibs
    folder = [Setup.Datapath '\' int2str(ii) '\'];
    v = dir(folder);
    counter = 1;
    for j = 1:numel(v)
        if v(j).isdir == 0;
            datpath{ii,counter} = [Setup.Datapath '\'  int2str(ii) '\' v(j).name];
            counter = counter+1;
        end
    end
end
[imG, imR]=bigread3(datpath{Ucalibs(1),1});
data = sum(imR,3); data = max(data(:))-data;
data = imgaussfilt(data,3);
f = figure('units','normalized');%,'outerposition',[0 0 1 1]);
imagesc(data); title('Circle a blob that has been burned');
h = imellipse;
w = wait(h);
radius = sqrt(mean(var(w)));
close(f)
[LX,LY] = size(data);

for ii = Ucalibs
    SLM = Calibrations.SLM{ii};
    Points.SLM{ii} = [];
    Points.SI{ii} = [];
    LN = numel( SLM.Depths.SLM);
    for j = 2:LN
        [imG, imR]=bigread3(datpath{ii,j});
        data = sum(imR,3); data = max(data(:))-data;
        data = imgaussfilt(data,3);
        f = figure('units','normalized','outerposition',[0 0 1 1]);
        subplot(1,2,2); scatter(-SLM.XList,-SLM.YList);  axis([-1 0 -1 0]);title(datpath{ii,j})
        subplot(1,2,1); imagesc(flipud(fliplr(data))); title('First select here, then press n for next, q to quit, anything else to redo'); hold on;
        %Acquire N points here
        x = [];y = []; subcounter = 1; v = 'r';
        while v ~= 'q'
            [xt,yt] = ginput(1);
          %  bx = max(floor(yt-radius),1);
          %  by = max(floor(xt-radius),1);
          %  ex = min(floor(yt+radius),LX);
          %  ey = min(floor(xt+radius),LY);
          %  mask = data-data; mask(bx:ex,by:ey) = data(bx:ex,by:ey);
          %  [yt, xt] = function_findcenter(mask);
            scatter(xt,yt,'green');   
            waitforbuttonpress; v = get(gcf,'CurrentCharacter');
            if v == 'n'
                y(subcounter,1) = yt; x(subcounter,1) = xt;
                subcounter = subcounter+1;
                scatter(x,y,'red','filled'); hold on;
            end
        end
        subplot(1,2,2); title('Now select corresponding point here, leave by clicking on the left graph')
        subcounter=0;xx=x-x;yy=y-y;
        for k = 1:numel(x)
            subplot(1,2,1); scatter(x(k),y(k),'blue','filled'); hold on;
            subplot(1,2,2);
            scatter(-SLM.XList,-SLM.YList,'red','filled');  axis([-1 0 -1 0]); hold on; scatter(xx,yy,'blue');
            [xxx,yyy] = ginput(1); hold on;
            if abs(xxx)<0||abs(xxx)>1||abs(yyy)<0||abs(yyy)>1;  disp('Exit requested'); break; else xx(k)=xxx; yy(k)=yyy; end; % case where you want to exit loop
            if k<numel(x)
                [xx, yy] = function_guess_locations(x,y,xx,yy,k);
            end
            hold off;
            subplot(1,2,1); scatter(x(k),y(k),'red','filled'); hold on
        end
        distance = zeros(numel(x),numel(SLM.XList));
        for k = 1:numel(x)
            distance(k,:) = (-SLM.XList-xx(k)).^2+(-SLM.YList-yy(k)).^2;
        end
        [a,b] = min(distance');
        subplot(1,2,2);scatter(-SLM.XList(b),-SLM.YList(b),'green','filled');
        subplot(1,2,1); hold off;subplot(1,2,2); hold off;
        pause(1);
        z = (x-x)+ SLM.Depths.SI(j);
        xx = SLM.XList(b);
        yy = SLM.YList(b);
        zz = yy-yy+ SLM.Depths.SLM(j);
        Points.SLM{ii} = [Points.SLM{ii} ;[xx' yy' zz']];
        Points.SI{ii} = [Points.SI{ii} ;[x y z]];
        counter = counter+1;
        close(f)
    end   
    Points.RealDepths{ii} = SLM.Depths.True;
    Points.Calibrationdepths{ii} = SLM.Depths.SI;
    COC.Zooms{ii} = thezoom;
end

Points.SI{ii}(:,1)=512-Points.SI{ii}(:,1);
Points.SI{ii}(:,2)=512-Points.SI{ii}(:,2);
save([Setup.Datapath '\DATA_07_XYZ_Calibration.mat'],'Points');
modelterms.XY = [0 0 0; 1 0 0; 0 1 0; 0 0 1;1 1 0; 0 1 1 ; 1 0 1; 0 0 2; 2 0 0; 0 2 0; 2 1 0; 2 0 1; 1 2 0 ; 1 0 2; 0 1 2 ; 0 2 1];     %XY spatial calibration model for C_Of_C between SLM and true space
modelterms.Z = [0 0 0; 0 0 1; 0 0 2; 0 0 3; 0 0 4 ;0 1 0; 1 0 0];

for i = Ucalibs
    COC.SI_SLM_X{i} = polyfitn(Points.SI{i},Points.SLM{i}(:,1)',modelterms.XY); Guess.SLMX = polyvaln(COC.SI_SLM_X{i} ,Points.SI{i});
    COC.SI_SLM_Y{i} = polyfitn(Points.SI{i},Points.SLM{i}(:,2)',modelterms.XY); Guess.SLMY = polyvaln(COC.SI_SLM_Y{i} ,Points.SI{i});
    COC.SI_SLM_Z{i} = polyfitn(Points.SI{i},Points.SLM{i}(:,3)',modelterms.Z); Guess.SLMZ = polyvaln(COC.SI_SLM_Z{i} ,Points.SI{i});
    COC.SLM_SI_X{i} = polyfitn(Points.SLM{i},Points.SI{i}(:,1)',modelterms.XY); Guess.SIX = polyvaln(COC.SLM_SI_X{i} ,Points.SLM{i});
    COC.SLM_SI_Y{i} = polyfitn(Points.SLM{i},Points.SI{i}(:,2)',modelterms.XY); Guess.SIY = polyvaln(COC.SLM_SI_Y{i} ,Points.SLM{i});
    COC.SLM_SI_Z{i} = polyfitn(Points.SLM{i},Points.SI{i}(:,3)',modelterms.Z); Guess.SIZ = polyvaln(COC.SLM_SI_Z{i} ,Points.SLM{i});
end

g = figure(2);
subplot(1,2,1);
scatter3(Points.SLM{ii}(:,1),Points.SLM{ii}(:,2),Points.SLM{ii}(:,3),'filled', 'red'); hold on
scatter3(Guess.SLMX,Guess.SLMY,Guess.SLMZ,'blue'); hold on
xlabel('X - SLM');  ylabel('Y - SLM');  zlabel('Z - SLM');
legend({'Burned','Interpolation'})
subplot(1,2,2);
scatter3(Points.SI{ii}(:,1),Points.SI{ii}(:,2),Points.SI{ii}(:,3),'filled', 'red'); hold on
scatter3(Guess.SIX,Guess.SIY,Guess.SIZ,'blue'); hold on
xlabel('X - SI');  ylabel('Y - SI');  zlabel('Z - Optotune'); title(['Zoom = ' num2str(thezoom)]);
legend({'Recorded','Interpolation'})
pause(6)
saveas(g,[Setup.Displaypath '\_07_XYZ_Calibration.fig'])
save([Setup.Datapath '\07_XYZ_Calibration.mat'],'COC','Points')