function ScaleFactor=correctPower(I,xyPowerInterp,XYZ_Points)
   global ExpStruct 
    ExpStruct.Holo.currentHolo=1;

    roi= ExpStruct.Holo.ROIdata.rois(ExpStruct.Holo.currentHolo);
    Query=[ roi.centroid(1),roi.centroid(2),0];  %CHECK TO MAKE SURE ZLEVEL WORKS WELL
    
    [ Query_T ] = function_3DCofC(Query', XYZ_Points );
    
    ScaleFactor=xyPowerInterp(Query_T(1),Query_T(2)); 

   

    
    