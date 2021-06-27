function S_save_nii_4d( fname, data, ID )
%% Save nifti NKI
%   reshap it to 4d and save nifti 
%   Input: 
%   fame: Folderpath and name nifit has to be saved, with or without
%   suffix


% 28-10-20

   
    % check if nifit is present and suffix. if zipped unzip
    if exist(fname, 'file') >= 1
        
        if strfind (fname, '.nii.gz') >= 1
        
        disp (['unzipping ', fname]);
        system (['gunzip ', fname]);
        
        fname = fname(1:end-3);  % remove '.gz' in string
        
        disp (['loading ', fname]);
        nii = load_nii (fname);

%         disp (['zipping ', fname]);
%         system (['gzip ', fname]);
        
        
        else disp (['loading ', fname]);
             nii = load_nii (fname);
              
        end  

    else disp ([fname, ' not found!']);
    end


        % reshape to 4d
        nii.img = reshape(data,nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4),size(nii.img,4));

        % save nifit
        
          fnameN = (['/Users/ramirez/Desktop/', ID, '.nii']);
          save_nii (nii,fnameN)
    
        
disp('save nifit: Done')
disp(' ')    

end

