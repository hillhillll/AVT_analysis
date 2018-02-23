clc; clear;

Target = 0;

StartDir = fullfile(pwd, '..','..','..');
addpath(genpath(fullfile(StartDir, 'code','subfun')))

cd(StartDir)
SubLs = dir('sub*');
NbSub = numel(SubLs);

NbLayers = 6;

if Target
    CondNames = {...
        'ATargL','ATargR',...
        'VTargL','VTargR',...
        'TTargL','TTargR',...
        };
else
    CondNames = {...
        'AStimL','AStimR',...
        'VStimL','VStimR',...
        'TStimL','TStimR'}; %#ok<*UNRCH>
end

DesMat = (1:NbLayers)-mean(1:NbLayers);
DesMat = [ones(NbLayers,1) DesMat' (DesMat.^2)'];
% DesMat = [ones(NbLayers-2,1) DesMat'];
DesMat = spm_orth(DesMat);

ToPlot={'Cst','Lin','Quad'};

for iSub = 1:NbSub
    
    fprintf('\n\n\n')
    
    fprintf('Processing %s\n', SubLs(iSub).name)
    
    Sub_dir = fullfile(StartDir, SubLs(iSub).name);
    GLM_dir = fullfile(Sub_dir, 'ffx_nat');
    
    if Target
        Data_dir = fullfile(GLM_dir,'betas','6_surf', 'targets');
    else
        Data_dir = fullfile(GLM_dir,'betas','6_surf');
    end
    
    % Get number of sessions, regressors of interest numbers, and names of conditions
    load(fullfile(GLM_dir, 'SPM.mat'))
    [BetaOfInterest, BetaNames] = GetBOI(SPM,CondNames);
    Nb_sess = numel(SPM.Sess);
    clear SPM
    
    % Load Vertices of interest for each ROI;
    load(fullfile(Sub_dir, 'roi', 'surf',[SubLs(iSub).name  '_ROI_VertOfInt.mat']), 'ROI', 'NbVertex')
    
    % Loads which runs happened on which day to set up the CVs
    load(fullfile(StartDir, 'RunsPerSes.mat'))
    Idx = ismember({RunPerSes.Subject}, SubLs(iSub).name);
    RunPerSes = RunPerSes(Idx).RunsPerSes;
    DayCVs = {...
        1:RunPerSes(1), ...
        RunPerSes(1)+1:RunPerSes(1)+RunPerSes(2),...
        RunPerSes(1)+RunPerSes(2)+1:sum(RunPerSes)};
    clear Idx RunPerSes
    
    %% For the 2 hemispheres
    NbVertices = nan(1,2);
    for hs = 1:2
        
        if hs==1
            fprintf('\n\n Left hemipshere\n')
            HsSufix = 'l';
        else
            fprintf('\n\n Right hemipshere\n')
            HsSufix = 'r';
        end
        
        FeatureSaveFile = fullfile(Data_dir,[SubLs(iSub).name  '_features_' HsSufix 'hs_' ...
            num2str(NbLayers) '_surf.mat']);
        
        InfSurfFile=spm_select('FPList', fullfile(Sub_dir, 'anat', 'cbs'), ...
            ['^' SubLs(iSub).name '.*' HsSufix 'cr_gm_avg_inf.vtk$']);
        [inf_vertex,inf_faces,~] = read_vtk(InfSurfFile, 0, 1);
        
        NbVertices(hs)=size(inf_vertex,2);
        
        % Load data or extract them
        fprintf('  Reading VTKs\n')
        if exist(FeatureSaveFile, 'file')
            load(FeatureSaveFile)
            VertexWithDataHS{hs} = VertexWithData; %#ok<*SAGROW>
        else
            error('The features have not been extracted from the VTK files.')
        end
        
        
        %% Run GLMs for basic conditions
        fprintf('\n   All conditions\n')
        
        for iCdt = 1:numel(CondNames) % For each Condition
            fprintf('    %s\n',CondNames{iCdt})
            
            % Identify the relevant betas
            Beta2Sel = [];
            for iSess = 1:Nb_sess
                if strcmp(SubLs(iSub).name,'sub-06') && iSess==17
                else
                    Beta2Sel = [Beta2Sel ;find(strcmp(cellstr(BetaNames), ...
                        ['Sn(' num2str(iSess) ') ' CondNames{iCdt}  '*bf(1)']))];   %#ok<*AGROW>
                end
            end
            
            % Identify the corresponding "layers" (as in 3rd dimension) in the feature matrix
            Beta2Sel = find(ismember(BetaOfInterest, Beta2Sel));
            
            % Extract them
            Features = AllMapping(:,:,Beta2Sel);
            
            if sum(isnan(Features(:)))>0
                warning('We have %i NaNs for %s', sum(isnan(Features(:))), CondNames{iCdt})
            end
            if sum(Features(:)==0)>0
                warning('We have %i zeros for %s', sum(Features(:)==0), CondNames{iCdt})
            end
            
            % Run the "cross-validation"
            for iCV = 1:size(Features,3)
                Sess2Sel = iCV;
                if strcmp(SubLs(iSub).name,'sub-06') && iCdt<3 && iCV==17
                    %                     BetaCdt{hs,iCV}(:,:,iCdt) = nan(size(DesMat,2),size(Features,1));
                else
                    Y = Features(:,:,Sess2Sel);
                    X=repmat(DesMat,size(Y,3),1);
                    Y = shiftdim(Y,1);
                    B = pinv(X)*Y;
                    BetaCdt{hs,iCV}(:,:,iCdt) = B;
                end
            end
            
            clear Features Beta2Sel X Y B iSess
        end
        
        clear iCdt
        
        
    end
    
    cd(StartDir)
    
    if any(NbVertex ~= NbVertices)
        NbVertex
        NbVertices %#ok<*NOPTS>
        error('The number of vertices does not match.')
    end
    
    %%
    if strcmp(SubLs(iSub).name,'sub-06')
        Nb_sess = 19;
    end
    
    Cdt_ROI_lhs = 1:6;
    Cdt_ROI_rhs = [2 1 4 3 6 5];
    
    for iToPlot = 1:numel(ToPlot)
        
        X_lh = nan(size(CondNames,2)*Nb_sess,NbVertex(1));
        X_rh = nan(size(CondNames,2)*Nb_sess,NbVertex(2));
        row=1;
        
        for iCV = 1:Nb_sess
            for iCdt = 1:size(CondNames,2)
                X_lh(row,VertexWithDataHS{1}) = BetaCdt{1,iCV}(iToPlot,:,Cdt_ROI_lhs(iCdt));
                X_rh(row,VertexWithDataHS{2}) = BetaCdt{2,iCV}(iToPlot,:,Cdt_ROI_rhs(iCdt));
                row=row+1;
            end
        end
        
        for iROI = 1:numel(ROI)
            
            X = [X_lh(:,ROI(iROI).VertOfInt{1}) X_rh(:,ROI(iROI).VertOfInt{2})];
            
            % Stores data for PCM
            PCM_data{iToPlot,iROI} = X;
            
        end
        
    end
    
    clear BetaCdt
    
    mkdir(fullfile(Sub_dir,'results','profiles','surf','PCM'))
    
    if Target
        save(fullfile(Sub_dir,'results','profiles','surf','PCM','Data_PCM_targets_raw_beta.mat'), '-v7.3', 'PCM_data')
    else
        save(fullfile(Sub_dir,'results','profiles','surf','PCM','Data_PCM_stim_raw_beta.mat'), '-v7.3', 'PCM_data')
    end
    
    
end

cd(StartDir)

