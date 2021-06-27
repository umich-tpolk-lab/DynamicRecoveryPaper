SHELL := /bin/bash

# Note that the symbolic links to this makefile are in /nfs/tpolk/mind/freesurfer/func/?mind????
# It will normally be called recursively from the makefile in the func directory above it

# Make sure the Freesurfer subjects directory is set correctly
task=rest
export SUBJECTS_DIR=/nfs/tpolk/mind/freesurfer
DATAPATH=/nfs/tpolk/mind/boldvariability/placebo/${task}
SRCPATH=/nfs/tpolk/mind/boldvariability/placebo
# get subject id from the path
subject=$(shell pwd|egrep -o '[dp]mind[oy][0-9][0-9][0-9]')
stripsubject=$(shell pwd|egrep -o 'mind[oy][0-9][0-9][0-9]')
#Set all the variables
new_location=${DATAPATH}/preproc/${subject}/${subject}_detrend_filt_denoised_2mm.nii
Input=${DATAPATH}/preproc/${subject}/${subject}_detrend_filt.nii.gz
Output=${DATAPATH}/preproc/${subject}/${subject}_detrend_filt_denoised.nii.gz
Melodic=${DATAPATH}/preproc/${subject}/ICA.ica/melodic_mix
Rejected=$(shell cat ${DATAPATH}/preproc/${subject}/${subject}_rejected.txt)
FuncPath=${DATAPATH}/preproc/${subject}
FuncImage=${subject}_detrend_filt_denoised
Preproc=${FuncPath}/${FuncImage}.nii.gz
Registered=${FuncPath}/${FuncImage}_2mm.nii.gz
BET=${FuncPath}/anat/${subject}_brain.nii.gz
MNI=${SRCPATH}/scripts/MNIs/MNI152_T1_2mm_brain.nii.gz
Preproc_to_BET=${FuncPath}/reg/${FuncImage}_preproc_to_BET.mat
BET_to_MNI=${FuncPath}/reg/${FuncImage}_BET_to_MNI.mat
Preproc_to_MNI=${FuncPath}/reg/${FuncImage}_preproc_to_MNI.mat

#Set all the targets phony and otherwise
.PHONY: all 

all: prepauto prepmanual preppls

.PHONY: prepauto prepmanual

prepauto: prepfeat feat mask filterdetrend ICA

prepmanual: denoise registration

.PHONY: prepfeat feat mask filterdetrend ICA denoise registration

prepfeat:${DATAPATH}/designfiles/design_${subject}_${task}.fsf

${DATAPATH}/designfiles/design_${subject}_${task}.fsf: ${SRCPATH}/scripts/design_template_rest.fsf
	cp  $< ${DATAPATH}/designfiles/design_${subject}_${task}.fsf;\
	sed 's/id_dummy/${subject}/g' -i ${DATAPATH}/designfiles/design_${subject}_${task}.fsf;\
	sed 's/id_dummy/${subject}/g' -i ${DATAPATH}/designfiles/design_${subject}_${task}.fsf;\
	sed 's#DATAPATH_dummy#${SRCPATH}#g' -i ${DATAPATH}/designfiles/design_${subject}_${task}.fsf;\

feat:${DATAPATH}/preproc/${subject}/FEAT.feat/filtered_func_data.nii.gz

${DATAPATH}/preproc/${subject}/FEAT.feat/filtered_func_data.nii.gz: ${DATAPATH}/designfiles/design_${subject}_${task}.fsf
	feat $<;\

mask: ${DATAPATH}/preproc/${subject}/FEAT.feat/filtered_func_data_mask.nii.gz

${DATAPATH}/preproc/${subject}/FEAT.feat/filtered_func_data_mask.nii.gz: ${DATAPATH}/preproc/${subject}/FEAT.feat/filtered_func_data.nii.gz
	cd ${DATAPATH}/preproc/${subject}/FEAT.feat;\
	mkdir tmp;\
	fslsplit filtered_func_data tmp/filtered_func_data;\
	fslmaths tmp/filtered_func_data0001 -bin filtered_func_data_mask;\
    	rm -fr tmp ;\

filterdetrend: ${DATAPATH}/preproc/${subject}/${subject}_detrend_filt.nii.gz

${DATAPATH}/preproc/${subject}/${subject}_detrend_filt.nii.gz: ${DATAPATH}/preproc/${subject}/FEAT.feat/filtered_func_data_mask.nii.gz
	matlab -nosplash -nodesktop -r "try, filterdetrend('${subject}','${DATAPATH}','$<'), catch, 'Error running filterdetrend', end; exit" ;\

