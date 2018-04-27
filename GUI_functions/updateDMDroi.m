function updateDMDroi(pos)

global h ExpStruct dmd

if isfield(dmd,'roimirror')
    delete(dmd.roimirror)
end


% xscalefactor = 1000/562.5;
% xscalefactor=10/11;
xscalefactor=dmd.scalefactor;

yscalefactor = xscalefactor;
totalwidth = round(pos(3)*xscalefactor);
totalheight = round(pos(4)*yscalefactor);

ExpStruct.grid.spacing = round(str2num(get(dmd.spacingtext,'String'))/yscalefactor);
ExpStruct.grid.width = round(str2num(get(dmd.widthtext,'String'))/xscalefactor);
ExpStruct.grid.height = round(str2num(get(dmd.heighttext,'String'))/yscalefactor);
ExpStruct.grid.numcol = round((pos(3)-ExpStruct.grid.width)/ExpStruct.grid.spacing);
ExpStruct.grid.numrow = round((pos(4)-ExpStruct.grid.height)/ExpStruct.grid.spacing);


% set(dmd.MaskText,'String',{strcat('Height = ',num2str(totalheight)),strcat('Width = ',num2str(totalwidth))})
set(dmd.MaskText,'String',{strcat('Height = ',num2str(totalheight)),strcat('Width = ',num2str(totalwidth)),...
    strcat(num2str(ExpStruct.grid.numcol),' columns'),strcat(num2str(ExpStruct.grid.numrow),' rows'),...
    ['Frames = ',num2str(ExpStruct.grid.numcol*ExpStruct.grid.numrow)],...
    ['Load time = ',num2str(round(ExpStruct.grid.numcol*ExpStruct.grid.numrow/3)),' s']})
dmd.roimirror=imrect(dmd.axes2,pos);

end