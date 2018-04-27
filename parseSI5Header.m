function header = parseSI5Header(input)
%updated 12/16/17 arm for SI2017
s2017Index=strfind(input,'2017');
sIndex=strfind(input,'scanimage');

if  ~isempty(s2017Index);
    vs=2017;
    sIndex=strfind(input,'SI.');
    
elseif   isempty(sIndex) && isempty(s2017Index)
    vs=5;
    sIndex=strfind(input,'scanimage');
    
else
    vs=5.2;
    sIndex=strfind(input,'SI.');
    
end





if vs==5
    for i=1:size(sIndex,2)-1
        
        [field, remainder ] = strtok(input(sIndex(i):sIndex(i+1)-1));
        [tk, val] = strtok(remainder);
        field= strrep(field,'.','_'); %remove . from names if present
        val = val(2:end-1);
        try
            eval(['header.scanimage.(field(15:end))=' val ';']);
        catch %catch weird variables and translate to strings <>
            header.scanimage.(field(15:end))=val;
        end
    end
    [field, remainder ] = strtok(input(sIndex(i+1):end));
    [tk, val] = strtok(remainder);
    field= strrep(field,'.','_'); %remove . from names if present
    val2 = strtok(val);
    try
        eval(['header.scanimage.(field(15:end))=' val2 ';']);
    catch
        %        header.scanimage.(field(15:end))=val;
    end
    
elseif vs ==5.2 %should be largely similar to vs 5 just a few changes
    for i=1:size(sIndex,2)-1
        
        [field, remainder ] = strtok(input(sIndex(i):sIndex(i+1)-1));
        [tk, val] = strtok(remainder);
        %field= strrep(field,'.','_'); %remove . from names if present
        val = val(2:end-1);
        try
            eval(['header.SI.' field(4:end) ' =' val ';']);
        catch %catch weird variables and translate to strings <>
            header.SI.(field(4:end))=val;
        end
    end
    [field, remainder ] = strtok(input(sIndex(i+1):end));
    [tk, val] = strtok(remainder);
    %field= strrep(field,'.','_'); %remove . from names if present
    val2 = strtok(val);
    try
        eval(['header.SI.' field(4:end) ' = ' val2 ';']);
    catch
        header.SI.(field(4:end))=val;
    end
    
elseif vs ==2017 %should be largely similar to vs 5 just a few changes
    for i=1:size(sIndex,2)-1
        
        [field, remainder ] = strtok(input(sIndex(i):sIndex(i+1)-1));
        [tk, val] = strtok(remainder);
        %field= strrep(field,'.','_'); %remove . from names if present
        val = val(2:end-1);
        try
            eval(['header.SI.' field(4:end) ' =' val ';']);
        catch %catch weird variables and translate to strings <>
            header.SI.(field(4:end))=val;
        end
    end
    [field, remainder ] = strtok(input(sIndex(i+1):end));
    [tk, val] = strtok(remainder);
    %field= strrep(field,'.','_'); %remove . from names if present
    val2 = strtok(val);
    try
        eval(['header.SI.' field(4:end) ' = ' val2 ';']);
    catch
        header.SI.(field(4:end))=val;
    end
end