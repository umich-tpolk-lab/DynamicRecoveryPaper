function [ final_coords ] = S_GMcommonCoords( DATAPATH, SAVEPATH, IDlist, P )
%Create a mask of coordinates consisting out of gray matter coordinates and
%brain coordinats of all subjects in sample
%       DATAPATH: ...
%       IDlist: List of subject IDs
%       P = 2 = apply coords image and save new image to DATAPATH and save final coords
%           1 = save final coords
%           0 = do not save coords
%   MAKE SURE ALL NIFTIs have the same resolution, here 2m is used

% 14-10-20


%DATAPATH = (['/Volumes/DDGLab/NKI_enhanced/preproc+ICA/output_post-bandpassed/', ID, '.feat/filtered_func_data_restBPF.ica/']);
%DATAPATH = (['/home/mpib/wiegert/nki/preproc/output_post-bandpassed/', ID, '.feat/filtered_func_data_restBPF.ica/']);
%DATAPATH = ('/home/mpib/wiegert/nki/preproc/output_post-bandpassed/');


%these commands find a common set of coords across subjects to find masked,
%common coords. We first load the MNI template, already GM masked, and go from
%there. Subject files MUST BE IN MNI space at this point!
%GMmask=load_nii ('/Volumes/DDGLab/Standards/tissuepriors/avg152_T1_gray_mask_90.nii');
GMmask=load_nii ('/home/mpib/wiegert/fsl_standard_images/tissuepriors/avg152_T1_gray_mask_90.nii');

final_coords = (find(GMmask.img))';
 
%h=waitbar(0,'You are on your way to results!');
%the code below  gets final_coords from BOLD files only, but should be
%identical coords to ASL maps.


%% ini common_coords
% if common coords not needed, resp. just GM coords dont use load common
% coords function; 
% 1 to 1mio to ensure 1st subjects coords are all
% included
%common_coords = (1:1000000);



%% load common coords...  
% function loads all subjects and creates a set of common coords, S = 1
% save coords as mat-file to datapath; S=0 do not save just return coords
S=1;
[ common_coords ] = S_CommonCoords( DATAPATH, SAVEPATH, IDlist, S );

%% match common_coords with GM coords

    final_coords=intersect(final_coords,common_coords);

    
    
    
    

%% save GMcommon coords
% P parameter = 1 saves final_coords
if P >=1
    save ([SAVEPATH, 'GMcommoncordsN112.mat'], 'final_coords');
end
    




%% calc binary mask and save file 
% P parameter activates apply coords to single subject and save
if P ==2

        
        %j=waitbar(0,'You are on your way to results!');

    matlabpool open

    parfor i = 1:numel(IDlist)
        try


        %S: add S_load_nii...  
        %load to be changed nifti
        %fname = [DATAPATH , ID{i}, '_BFT_ICA_denoised_MNI2mm_flirt.nii.gz'];
        fname = [DATAPATH , IDlist{i}, '.feat/filtered_func_data_restBPF.ica/', IDlist{i}, '_BPT_ICA_denoised_MNI2mm_flirt.nii'];

        nii = load_nii(fname); %(x by y by z by time)

        %create a coordinate box to match with final_coords
        %databox = ones(45,54,45); % 4mm
        databox = ones(nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4));    % loads dynamicly dimentions from nifti header; make sure GM reslution fits
        databox_coords = find(databox);

        binary_mask=ismember(databox_coords,final_coords);
        binary_mask_rep=repmat(binary_mask,1,size(nii.img,4));

        % reshape to 4d
        binary_mask_rep = reshape(binary_mask_rep,nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4),size(nii.img,4));


        nii.img=nii.img.*binary_mask_rep;

        %waitbar(i/numel(ID),j);

        %% save under new name

            %fname = [DATAPATH , ID{i}, '_BFT_ICA_denoised_MNI2mm_flirt.nii.gz']
            fname = [DATAPATH , IDlist{i}, '.feat/filtered_func_data_restBPF.ica/', IDlist{i}, '_BPT_ICA_denoised_MNI2mm_flirt.nii'];
            save_nii (nii, fname);

            disp ([IDlist{i}, ' processed'])
        



        catch ME
           warning(['error with subject ', IDlist{i}]);


        end % end try

    end % end parfor


matlabpool close

end % P parameter
end