ICA: ICA.ica

ICA.ica: ${DATAPATH}/preproc/${subject}/${subject}_detrend_filt.nii.gz
	flirt -in  ${DATAPATH}/preproc/${subject}/anat/${subject}_brain.nii.gz -ref ${subject}_detrend_filt.nii.gz -out anat2func ;\
	melodic -i ${subject}_detrend_filt.nii.gz -o ICA.ica --dimest=mdl -v --nobet --bgthreshold=3 --tr=2 --report --guireport=/FEAT.feat/report.html -d 0 --mmthresh=0.5 --Ostats --bgimage=anat2func.nii.gz ;\
	touch ${DATAPATH}/preproc/${subject}/${subject}_rejected.txt
	

denoise:${DATAPATH}/preproc/${subject}/${subject}_detrend_filt_denoised.nii.gz 
${DATAPATH}/preproc/${subject}/${subject}_detrend_filt_denoised.nii.gz : ${DATAPATH}/preproc/${subject}/${subject}_rejected.txt	
	fsl_regfilt -i ${Input} -o ${Output} -d ${Melodic} -f ${Rejected} ;\


registration:${DATAPATH}/preproc/${subject}/preprocess
${DATAPATH}/preproc/${subject}/preprocess: ${DATAPATH}/preproc/${subject}/${subject}_detrend_filt_denoised.nii.gz 
	mkdir ${DATAPATH}/preproc/${subject}/reg;\
	cd ${DATAPATH}/preproc/${subject}/reg;\
	flirt -in ${Preproc} -ref ${BET} -omat ${Preproc_to_BET};\
	flirt -in ${BET} -ref ${MNI} -omat ${BET_to_MNI};\
	convert_xfm -omat ${Preproc_to_MNI} -concat ${BET_to_MNI} ${Preproc_to_BET};\
	flirt -in ${Preproc} -ref ${MNI} -out ${Registered} -applyxfm -init ${Preproc_to_MNI};\
	touch ${DATAPATH}/preproc/${subject}/preprocess

.PHONY:preppls
preppls: batchfile makemean commoncoords makesd applycommoncord

.PHONY: batchfile makemean commoncoords makesd applycommoncord

batchfile:${DATAPATH}/pls/mean_datamats/${subject}_${task}_meanbold_batch.txt;
${DATAPATH}/pls/mean_datamats/${subject}_${task}_meanbold_batch.txt: ${DATAPATH}/preproc/${subject}/preprocess
	cp ${SRCPATH}/scripts/make_batch_template_rest.txt $@ ;\
	sed 's/dummyID/${subject}/g' -i $@ ;\
	sed 's#dummy_location#${new_location}#g' -i $@ ;\
	gunzip ${DATAPATH}/preproc/${subject}/${subject}_detrend_filt_denoised_2mm.nii.gz ;\

makemean:${DATAPATH}/pls/mean_datamats/mean_${subject}_BfMRIsessiondata.mat
${DATAPATH}/pls/mean_datamats/mean_${subject}_BfMRIsessiondata.mat: ${DATAPATH}/pls/mean_datamats/${subject}_${task}_meanbold_batch.txt
	matlab -nosplash -nodesktop -r "try, make_meanbold_datamat('${DATAPATH}/pls/mean_datamats', '$<'), catch, 'Error making meanbold datamat', end; exit" ;\

commoncoords: ${DATAPATH}/pls/${subject}_coords_EVAL.mat
${DATAPATH}/pls/${subject}_coords_EVAL.mat: ${DATAPATH}/pls/mean_datamats/mean_${subject}_BfMRIsessiondata.mat
	matlab -nosplash -nodesktop -r "try, CommonCoords('${subject}', '${DATAPATH}/preproc/${subject}/${subject}_detrend_filt_denoised_2mm.nii','${task}'), catch, 'Error evaluating coords', end; exit" ;\

makesd:${DATAPATH}/pls/sd_datamats/SD_${subject}_BfMRIsessiondata.mat
${DATAPATH}/pls/sd_datamats/SD_${subject}_BfMRIsessiondata.mat: ${DATAPATH}/pls/${subject}_coords_EVAL.mat
	matlab -nosplash -nodesktop -r "try, make_sdbold_datamat('${subject}','${DATAPATH}', '${DATAPATH}/pls/mean_datamats/mean_${subject}_BfMRIsessiondata.mat'), catch, 'Error making sdbold datamat', end; exit"		

		
print-%  : ; @echo $* = $($*)
