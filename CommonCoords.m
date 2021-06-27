function CommonCoords(Subject,NIIfname,taskname)

%% Basic coordinate size for nifti file
nii_coords= 1:91*109*91 ; % 2mm

%% Find coordiantes of gray matter mask
GM_coords = load_nii('/nfs/tpolk/mind/boldvariability/placebo/scripts/avg152_T1_gray_mask_90_2mm.nii');
GM_coords = reshape(GM_coords.img, [],1);
GM_coords = find(GM_coords);

%% Find Common Coordiantes for all subjects/runs

coords=load_nii(NIIfname); 
coords=reshape(coords.img,[],coords.hdr.dime.dim(5));
coords(isnan(coords))=0; % Necessary to avoid NaNs, which cause problems for PLS analysis
coords = find(coords(:,1));
nii_coords=intersect(nii_coords,coords);
clear coords
final_coords = intersect (nii_coords, GM_coords);

%% Export coordinates
save (['/nfs/tpolk/mind/boldvariability/placebo/',taskname,'/pls/' Subject '_coords_EVAL.mat'] ,'nii_coords', 'final_coords', 'GM_coords');

end
