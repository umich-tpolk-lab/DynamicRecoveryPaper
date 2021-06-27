sublist = dir('*mind*_coords*');
sublist = {sublist.name};
for sn = 1:length(sublist)
    subjectname = char(sublist(sn));
    subjectname = subjectname(1:9);
    commoncoord_meanbold(subjectname)
end


function commoncoord_meanbold(subject)

%% Load common set of coordiants
load ([subject,'_coords_EVAL.mat'], 'final_coords');

%this loads a subject's sessiondata file.
a = load(['mean_', subject, '_BfMRIsessiondata.mat']);

%replace fields with correct info.
a.session_info.datamat_prefix= (['mean_commoncoord_' subject]);
[~,fidx] = intersect(a.st_coords,final_coords);
a.st_coords = final_coords;
a.st_datamat =  a.st_datamat(:,fidx);

% save data
save(['mean_', subject, '_BfMRIsessiondata.mat'],'-struct','a','-mat');
disp ([subject ' done!'])
clear a
end