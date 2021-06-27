function [ data ] = S_load_nii_2d( fname )
%% Load nifti NKI
%   load nifti and reshap it to voxel x time
%   Input: 
%   fame: Folderpath and name nifit can be found, with or without
%   suffix
%   Output: NIFTI structure reshaped to 2D (voxel x time)

% 28-10-20

   
    % check if nifit matches filename
    if exist(fname, 'file') >= 1
        
        %if filenname contains .gz unzip
        if strfind (fname, '.nii.gz') >= 1
        
        disp (['unzipping ', fname]);
        system (['gunzip ', fname]);
        
        %change filename
        fname = fname(1:end-3);  % remove '.gz' in string
        
        disp (['loading ', fname]);
        nii = load_nii (fname);

        disp (['zipping ', fname]);
        system (['gzip ', fname]);
        
        % if filename does not contain .gz load directly
        else disp (['loading ', fname]);
             nii = load_nii (fname);
              
        end  

    %if filename does not match, check if .gz suffix works
    elseif exist([fname, '.gz'], 'file') >= 1
            
            disp (['unzipping ', fname]);
            system (['gunzip ', fname]);        
       
            disp (['loading ', fname]);
            nii = load_nii (fname(1:end-3));

            disp (['zipping ', fname]);
            system (['gzip ', fname]);
    
    elseif exist (fname(1:end-3), 'file') >= 1
            
            disp (['loading ', fname(1:end-3)]);
            nii = load_nii (fname(1:end-3));
        
    % if nothing works or file is not present
    else disp ([fname, ' not found!']);
    end


    % reshape to 2D. 4 refers to 4th dimension in 4D file....time.
    data = reshape(nii.img,[],size(nii.img,4));
  
    
    
disp('...done')
disp(' ')    

end