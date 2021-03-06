function bold_profiles_surf_grp_avg
clc; clear;

StartDir = fullfile(pwd, '..','..', '..');
addpath(genpath(fullfile(StartDir, 'AVT-7T-code','subfun')))
Get_dependencies('D:\Dropbox/')

ResultsDir = fullfile(StartDir, 'results', 'profiles', 'surf');
[~,~,~] = mkdir(ResultsDir);

cd(StartDir)
SubLs = dir('sub*');
NbSub = numel(SubLs);

addpath(genpath(fullfile(StartDir, 'code', 'subfun')))

NbLayers = 6;

CondNames = {...
    'AStimL','AStimR';...
    'VStimL','VStimR';...
    'TStimL','TStimR';...
    %         'ATargL','ATargR';...
    %         'VTargL','VTargR';...
    %         'TTargL','TTargR';...
    };


ROIs= {...
    'A1',...
    'PT'
    'V1',...
    'V2',...
    };

DesMat = (1:NbLayers)-mean(1:NbLayers);
DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
% DesMat = [DesMat' ones(NbLayers,1)];
DesMat = spm_orth(DesMat);


for iROI = 1:4 %length(ROIs)
    AllSubjects_Data(iROI) = struct(...
        'name', ROIs{iROI}); %#ok<*AGROW>
end

Median = 1;


%% Gets data for each subject
for iSub = 1:NbSub
    
    
    SubDir = fullfile(StartDir, SubLs(iSub).name);
    SaveDir = fullfile(SubDir, 'results', 'profiles', 'surf');
    
    for iROI=1:4 %numel(ROIs)
        
        File2Load = fullfile(SaveDir, strcat('Data_Surf_', AllSubjects_Data(iROI).name, '_l-', ...
            num2str(NbLayers), '.mat'));
        
        if exist(File2Load,'file')
            
            load(File2Load, 'Data_ROI')
            
            if Median
                
                % layers
                AllSubjects_Data(iROI).Ispi.DATA{iSub} = Data_ROI.Ispi.LayerMedian;
                AllSubjects_Data(iROI).Ispi.grp(:,:,iSub,:) = squeeze(nanmean(Data_ROI.Ispi.LayerMedian,2));
                
                AllSubjects_Data(iROI).Contra.DATA{iSub} = Data_ROI.Contra.LayerMedian;
                AllSubjects_Data(iROI).Contra.grp(:,:,iSub,:) = squeeze(nanmean(Data_ROI.Contra.LayerMedian,2));
                
                AllSubjects_Data(iROI).Contra_VS_Ipsi.DATA{iSub} = Data_ROI.Contra_VS_Ipsi.LayerMedian;
                AllSubjects_Data(iROI).Contra_VS_Ipsi.grp(:,:,iSub,:) = squeeze(nanmean(Data_ROI.Contra_VS_Ipsi.LayerMedian,2));
                
                AllSubjects_Data(iROI).ContSensModIpsi.DATA{iSub} = Data_ROI.ContSensModIpsi.LayerMedian;
                AllSubjects_Data(iROI).ContSensModIpsi.grp(:,:,iSub,:) = squeeze(nanmean(Data_ROI.ContSensModIpsi.LayerMedian,2));
                
                AllSubjects_Data(iROI).ContSensModContra.DATA{iSub} = Data_ROI.ContSensModContra.LayerMedian;
                AllSubjects_Data(iROI).ContSensModContra.grp(:,:,iSub,:) = squeeze(nanmean(Data_ROI.ContSensModContra.LayerMedian,2));
                
                
                % whole roi
                AllSubjects_Data(iROI).Ispi.whole_roi_grp(iSub,:,:) = nanmean(Data_ROI.Ispi.WholeROI.MEDIAN);
                AllSubjects_Data(iROI).Contra.whole_roi_grp(iSub,:,:) = nanmean(Data_ROI.Contra.WholeROI.MEAN);
                AllSubjects_Data(iROI).Contra_VS_Ipsi.whole_roi_grp(iSub,:,:) = nanmean(Data_ROI.Contra_VS_Ipsi.WholeROI.MEDIAN);
                AllSubjects_Data(iROI).ContSensModIpsi.whole_roi_grp(iSub,:,:) = nanmean(Data_ROI.ContSensModIpsi.WholeROI.MEDIAN);
                AllSubjects_Data(iROI).ContSensModContra.whole_roi_grp(iSub,:,:) = nanmean(Data_ROI.ContSensModContra.WholeROI.MEDIAN);
                
            else
                
                % layers
                AllSubjects_Data(iROI).Ispi.DATA{iSub} = Data_ROI.Ispi.LayerMean;
                AllSubjects_Data(iROI).Ispi.grp(:,:,iSub,:) = squeeze(nanmean(Data_ROI.Ispi.LayerMean,2));
                
                AllSubjects_Data(iROI).Contra.DATA{iSub} = Data_ROI.Contra.LayerMean;
                AllSubjects_Data(iROI).Contra.grp(:,:,iSub,:) = squeeze(nanmean(Data_ROI.Contra.LayerMean,2));
                
                AllSubjects_Data(iROI).Contra_VS_Ipsi.DATA{iSub} = Data_ROI.Contra_VS_Ipsi.LayerMean;
                AllSubjects_Data(iROI).Contra_VS_Ipsi.grp(:,:,iSub,:) = squeeze(nanmean(Data_ROI.Contra_VS_Ipsi.LayerMean,2));
                
                AllSubjects_Data(iROI).ContSensModIpsi.DATA{iSub} = Data_ROI.ContSensModIpsi.LayerMean;
                AllSubjects_Data(iROI).ContSensModIpsi.grp(:,:,iSub,:) = squeeze(nanmean(Data_ROI.ContSensModIpsi.LayerMean,2));
                
                AllSubjects_Data(iROI).ContSensModContra.DATA{iSub} = Data_ROI.ContSensModContra.LayerMean;
                AllSubjects_Data(iROI).ContSensModContra.grp(:,:,iSub,:) = squeeze(nanmean(Data_ROI.ContSensModContra.LayerMean,2));
                
                % whole roi
                AllSubjects_Data(iROI).Ispi.whole_roi_grp(iSub,:,:) = nanmean(Data_ROI.Ispi.WholeROI.MEAN);
                AllSubjects_Data(iROI).Contra.whole_roi_grp(iSub,:,:) = nanmean(Data_ROI.Contra.WholeROI.MEAN);
                AllSubjects_Data(iROI).Contra_VS_Ipsi.whole_roi_grp(iSub,:,:) = nanmean(Data_ROI.Contra_VS_Ipsi.WholeROI.MEAN);
                AllSubjects_Data(iROI).ContSensModIpsi.whole_roi_grp(iSub,:,:) = nanmean(Data_ROI.ContSensModIpsi.WholeROI.MEAN);
                AllSubjects_Data(iROI).ContSensModContra.whole_roi_grp(iSub,:,:) = nanmean(Data_ROI.ContSensModContra.WholeROI.MEAN);
                
            end
            
        else
            warning('The file %s does not exit.', File2Load)
            
            AllSubjects_Data(iROI).Ispi.DATA{iSub} = nan(NbLayers, 20, size(CondNames,1),2);
            AllSubjects_Data(iROI).Ispi.grp(:,:,iSub,:) = nan(NbLayers, size(CondNames,1),2);
            
            AllSubjects_Data(iROI).Contra.DATA{iSub} = nan(NbLayers, 20, size(CondNames,1),2);
            AllSubjects_Data(iROI).Contra.grp(:,:,iSub,:) = nan(NbLayers, size(CondNames,1),2);
            
            AllSubjects_Data(iROI).Contra_VS_Ipsi.DATA{iSub} =  nan(NbLayers, 20, size(CondNames,1),2);
            AllSubjects_Data(iROI).Contra_VS_Ipsi.grp(:,:,iSub,:) =  nan(NbLayers, size(CondNames,1),2);
            
            AllSubjects_Data(iROI).ContSensModIpsi.DATA{iSub} =  nan(NbLayers, 20, size(CondNames,1),2);
            AllSubjects_Data(iROI).ContSensModIpsi.grp(:,:,iSub,:) =  nan(NbLayers, size(CondNames,1),2);
            
            AllSubjects_Data(iROI).ContSensModContra.DATA{iSub} =  nan(NbLayers, 20, size(CondNames,1),2);
            AllSubjects_Data(iROI).ContSensModContra.grp(:,:,iSub,:) =  nan(NbLayers, size(CondNames,1),2);
            
            
            AllSubjects_Data(iROI).Ispi.whole_roi_grp(iSub,:,:) = nan(1, size(CondNames,1),2);
            AllSubjects_Data(iROI).Contra.whole_roi_grp(iSub,:,:) = nan(1, size(CondNames,1),2);
            AllSubjects_Data(iROI).Contra_VS_Ipsi.whole_roi_grp(iSub,:,:) =  nan(1, size(CondNames,1),2);
            AllSubjects_Data(iROI).ContSensModIpsi.whole_roi_grp(iSub,:,:) =  nan(1, size(CondNames,1),2);
            AllSubjects_Data(iROI).ContSensModContra.whole_roi_grp(iSub,:,:) =  nan(1, size(CondNames,1),2);
            
        end
        
        clear Data_ROI
        
    end
end



%% Averages over subjects
for iROI=1:length(AllSubjects_Data)
    
    fprintf(' Processing %s\n', AllSubjects_Data(iROI).name)
    
    % layers
    AllSubjects_Data(iROI).Ispi.MEAN = nanmean(AllSubjects_Data(iROI).Ispi.grp,3);
    AllSubjects_Data(iROI).Ispi.STD = nanstd(AllSubjects_Data(iROI).Ispi.grp,3);
    AllSubjects_Data(iROI).Ispi.SEM = nansem(AllSubjects_Data(iROI).Ispi.grp,3);
    
    AllSubjects_Data(iROI).Contra.MEAN = nanmean(AllSubjects_Data(iROI).Contra.grp,3);
    AllSubjects_Data(iROI).Contra.STD = nanstd(AllSubjects_Data(iROI).Contra.grp,3);
    AllSubjects_Data(iROI).Contra.SEM = nansem(AllSubjects_Data(iROI).Contra.grp,3);
    
    AllSubjects_Data(iROI).Contra_VS_Ipsi.MEAN = nanmean(AllSubjects_Data(iROI).Contra_VS_Ipsi.grp,3);
    AllSubjects_Data(iROI).Contra_VS_Ipsi.STD = nanstd(AllSubjects_Data(iROI).Contra_VS_Ipsi.grp,3);
    AllSubjects_Data(iROI).Contra_VS_Ipsi.SEM = nansem(AllSubjects_Data(iROI).Contra_VS_Ipsi.grp,3);
    
    AllSubjects_Data(iROI).ContSensModIpsi.MEAN = nanmean(AllSubjects_Data(iROI).ContSensModIpsi.grp,3);
    AllSubjects_Data(iROI).ContSensModIpsi.STD = nanstd(AllSubjects_Data(iROI).ContSensModIpsi.grp,3);
    AllSubjects_Data(iROI).ContSensModIpsi.SEM = nansem(AllSubjects_Data(iROI).ContSensModIpsi.grp,3);
    
    AllSubjects_Data(iROI).ContSensModContra.MEAN = nanmean(AllSubjects_Data(iROI).ContSensModContra.grp,3);
    AllSubjects_Data(iROI).ContSensModContra.STD = nanstd(AllSubjects_Data(iROI).ContSensModContra.grp,3);
    AllSubjects_Data(iROI).ContSensModContra.SEM = nansem(AllSubjects_Data(iROI).ContSensModContra.grp,3);
    
    
    % whole roi
    AllSubjects_Data(iROI).Ispi.whole_roi_MEAN = nanmean(AllSubjects_Data(iROI).Ispi.whole_roi_grp);
    AllSubjects_Data(iROI).Ispi.whole_roi_STD = nanstd(AllSubjects_Data(iROI).Ispi.whole_roi_grp);
    AllSubjects_Data(iROI).Ispi.whole_roi_SEM = nansem(AllSubjects_Data(iROI).Ispi.whole_roi_grp);
    
    AllSubjects_Data(iROI).Contra.whole_roi_MEAN = nanmean(AllSubjects_Data(iROI).Contra.whole_roi_grp);
    AllSubjects_Data(iROI).Contra.whole_roi_STD = nanstd(AllSubjects_Data(iROI).Contra.whole_roi_grp);
    AllSubjects_Data(iROI).Contra.whole_roi_SEM = nansem(AllSubjects_Data(iROI).Contra.whole_roi_grp);
    
    AllSubjects_Data(iROI).Contra_VS_Ipsi.whole_roi_MEAN = nanmean(AllSubjects_Data(iROI).Contra_VS_Ipsi.whole_roi_grp);
    AllSubjects_Data(iROI).Contra_VS_Ipsi.whole_roi_STD = nanstd(AllSubjects_Data(iROI).Contra_VS_Ipsi.whole_roi_grp);
    AllSubjects_Data(iROI).Contra_VS_Ipsi.whole_roi_SEM = nansem(AllSubjects_Data(iROI).Contra_VS_Ipsi.whole_roi_grp);
    
    AllSubjects_Data(iROI).ContSensModIpsi.whole_roi_MEAN = nanmean(AllSubjects_Data(iROI).ContSensModIpsi.whole_roi_grp);
    AllSubjects_Data(iROI).ContSensModIpsi.whole_roi_STD = nanstd(AllSubjects_Data(iROI).ContSensModIpsi.whole_roi_grp);
    AllSubjects_Data(iROI).ContSensModIpsi.whole_roi_SEM = nansem(AllSubjects_Data(iROI).ContSensModIpsi.whole_roi_grp);
    
    AllSubjects_Data(iROI).ContSensModContra.whole_roi_MEAN = nanmean(AllSubjects_Data(iROI).ContSensModContra.whole_roi_grp);
    AllSubjects_Data(iROI).ContSensModContra.whole_roi_STD = nanstd(AllSubjects_Data(iROI).ContSensModContra.whole_roi_grp);
    AllSubjects_Data(iROI).ContSensModContra.whole_roi_SEM = nansem(AllSubjects_Data(iROI).ContSensModContra.whole_roi_grp);
    
end



%% Betas from profile fits
fprintf('\n')

for iROI=1:length(AllSubjects_Data)
    
    Name=AllSubjects_Data(iROI).name;
    
    fprintf('Computing betas for ROI %s\n', Name)
    
    for i=1:5
        
        %% Actually compute betas
        for iSub = 1:NbSub
            for ihs = 1:2
                switch i
                    case 1
                        Blocks = AllSubjects_Data(iROI).Ispi.DATA{iSub}(:,:,:,ihs);
                    case 2
                        Blocks = AllSubjects_Data(iROI).Contra.DATA{iSub}(:,:,:,ihs);
                    case 3
                        Blocks = AllSubjects_Data(iROI).Contra_VS_Ipsi.DATA{iSub}(:,:,:,ihs);
                    case 4
                        Blocks = AllSubjects_Data(iROI).ContSensModIpsi.DATA{iSub}(:,:,:,ihs);
                    case 5
                        Blocks = AllSubjects_Data(iROI).ContSensModContra.DATA{iSub}(:,:,:,ihs);
                end
                
                if ~all(isnan(Blocks(:))) || ~isempty(Blocks)
                    
                    for iCond = 1:size(Blocks,3)
                        
                        Y = flipud(Blocks(:,:,iCond));
                        [B] = ProfileGLM(DesMat, Y);
                        
                        switch i
                            case 1
                                AllSubjects_Data(iROI).Ispi.Beta.DATA(:,iCond,iSub,ihs)=B;
                            case 2
                                AllSubjects_Data(iROI).Contra.Beta.DATA(:,iCond,iSub,ihs)=B;
                            case 3
                                AllSubjects_Data(iROI).Contra_VS_Ipsi.Beta.DATA(:,iCond,iSub,ihs)=B;
                            case 4
                                AllSubjects_Data(iROI).ContSensModIpsi.Beta.DATA(:,iCond,iSub,ihs)=B;
                            case 5
                                AllSubjects_Data(iROI).ContSensModContra.Beta.DATA(:,iCond,iSub,ihs)=B;
                        end
                        clear Y B
                        
                    end
                    
                end
            end
        end
        
        %% Group stat on betas
        for ihs = 1:2
            switch i
                case 1
                    tmp = AllSubjects_Data(iROI).Ispi.Beta.DATA(:,:,:,ihs);
                    AllSubjects_Data(iROI).Ispi.Beta.MEAN(:,:,ihs)=nanmean(tmp, 3);
                    AllSubjects_Data(iROI).Ispi.Beta.STD(:,:,ihs)=nanstd(tmp, 3);
                    AllSubjects_Data(iROI).Ispi.Beta.SEM(:,:,ihs)=nansem(tmp, 3);
                case 2
                    tmp = AllSubjects_Data(iROI).Contra.Beta.DATA(:,:,:,ihs);
                    AllSubjects_Data(iROI).Contra.Beta.MEAN(:,:,ihs)=nanmean(tmp, 3);
                    AllSubjects_Data(iROI).Contra.Beta.STD(:,:,ihs)=nanstd(tmp, 3);
                    AllSubjects_Data(iROI).Contra.Beta.SEM(:,:,ihs)=nansem(tmp, 3);
                case 3
                    tmp = AllSubjects_Data(iROI).Contra_VS_Ipsi.Beta.DATA(:,:,:,ihs);
                    AllSubjects_Data(iROI).Contra_VS_Ipsi.Beta.MEAN(:,:,ihs)=nanmean(tmp, 3);
                    AllSubjects_Data(iROI).Contra_VS_Ipsi.Beta.STD(:,:,ihs)=nanstd(tmp, 3);
                    AllSubjects_Data(iROI).Contra_VS_Ipsi.Beta.SEM(:,:,ihs)=nansem(tmp, 3);
                case 4
                    tmp = AllSubjects_Data(iROI).ContSensModIpsi.Beta.DATA(:,:,:,ihs);
                    AllSubjects_Data(iROI).ContSensModIpsi.Beta.MEAN(:,:,ihs)=nanmean(tmp, 3);
                    AllSubjects_Data(iROI).ContSensModIpsi.Beta.STD(:,:,ihs)=nanstd(tmp, 3);
                    AllSubjects_Data(iROI).ContSensModIpsi.Beta.SEM(:,:,ihs)=nansem(tmp, 3);
                case 5
                    tmp = AllSubjects_Data(iROI).ContSensModContra.Beta.DATA(:,:,:,ihs);
                    AllSubjects_Data(iROI).ContSensModContra.Beta.MEAN(:,:,ihs)=nanmean(tmp, 3);
                    AllSubjects_Data(iROI).ContSensModContra.Beta.STD(:,:,ihs)=nanstd(tmp, 3);
                    AllSubjects_Data(iROI).ContSensModContra.Beta.SEM(:,:,ihs)=nansem(tmp, 3);
            end

            clear tmp P
        end
    end
    
end


%% Saves
fprintf('\nSaving\n')

for iROI = 1:numel(AllSubjects_Data)
    Results = AllSubjects_Data(iROI);
    save( fullfile(ResultsDir, strcat('Results_', AllSubjects_Data(iROI).name, ...
        '_SurfQuadGLM_l-', num2str(NbLayers), '.mat')), 'Results')
end

save( fullfile(ResultsDir, strcat('ResultsSurfQuadGLM_l-', num2str(NbLayers), '.mat')) )

cd(StartDir)

end

function [B] = ProfileGLM(X, Y)

if any(isnan(Y(:)))
    [~,y]=find(isnan(Y));
    y=unique(y);
    Y(:,y)=[];
    clear y
end

if isempty(Y)
    B=nan(1,size(X,2));
else
    X=repmat(X,size(Y,2),1);
    Y=Y(:);
    [B,~,~] = glmfit(X, Y, 'normal', 'constant', 'off');
end

end