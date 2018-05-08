%Scripts to convert multiple subjects' electrode coordinates to standard
%space coordinates and automatically allocate nearest network names to
%electrodes on group level, not single subjects. This script works
%with the elec2Parc_lin function. 
%Written by Lin Shi from LBCN, Stanford University.
%email: shilin18@stanford.edu, shilin2015@foxmail.com.
close ALL; clc; clear;
global globalFsDir;
globalFsDir =   '      ';%input your SUBJECT_DIR folder
subs  ={'Pt01'};%input subjects folder names
groupAvgCoords=[];
groupLabels=[];
groupIsLeft=[];
cfg=[];
cfg.rmDepths=1;
%convert the coordinates of electrodes to standard space
for a=1:length(subs),
    fprintf('Working on Participant %s\n',subs{a});
    [avgCoords, elecNames, isLeft]=sub2AvgBrain(subs{a},cfg);
    groupAvgCoords=[groupAvgCoords; avgCoords];
    groupLabels=[groupLabels; elecNames];
    groupIsLeft=[groupIsLeft; isLeft];
end
% make all electrodes appear in left
groupAvgCoords(:, 1) = -1*abs(groupAvgCoords(:, 1)); 

%read Network labels you want to plot with
[averts, label, col]=read_annotation(fullfile(getFsurfSubDir(),'fsaverage','label','lh.Yeo2011_7Networks_N1000.annot'));

%make colortable array. 
network_labels={''; 'Visual';'Somatomotor';'Dorsal Attention';'Ventral Attention';'Limbic';'Frontoparietal';'Default'};
for id = 2:8;
col.table(1,1:3) = [0 0 0]; % Subcortical Mask = BLACK
col.table(2,1:3) = [111 54 166]; % Visual Network = PURPLE
col.table(3,1:3) = [0 170 14]; % Somatomotor Network = GREEN
col.table(4,1:3) = [214 158 26]; % Dorsal Attention Network = ORANGE 
col.table(5,1:3) = [247 255 5]; % Ventral Attention Network = ELECTRIC YELLOW
col.table(6,1:3) = [255 255 235]; % Limbic Network = CREAM
col.table(7,1:3) = [232,63,51]; % Frontoparietal Network = RED
col.table(8,1:3) = [124,185,232]; % Default Network = BLUE

parc_col = .7.*255.*ones(size(col.table(:,1:3)));
parc_col(id,:)=col.table(id,1:3);

createIndivYeoMapping('fsaverage');%this line can be commented after first run
elec_colors_f = [];
elec_colors = {};
%find nearest pial surface for each electrode contact
parcOut=elec2Parc_Lin([],'Y7',  groupLabels, groupAvgCoords);
elec_val = strcmp(parcOut(:, 2), network_labels{id});
   for j = 1: length(elec_val)
       if elec_val(j)
           elec_colors{j} =[0, 0, 0];
       else
           elec_colors{j} = [255, 255, 255]./255;
       end
   end
   elec_colors_f = cell2mat([elec_colors_f ; elec_colors]);
%plot on the pial surface
cfg=[];
cfg.view='lomni';
cfg.elecSize = 3;
cfg.elecShape = 'marker';
cfg.overlayParcellation='         '; %input your parcellation annotate absolute path here
cfg.pullOut = 1; 
cfg.elecCoord=[groupAvgCoords ones(length(groupAvgCoords), 1)];
cfg.parcellationColors = parc_col;
cfg.elecColors = elec_colors_f;
cfg.elecNames=groupLabels;
cfg.showLabels='n';
cfg.surfType = 'pial';
cfg.title = 'ECoG and SEEG electrodes Manifestation from LBCN';
cfgOut=plotPialSurf('fsaverage',cfg);
end
