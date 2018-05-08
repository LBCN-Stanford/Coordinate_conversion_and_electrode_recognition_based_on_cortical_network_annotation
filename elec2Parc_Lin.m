function elecParc=elec2Parc_Lin(subj,atlas, groupLabels, groupAvgCoords)
%Scripts to convert multiple subjects' electrode coordinates to standard
%space coordinates and automatically allocate nearest network names to
%electrodes on group level, not single subjects. This script works
%with the groupsub2std. file.  
%Written by Lin Shi from LBCN, Stanford University.
%email: shilin18@stanford.edu, shilin2015@foxmail.com.

subj = 'fsaverage';
fsDir=getFsurfSubDir();
surfaceFolder=fullfile(fsDir,subj,'surf');
labelFolder=fullfile(fsDir,subj,'label');
nElec = length(groupLabels);
pialCoord = groupAvgCoords;
mriFname=fullfile(fsDir,subj,'mri','brainmask.mgz');
if ~exist(mriFname,'file')
   error('File %s not found.',mriFname); 
end
mri=MRIread(mriFname);
sVol=size(mri.vol);
VOX2RAS=[-1 0 0 128; 0 0 -1 128; 0 -1 0 128; 0 0 0 1];
RAS2VOX=inv(VOX2RAS);
pvoxCoord=(RAS2VOX*[pialCoord'; ones(1, nElec)])';
pvoxCoord=round(pvoxCoord+1);
pvoxCoord(:,[1 2])=pvoxCoord(:,[2 1]);
pvoxCoord(:,3)=sVol(3)-pvoxCoord(:,3);
elecLabels=groupLabels;
elecParc=cell(nElec,2);
elecIdsThisHem=elecLabels;
nElecThisHem=length(elecIdsThisHem);
    if nElecThisHem,
        surfFname=fullfile(surfaceFolder,'lh.pial');
        [cort.vert, cort.tri]=read_surf(surfFname);
        nVertex=length(cort.vert);
       if exist(atlas,'file')
            [~, label, colortable]=read_annotation(atlas);
        else
            switch upper(atlas)
                case 'DK'
                    parcFname=fullfile(labelFolder,'lh.aparc.annot');
                    [~, label, colortable]=read_annotation(parcFname);
                case 'D'
                    parcFname=fullfile(labelFolder,'lh.aparc.a2009s.annot');
                    [~, label, colortable]=read_annotation(parcFname);
                case 'Y7'
                    parcFname=fullfile(labelFolder, 'lh_Yeo2011_7Networks_N1000.mat');
                    load(parcFname);
                case 'Y17'
                    parcFname=fullfile(labelFolder,'lh_Yeo2011_17Networks_N1000.mat');
                    load(parcFname);
                otherwise
                    error('Unrecognized value of atlas argument.')
            end
        end   
        for elecLoop=1:nElecThisHem,
            elecParc{elecLoop,1}=elecLabels{elecLoop,1};
                [~, minId]=min(sum( (repmat(pialCoord(elecLoop,:),nVertex,1)-cort.vert).^2,2 ));
                switch label(minId),
                    case 0,
                        elecParc{elecLoop,2}='unknown';
                    otherwise
                        elecParc{elecLoop,2}=colortable.struct_names{find(colortable.table(:,5)==label(minId))};
                end
            end
    end
    end
