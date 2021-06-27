function [ data ] = S_appl_st_coords( data )
%get and apply standard coordinates (non-zero values) from 2d matrix.
%coords from first column. Apply those coords to data (all other columns)
%   Detailed explanation goes here

disp('applying coords...'); 

data = reshape(data(find(data)),[],size(data,2));

disp('...done');
disp (' ');

end
