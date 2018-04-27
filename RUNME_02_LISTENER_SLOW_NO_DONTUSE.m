clear all
close all
clc

[Setup ] = function_loadparameters(1);

%Overwrite delay uration
Setup.TimeToPickSequence = input('In seconds, enter duration of the listening for hologram selection ->');


%Here, load a list of hologram...
[FileName,PathName] = uigetfile('*.mat','Select sequences of holograms');
load([PathName, FileName])


[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
Function_shoot_slow_sequences(Setup,sequences);
[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
       
