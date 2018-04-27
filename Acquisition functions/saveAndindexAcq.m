function saveAndindexAcq(~)
    %% saves data acquired in Acq, indexes metadata in .xls
    
    global ExpStruct  cell1 cell2 LED Ramp Exp_Defaults h s sweeps
   
    numberOfcells=get(h.record_cell2_check, 'Value')+1;
    ExpStruct.description={'';'';'';'';''};
    prompt={'Describe current experiment','Cell1 Layer','Cell1 Cell Type','Cell2 Layer','Cell2 Cell Type'};
    ExpStruct.description =inputdlg(prompt,'Describe experiment',[1 60]);    
    
    descriptionTable = table({ExpStruct.SaveName},{datestr(ExpStruct.exp_start_time)},numberOfcells,...
        {ExpStruct.Expt_Params.ExpType},{ExpStruct.Expt_Params.genotype},{ExpStruct.Expt_Params.internal},...
        {ExpStruct.Expt_Params.virus},{ExpStruct.Expt_Params.slice},{ExpStruct.Expt_Params.age},...
        {ExpStruct.Expt_Params.brainregion},{ExpStruct.Expt_Params.notes},{ExpStruct.description{1}},{datestr(now)},...
        {ExpStruct.description{2}},{ExpStruct.description{3}},{ExpStruct.description{4}},{ExpStruct.description{5}},...
        'VariableNames',{'SavePath','StartTime','numberOfcells','ExpType','Genotype','Internal','Virus','Slice','Age',...
        'BrainRegion','Notes','Description','SaveTime','Cell1_Layer','Cell1Type','Cell2_Layer','Cell2Type'});

   save(ExpStruct.SaveName,'-v7.3');
    
    if exist([ExpStruct.IndexPath,'.mat'])==0    
        indextable = descriptionTable;
    elseif exist([ExpStruct.IndexPath,'.mat'])==2
        load([ExpStruct.IndexPath,'.mat'],'indextable');      
        indextable = [indextable;descriptionTable];
    end
    save([ExpStruct.IndexPath,'.mat'],'indextable');
    writetable(indextable,[ExpStruct.IndexPath,'.xlsx']); 
end