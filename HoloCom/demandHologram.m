function demandHologram(holoNumber)
global ExpStruct



path =locations.HoloRequest_DAQ_DemandHolo

h=ExpStruct.Holo.holoRequests{ExpStruct.Holo.holoRequestNumber};
seq=h.Sequence{1};

if isempty(intersect(holoNumber,seq)) == 1;
    errordlg('You demanded a hologram that is not in the current sequence')
else
    save(path,'holoNumber');
end;


