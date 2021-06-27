subjectlist = dir('alffbin_drug/*mind*');
subjectlist = {subjectlist.name};
for i=1:length(subjectlist)
    subjectname = char(subjectlist(i));
    subjectname = subjectname(5:12);
    p = load(['alffbin_placebo/SD_p',subjectname,'_alffbin_BfMRIsessiondata.mat']);
    d = load(['alffbin_drug/SD_d',subjectname,'_alffbin_BfMRIsessiondata.mat']);
    [PD,pi,di] = intersect(p.st_coords,d.st_coords,'stable');
    PDstruct = p;
    PDstruct.st_coords = PD;
    condpl1 = p.st_datamat(1,pi);
    condpl2 = p.st_datamat(2,pi);
    condpl3 = p.st_datamat(3,pi);

    conddr1 = d.st_datamat(1,di);
    conddr2 = d.st_datamat(2,di);
    conddr3 = d.st_datamat(3,di);
    
    PDstruct.st_datamat = zeros(6,length(pi));
    PDstruct.st_datamat(1,:) = condpl1;
    PDstruct.st_datamat(2,:) = condpl2;
    PDstruct.st_datamat(3,:) = condpl3;

    PDstruct.st_datamat(4,:) = conddr1;
    PDstruct.st_datamat(5,:) = conddr2;
    PDstruct.st_datamat(6,:) = conddr3;

    PDstruct.session_info.condition{1} = 'LowBin_Placebo';
    PDstruct.session_info.condition{2} = 'MidBin_Placebo';
    PDstruct.session_info.condition{3} = 'HighBin_Placebo';

    PDstruct.session_info.condition{4} = 'LowBin_Drug';
    PDstruct.session_info.condition{5} = 'MidBin_Drug';
    PDstruct.session_info.condition{6} = 'HighBin_Drug';

    
    PDstruct.session_info.condition0 = PDstruct.session_info.condition;
    PDstruct.session_info.condition_baseline{3} = [0,1];
    PDstruct.session_info.condition_baseline{4} = [0,1];
    PDstruct.session_info.condition_baseline{5} = [0,1];
    PDstruct.session_info.condition_baseline{6} = [0,1];

    PDstruct.session_info.condition_baseline0 = PDstruct.session_info.condition_baseline;
    PDstruct.num_subj_cond = [1,1,1,1,1,1];
    PDstruct.st_evt_list = [1,2,3,4,5,6];
    PDstruct.session_info.num_conditions =6;
    PDstruct.session_info.num_conditions0 =6;
    PDstruct.session_info.datamat_prefix = ['SD_pd',subjectname,'_alffbin'];
    save(['alffbin/SD_pd',subjectname,'_alffbin_BfMRIsessiondata.mat'],'-struct','PDstruct')
end
