function S_detrend_nifitLS( DATAPATH, ID, k )
%% Load Detrend and Save a Nifti
%   load nifti and reshap it to voxel x time
%   Input: 
%   - DATAPATH: Folderpath where nifit can be found
%   - ID: subject ID
%   - k : polynominal degree of derending

% 21-10-20


%% MCC
% mcc S_detrend_nifitLS.m -a /home/mpib/wiegert/matlab/toolbox/NIFTI_toolbox -a /home/mpib/wiegert/matlab/toolbox/preprocessing-S -a /home/mpib/wiegert/matlab/toolbox/spm12/

% test if k is a string and make it number
if ischar(k) == 1
    k = str2double(k);
end

    %% get exact file location
    %fname = ([DATAPATH , ID, '.feat/filtered_func_data_restBPF.ica/', ID, '_BPT_ICA_denoised_MNI2mm_flirt']);
    fname = ([DATAPATH, ID, '_BPT_ICA_denoised_MNI2mm_flirt']);

    
    %% load nifti
    % check in datafolder if nifit ends with .nii or .nii.gz and load
    % specific file (x by y by z by time)
    if exist([fname, '.nii.gz'], 'file') == 2
        nii = load_nii ([fname, '.nii.gz']);

    elseif exist([fname, '.nii'], 'file') == 2
        nii = load_nii ([fname, '.nii']);

    else disp ([fname, ' not found!']);
    end

    % 4 here refers to 4th dimension in 4D file....time.
    data = double(reshape(nii.img,[],size(nii.img,4)));
  
    
    
    %% detrend 
    % call detrend function. 2= detrend linear and quadratic. SPM must be 
    % installed. data must be 2D. function flips data and detrend col wise
    % here: time is detrended
    data = S_detrend_data2D(data, k);

    
    % reshape data back to 4D, take dimensions from nifti header
    nii.img = reshape(data,nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4),size(nii.img,4));
        
    
    %% save to new file
    %fname = [DATAPATH , ID, '.feat/final-files/', ID, '_BPT_ICA_denoised_MNI2mm_flirt_detrend.nii'];
    fname = ([DATAPATH, ID, '_BPT_ICA_denoised_MNI2mm_flirt_detrend.nii']);
    save_nii (nii, fname);

    
disp(' ')
disp('save nifit: Done')
    

end

