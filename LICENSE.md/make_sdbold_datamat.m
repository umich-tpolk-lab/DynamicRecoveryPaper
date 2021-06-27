function make_sdbold_datamat(subject,basepath,matpath)
%% 2nd pre-step for PLS.
% fill matrix with standard deviations for various condtions, runs and blocks
    %% Load common set of coordiants
load ([basepath,'/pls/' subject,'_coords_EVAL.mat'], 'final_coords');
    
    %% SDBOLD Calculation
    %And now the real work begins to create the SDBOLD datamats :-)
    
    %this command produces a waitbar to check on progress of datamat creation
    %for all files. Waitbar is then called within the loop.
    %h=waitbar(0,'You are on your way to results!');

    %this loads a subject's sessiondata file.
    a = load(matpath);

    % conditions in original mean-BOLD PLS file
    conditions = a.session_info.condition;
    % We will replace these respectively with the SD-BOLD datamats and the common coords
    a = rmfield(a,'st_datamat');
    a = rmfield(a,'st_coords');
    
    %replace fields with correct info.
    a.session_info.datamat_prefix= (['SD_' subject]);
    a.st_coords = final_coords;
    
    % initialize this subject's datamat
    a.st_datamat = zeros(numel(conditions),numel(final_coords)); %(cond voxel)
    
    % intialize cond specific scan count for populating cond_data
    clear count cond_data block_scan;
    for cond = 1:numel(conditions)
        count{cond} = 0;
    end
    
    %% Only necessary if changing condition info
    %       a.session_info.condition=condition;
    %       a.session_info.condition0=condition;
    %       a.session_info.num_conditions=length(condition);
    %
    %       for k=1:length(condition)
    %       a.session_info.condition_baseline0{1, k}=[-1, 1];
    %       a.session_info.condition_baseline{1, k}=[-1, 1];
    %       end
    
    %% Header
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % within each block express each scan as deviation from block's
    % temporal mean.Concatenate all these deviation values into one
    % long condition specific set of scans that were normalized for
    % block-to-block differences in signal strength. In the end calculate
    % stdev across all normalized cond scans
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % for each condition identify its scans within  runs
    % and prepare where to put cond specific normalized data
    for cond = 1:numel(conditions)
        tot_num_scans = 0;
        for run = 1:a.session_info.num_runs
            onsets = a.session_info.run(run).blk_onsets{cond}+1; % +1 is because we need matlab indexing convention (damain)
            lengths = a.session_info.run(run).blk_length{cond};
            for block = 1:numel(onsets)
                block_scans{cond}{run}{block} = onsets(block)-1+[1:lengths(block)];
                this_length = lengths(block);
                if max(block_scans{cond}{run}{block}>a.session_info.run(run).num_scans)
                    disp(['bljak ' subject ' something wrong in block onset lengths']);
                    block_scans{cond}{run}{block} = intersect(block_scans{cond}{run}{block},[1:a.session_info.run(run).num_scans]);
                    this_length = numel(block_scans{cond}{run}{block});
                end
                tot_num_scans = tot_num_scans + this_length;
            end
        end
        % create empty matrix with dimensions coords (rows) by total # of scans (columns).
        cond_data{cond} = zeros(numel(final_coords),tot_num_scans);
    end
    
    
    %% Load NIfTI file
    % Depending on working on grid or local. File location saved in
    % session.info. if it is wrong, use NIIPATH
    
    for i = 1:a.session_info.num_runs
        strcmp(basepath,a.session_info.run(i).data_path(1:10)) == 1;
        fname = [a.session_info.run(i).data_path '/' a.session_info.run(i).data_files{1}];
        
        
        % load nifti file for this run; %(x by y by z by time)
        % check for nii or nii.gz, unzip .gz and reshape to 2D
        
        [ img ] = double(S_load_nii_2d( fname ));
        img = img(final_coords,:);%this command constrains the img file to only use final_coords, which is common across subjects.
        clear nii
        
%         %If preprocessing_tools are unavailable
%         nii = load_nii(fname); %(x by y by z by time)
%         img = double(reshape(nii.img,[],size(nii.img,4)));% 4 here refers to 4th dimension in 4D file....time.
%         img = img(final_coords,:);%this command constrains the img file to only use final_coords, which is common across subjects.
%         clear nii
        
        %% Unused/Deprecated
        %         %now regress out motion parameters for this run. If decide to
        %         %regress CSF and WM time series in the future, do it here by loading .txt files with that info.
        %         %temporal_mean = mean(img,2);%calculate mean for each voxel across all TRs (used in residualization step below).
        %         %mp_ts=load(['/Volumes/damain2/MRI/Data/DA_main/n-back/preproc+first_2010/nback_final/MC/prefiltered_func_data_mcf_',subj(1:8),'_run',num2str(run),'.txt']);%load motion params. The subj(1:8) command shrinks the subj string variable to locate MP files correctly.
        %         %img = residualize([mp_ts],img')' + repmat(temporal_mean,[1 size(img,2)]);%use Randy's "residualize" function to regress using matrices instead of vectors.
        %         %%repmat of the temp mean is needed here to put data back in original "zone" after residualization, rather than zero centred.
        %         clear nii;
        
        
        % Detrend
        % call detrend func: centering and detrending 1,2,3,4-dimension
        % input must be voxel x time and intenger defining trend
        % (addpath: /matlab/toolbox/preprocessing-S)
        %img = S_detrend_data2D(img,4);
        
        
        % Increase intensity
        % add 10000 to voxel value to assure overall positive values
        % img=img+10000;
        
        
        %% Now, proceed with creating SD datamat...
        
        for cond = 1:numel(conditions)
            for block = 1:numel(block_scans{cond}{run})
                block_data = img(:,block_scans{cond}{run}{block});% (vox time)
                
                %detrending 1,2,3,4-dimension (addpath: /nki/neuronal_avalanche-scripts)
                %block_data=detrend_nki(block_data);
                
                % normalize block_data to global block mean = 100.
                block_data = 100*block_data/mean(mean(block_data));
                % temporal mean of this block
                block_mean = mean(block_data,2); % (vox) - this should be 100
                % express scans in this block as  deviations from block_mean
                % and append to cond_data
                good_vox = find(block_mean);
                for t = 1:size(block_data,2)
                    count{cond} = count{cond} + 1;
                    cond_data{cond}(good_vox,count{cond}) = block_data(good_vox,t) - block_mean(good_vox);%must decide about perc change option here!!??
                end
            end
        end
    end
    
    %% Get standard deviation from img
    
    % now calculate stdev across all cond scans.
    for cond = 1:numel(conditions)
        a.st_datamat(cond,:) = squeeze(std(cond_data{cond},0,2))';
    end
    
    %all values get saved in the datamat below; nothing should need to be
    %saved to session files at this point, so leave those as is.
    clear img;
    
    %waitbar(i/numel(ID),h);
    %% Save SD datamat
    
    save([basepath, '/pls/sd_datamats/SD_' subject, '_BfMRIsessiondata.mat'],'-struct','a','-mat');
    disp('Done')
end
