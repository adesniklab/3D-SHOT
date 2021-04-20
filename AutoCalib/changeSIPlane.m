function out = changeSIPlane(z)
%Subfunction to send SI computer command to switch to given plane.
% a z value of -1 indicates abort.
% to be included in the path of the SI computers
%
% by Ian Antón Oldenburg 2019

hSI = evalin('base','hSI');
global autoCalibPlaneToUse

fprintf(['Update Z Plane ' num2str(z) ' ']);
autoCalibPlaneToUse = z;

if z<0
    hSI.abort();
    disp('Aborted')
else
    if strcmpi(hSI.acqState,'idle')
        hSI.hBeams.pzCustom= {@autoCalibSIPowerFun} ;

        if z==0
            hSI.hFastZ.userZs = [ 0 5];
        else
            hSI.hFastZ.userZs = [ 0 autoCalibPlaneToUse];
        end
        hSI.startGrab();
        disp('Started')
    else
        hSI.abort();
        hSI.hBeams.pzAdjust = 1;
        hSI.hBeams.pzCustom= {@autoCalibSIPowerFun} ;

        if invar(1)==0
            hSI.hFastZ.userZs = [ 0 5];
        else
            hSI.hFastZ.userZs = [ 0 autoCalibPlaneToUse];
        end
        hSI.startGrab();
        disp('restarted')
    end
end

out = 'gotit'; %part of the handshake
