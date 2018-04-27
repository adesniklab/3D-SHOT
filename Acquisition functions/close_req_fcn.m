function close_req_fcn(src,evnt)
% User-defined close request function 
% to display a question dialog box 

global ExpStruct cell1 cell2 LED Ramp Exp_Defaults h sweeps L

selection = questdlg('Save and Close?',...
    '',...
    'Yes','No','Yes');
switch selection,
    case 'Yes',
        
        %Check to ensure not overwriting data
        if exist([ExpStruct.SaveName '.mat'])==2
            confirm = questdlg('Caution: this will overwrite an existing file. Continue?',...
                'WARNING',...
                'Yes','No','No');
            switch confirm
                case 'Yes',
                    saveAndindexAcq
                    delete(gcf)
                
                    close all
                case 'No'
                   
                    delete(confirm)
            end
        elseif ~exist([ExpStruct.SaveName '.mat'])
            saveAndindexAcq
            delete(gcf)
            close all
        end
        
    case 'No'
       
        delete(gcf)
        close all
        return
end
end