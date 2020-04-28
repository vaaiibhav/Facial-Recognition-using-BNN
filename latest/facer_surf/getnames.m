function name = getnames( inputimage1 )
%GETNAMES Summary of this function goes here
%   Detailed explanation goes here

global surf_names 
parts = strsplit(inputimage1, '\');
DirPart = parts{end-1} ;
disp(DirPart);
if (strcmp(DirPart,'s01'))
    surf_names = 'Anthony';
    
elseif (strcmp(DirPart,'s02'))
    surf_names = 'Adam';
elseif (strcmp(DirPart,'s03'))
     surf_names = 'John';
else 
     surf_names = 'Not Named';
   
end
 disp(surf_names);
 name = surf_names;
end

