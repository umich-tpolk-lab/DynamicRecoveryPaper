function [ subjID ] = subjID_nki( DATAPATH, index )
%% subjID_nki Load subjID
%   Detailed explanation goes here

subjects = dir([DATAPATH,'/01*']);      % load all subjects in datafolder
subjID = subjects(index).name(1:7);     % greps subject ID excl. suffix

disp(' ')
disp('loading subject info: Done')

end

