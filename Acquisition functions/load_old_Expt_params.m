function load_old_Expt_params()
%finds manually entered experiment paramters from first experiment of the
%day (date + 'a'), and enters them into ExpStruct.Expt_Params and GUI

global ExpStruct h Exp_Defaults
    
    Exp_Defaults.sweepduration = 1;
    Exp_Defaults.ISI=3;

    ExpStruct.Expt_Params.genotype = '';
    ExpStruct.Expt_Params.age = '';
    ExpStruct.Expt_Params.virus = '';
    ExpStruct.Expt_Params.slice = '';
    ExpStruct.Expt_Params.internal = '';
    ExpStruct.Expt_Params.brainregion = '';
    ExpStruct.Expt_Params.ExpType = '';
    ExpStruct.Expt_Params.notes = '';
    ExpStruct.Expt_Params.PMTsEditText = '';
    %ExpStruct.Expt_params.ConfigsEditText='';

%firstExpt = strcat(ExpStruct.SavePath,ExpStruct.date,'_A','.mat');
expName=ExpStruct.ExperimentName;
[str tok]=strtok(expName,'.');
thisExpLetter=str(length(str));

if isempty(strmatch(thisExpLetter,'A'))
prevExpLetter=char(thisExpLetter-1);

firstExpt = strcat(ExpStruct.SavePath,ExpStruct.date,'_',prevExpLetter,'.mat');


if exist(firstExpt, 'file') == 2 % if first experiment of the day exists (data + 'A')
    old_params = load(firstExpt, 'ExpStruct');
    old_def = load(firstExpt, 'Exp_Defaults');
  try
    old_params = old_params.ExpStruct.Expt_Params; % load Expt params from first expt

    ExpStruct.Expt_Params = old_params;

    set(h.genotype,'String',(ExpStruct.Expt_Params.genotype));
    set(h.age,'String',(ExpStruct.Expt_Params.age));
    set(h.virus,'String',(ExpStruct.Expt_Params.virus));
%     set(h.slice,'String',(ExpStruct.Expt_Params.slice));
    set(h.internal,'String',(ExpStruct.Expt_Params.internal));
    set(h.brainregion,'String',(ExpStruct.Expt_Params.brainregion));
    set(h.ExpTypeEditBox,'String',(ExpStruct.Expt_Params.ExpType));
%     set(h.notes,'String',(ExpStruct.Expt_Params.notes));
    set(h.PMTsEditText,'String',(ExpStruct.Expt_Params.PMTsEditText));
    
        
    Exp_Defaults.sweepduration = old_def.Exp_Defaults.sweepduration;
    Exp_Defaults.ISI=old_def.Exp_Defaults.ISI;
    set(h.set_ISI,'String',num2str(Exp_Defaults.ISI));
    set(h.set_length,'String',num2str(Exp_Defaults.sweepduration));
    
    
    
  catch
  end    
  
else
    
  
    
end
end;
