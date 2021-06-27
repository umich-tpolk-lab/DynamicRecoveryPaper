subjectlist = dir('alffbin/*mind*');
subjectlist = {subjectlist.name};
corrmat = zeros(length(subjectlist),6);
for i=1:length(subjectlist)
    subjectname = char(subjectlist(i));
    subjectname = subjectname(6:13);
    x = load(['alffbin/SD_pd',subjectname,'_alffbin_BfMRIsessiondata.mat']);
    y = load(['sd_datamats_t/SD_pd',subjectname,'_BfMRIsessiondata.mat']);
    [PD,pi,di] = intersect(x.st_coords,y.st_coords,'stable');

    alffpl1 = x.st_datamat(1,pi)';
    alffpl2 = x.st_datamat(2,pi)';
    alffpl3 = x.st_datamat(3,pi)';
    alffdr1 = x.st_datamat(4,pi)';
    alffdr2 = x.st_datamat(5,pi)';
    alffdr3 = x.st_datamat(6,pi)';

    sdpl = y.st_datamat(1,di)';
    sddr = y.st_datamat(2,di)';
    
    corrmat(i,1) = corr(alffpl1,sdpl);
    corrmat(i,2) = corr(alffpl2,sdpl);
    corrmat(i,3) = corr(alffpl3,sdpl);
    corrmat(i,4) = corr(alffdr1,sddr);
    corrmat(i,5) = corr(alffdr2,sddr);
    corrmat(i,6) = corr(alffdr3,sddr);

end
