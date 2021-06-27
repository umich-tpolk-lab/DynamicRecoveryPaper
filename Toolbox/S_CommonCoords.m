function [ common_coords ] = S_CommonCoords( DATAPATH, SAVEPATH, IDlist, S )
%Create a matrix of common cordinats of a sample
%   Detailed explanation goes here
%   Input:
%       DATAPATH: ...
%       IDlist: List of subject IDs
%       S = 1 = save coords to DATAPATH
%           0 = do not save coords

% 14-10-20


%% calc binary mask and save file 
% S: Improve list collectio=n... 
% ID = dir('*01*'); 
% subjlist = ID.name; 

%initalize final coords; 1 to 1mio to ensure 1st subjects coords are all
%included
common_coords = (1:1000000);


for i = 1:numel(IDlist);  
   try
    
    %S: add S_load_nii...  
    %load nifti file
    %fname = [DATAPATH , ID{i}, '_BFT_ICA_denoised_MNI2mm_flirt.nii.gz'];
    %fname = [DATAPATH , IDlist{i}, '.feat/filtered_func_data_restBPF.ica/', IDlist{i}, '_BPT_ICA_denoised_MNI2mm_flirt.nii'];
    %fname = [DATAPATH , IDlist{i}, '_BPT_ICA_denoised_MNI2mm_flirt_detrend.nii'];
    fname = [DATAPATH , 'mean_', IDlist{i}, '_NKIrest_BfMRIsessiondata.mat'];
    
    % load nifit from fname, unzip .gz and reshape to 2D
    %[ data ] = S_load_nii_2d( fname );
     
    % load standard coords from PLS file
    load (fname, 'st_coords');
    subj_coords = st_coords;
    
    %resulting a matrix of intersecting coordinats over all subjects
    %subj_coords = find(data(:,1));%takes coords from first volume.
    common_coords=intersect(common_coords,subj_coords);
  
    disp ([IDlist{i}, ': added to common coords'])
  
  
   % Error log    
   catch ME
       warning(['error with subject ', IDlist{i}]);
   end
   
end

%% save
% S parameter activates save
if S ==1

    save ([SAVEPATH, 'commoncordsN112.mat'], 'common_coords');
end

end

