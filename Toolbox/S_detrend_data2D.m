function [ data ] = S_detrend_data2D( data, k )
%% detrend_nki Summary of this function goes here
%  funtion spm_detrend(X, n) removes a nonlinear trend from array X.
%  k is the order of nonlinear trend. 2 quadratic, 3 cubic, 4 ... 
%  If X is an matrix DETRENDING will be performed column-whise. Therefore 
%  the matrix has to be transposed, to remove trend of timeseries for each
%  voxel.
%
%  Input:
%  - data: 2D matrix from NIFTI (voxel x time)
%  - k:    Order of detrending:  1. linear 2. quadratic 3. cubic 4. quartic
%  Output:
%  - data: detrended 2D matrix (if form NIFTI, voxel x time)

% 14-10-20


%  SPM toolbox must be installed!!


%transpose matrix: now colums is time and row is voxel
data = data';

% detrend in serveral steps. 1. linear 2. quadratic 3. cubic 4. quartic

for i=1:k
    data=spm_detrend(data,i);
end

%retranspose matrix
data = data';

disp(' ')
disp('detrending: Done')




end


