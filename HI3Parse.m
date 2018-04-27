function outmat=HI3Parse(instr);

%string parser take instr, an input string and returns outmat, a cell of
%arrays containing ROI numbers to make ROI sequences;

%input is COMMA seperated!  Everything BETWEEN commas is a seperate
%command.  Inputs surround by brackets [ ] follow matlab syntax and denote
%a SINGLE Hologram.  Thus [1:5] will give you a single hologram containing
%ROIs 1,2,3,4,5.  [1:10:20 2:5:15] will give you a singe hologram
%containing ROI #s 1 11 2 7 12.  If your input DOES NOT have commas, it
%will be parsed as a sequence.  Eg, 1:5 will give you 5 holograms of 1,2,3,4,5 in that order, 
%'1:10:20 2:5:15' will return an error, but '1:10:20,2:5:15' will give you
%5 holograms, 1,11,2,7,12 in that order.  

%core of code - regexp find the index of every comma
[S I]= regexp(instr,',','match');

k=1;
location=1;
outchar=[];
for j=1:length(I)+1;   %for n commas + 1
    
    
   if j~= length(I)+1  %if we aren't at the end of the string
   f=instr(location:I(j)-1);   %then f=current character to the location directly before the next comma
   else
   f=instr(location:end);      %otherwise we take the current location to the end of string 
   end
   
   
   if strmatch(f(1),'[');
        outmat{k}=eval(f);          %matrix is store in a cell via eval
   else
       try
       miniSequence=eval(f);  %case '1:4'
       catch
       miniSequence=str2num(f); %case '1 2 3 4'
       end
       
       for u=1:numel(miniSequence);
           outmat{k}=miniSequence(u);
           k=k+1;
       end
       
       clear miniSequence
      % f=strcat('[',f,'] ');       %take on brackets to make it a matlab expression
        
   end
   
   
   if j~= length(I)+1         %if we aren't at the last character
       location=I(j)+1;       %start location for next string is the comma location + 1;
   end
   k=k+1;                     %increment counter for sequence
end 
   
