function filterdetrend(subject,datapath,maskpath)
addpath(genpath('/nfs/tpolk/mind/boldvariability/placebo/scripts/toolboxes'));
img = load_untouch_nii ([datapath,'/preproc/', subject, '/FEAT.feat/filtered_func_data.nii.gz']);
nii = double(reshape(img.img, [], img.hdr.dime.dim(5)));

%TR
TR = img.hdr.dime.pixdim(5);

%%load mask
mask = load_untouch_nii (maskpath);
mask = double(reshape(mask.img,  [], mask.hdr.dime.dim(5)));
mask_coords = find(mask);

% mask image
nii_masked = nii(mask_coords,:);

%% Detrend
k = 3;           % linear , quadratic and cubic detrending

% get TS voxel means
nii_means = mean(nii_masked,2);

[ nii_masked ] = S_detrend_data2D( nii_masked, k );
%% readd TS voxel means
for i=1:size(nii_masked,2)
    nii_masked(:,i) = nii_masked(:,i)+nii_means;
end

disp ([subject, ': add mean back done']);

%% filter
% parameters, for detail see help NoiseGenerator.m

LowCutoff = 0.01;
HighCutoff = 0.05;
filtorder = 8;
samplingrate = 1/2;         %in Hz, TR=2s, FS=1/(TR=2)


%parfor_progress(size(nii,1));
for i = 1:size(nii_masked,1)
    
    [B,A] = butter(filtorder,LowCutoff/(samplingrate/2),'high'); 
    nii_masked(i,:)  = filtfilt(B,A,nii_masked(i,:)); clear A B;

    [B,A] = butter(filtorder,HighCutoff/(samplingrate/2),'low');
    nii_masked(i,:)  = filtfilt(B,A,nii_masked(i,:)); clear A B
    

    %parfor_progress;
end

%% readd TS voxel means
for i=1:size(nii_masked,2)
    nii_masked(:,i) = nii_masked(:,i)+nii_means;
end

disp ([subject, ': detrending + bandpass filtering + add mean back done']);

%parfor_progress(0);


%% save file

nii(mask_coords,:)= nii_masked;

img.img = nii;
save_untouch_nii (img, [datapath,'/preproc/',subject, '/', subject,'_detrend_filt.nii.gz'])
disp (['saved as: ',[datapath,'/preproc/', subject, '/', subject,'_detrend_filt.nii.gz']])

end