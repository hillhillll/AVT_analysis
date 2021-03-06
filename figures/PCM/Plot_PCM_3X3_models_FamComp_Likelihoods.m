% for 3X3 models
% - computes likelihood of each model
% - computes exceedance probabilities by performing 2 family comparison with spm_compare_families
%           a) Families.names{1}='Scaled';
%           b) Families.names{2}='Scaled+Idpdt and Idpdt';
% or
%           a) Families.names{1}='Scaled';
%           b) Families.names{2}='Scaled+Idpdt'
%           c) Families.names{3}='Idpdt'
% - plot the exceedance probabilities for both cases as a matrix

clc; clear; close all

%% set up directories and get dependencies
if isunix
    CodeDir = '/home/remi/github/AVT_analysis';
    StartDir = '/home/remi';
elseif ispc
    CodeDir = 'D:\github\AVT-7T-code';
    StartDir = 'D:\';
else
    disp('Platform not supported')
end

addpath(genpath(fullfile(CodeDir, 'subfun')))

[Dirs] = set_dir();

Get_dependencies()

PCM_dir = fullfile(Dirs.DerDir, 'figures', 'PCM');

Comp_suffix{1} = '3X3_Ipsi';
Comp_suffix{end+1} = '3X3_Contra';
Comp_suffix{end+1} = '3X3_ContraIpsi';

%% Sorting models for each family comparison

family_names={...
    'Idpdt',...
    'Scaled',...
    'Scaled_Idpdt'};
family_names2={...
    'Idpdt + Scaled_Idpdt',...
    'Scaled'};

CdtComb = ['AV';'AT';'VT'];

% These are the 12 models from the PCM
% M{1}.name = 'all_scaled';
% M{2}.name = 'all_idpdt';
% M{3}.name = 'all_scaled_&_idpdt';
%
% M{4}.name = 'A idpdt - V,T scaled';
% M{5}.name = 'V idpdt - A,T scaled';
% M{6}.name = 'T idpdt - V,A scaled';
%
% M{7}.name = 'A idpdt+scaled - V,T scaled';
% M{8}.name = 'V idpdt+scaled - A,T scaled';
% M{9}.name = 'T idpdt+scaled - V,A scaled';
%
% M{10}.name = 'A idpdt+scaled V - T idpdt';
% M{11}.name = 'A idpdt+scaled T - V idpdt';
% M{12}.name = 'V idpdt+scaled T - A idpdt';

% Models to include for each modality for the family comparison
A_Idpdt_V = [2 4 5 11 12];
A_Scaled_V = [1 6 9];
A_Scaled_Idpdt_V = [3 7 8 10];

Cdt{1} = [A_Idpdt_V A_Scaled_V A_Scaled_Idpdt_V];

A_Idpdt_T = [2 4 6 10 12];
A_Scaled_T = [1 5 8];
A_Scaled_Idpdt_T = [3 7 9 11];

Cdt{2} = [A_Idpdt_T A_Scaled_T A_Scaled_Idpdt_T];

V_Idpdt_T = [2 5 6 10 11];
V_Scaled_T = [1 4 7];
V_Scaled_Idpdt_T = [3 8 9 12];

Cdt{3} = [V_Idpdt_T V_Scaled_T V_Scaled_Idpdt_T];

% Create the families
for iCdt = 1:3
    Families{iCdt} = ...
        struct('names', [], 'partition', [1 1 1 1 1 2 2 2 3 3 3 3], ...
        'modelorder', [], 'infer', 'RFX', 'Nsamp', 1e4, 'prior', 'F-unity'); %#ok<*SAGROW>
    Families2{iCdt} = ...
        struct('names', [], 'partition', [1 1 1 1 1 2 2 2 1 1 1 1], ...
        'modelorder', [], 'infer', 'RFX', 'Nsamp', 1e4, 'prior', 'F-unity');
    for iFam = 1:3
        Families{iCdt}.names{iFam} = [CdtComb(iCdt,1) '_' family_names{iFam} '_' CdtComb(iCdt,2)];
    end
    for iFam = 1:2
        Families2{iCdt}.names{iFam} = [CdtComb(iCdt,1) '_' family_names2{iFam} '_' CdtComb(iCdt,2)];
    end
    % The field model order will be used to only extract the likelihood
    % of the models of interest
    Families{iCdt}.modelorder = Cdt{iCdt};
    Families2{iCdt}.modelorder = Cdt{iCdt};
end

%%
surf = 1; % run of volumne whole ROI or surface profile data
raw = 0; % run on raw betas or prewhitened
hs_idpdt = 0;
on_merged_ROI = 0;

Split_suffix = '';

NbROI = 4;


if surf
    ToPlot={'Cst','Lin','Avg','ROI'};
    Output_dir = 'surf';
else
    ToPlot={'ROI'}; %#ok<*UNRCH>
    Output_dir = 'vol';
    if raw
        Save_suffix = 'beta-raw';
    else
        Save_suffix = 'beta-wht'; %#ok<*UNRCH>
    end
end
Save_dir = fullfile(Dirs.DerDir, 'results', 'PCM', Output_dir);

if raw
    Beta_suffix = 'raw-betas';
else
    Beta_suffix = 'wht-betas';
end

if hs_idpdt==1
    hs_suffix = {'LHS' 'RHS'};
    NbHS = 2;
else
    hs_suffix = {'LRHS'};
    NbHS = 1;
end


% To know how many ROIs we have
if surf
    load(fullfile(Dirs.DerDir, 'sub-02', 'roi', 'surf','sub-02_ROI_VertOfInt.mat'), 'ROI', 'NbVertex')
else
    ROI(1).name ='A1';
    ROI(2).name ='PT';
    ROI(3).name ='V1_thres';
    ROI(4).name ='V2_thres';
    ROI(5).name ='V3_thres';
    ROI(6).name ='V4_thres';
    ROI(7).name ='V5_thres';
end


%% Figure parameters
set(0,'defaultAxesFontName','Arial')
set(0,'defaultTextFontName','Arial')

FigDim = [50, 50, 480, 600];


for iToPlot = 1 %:numel(ToPlot)
    
    for Target = 1
        
        if Target==2
            Stim_suffix = 'targ';
        else
            Stim_suffix = 'stim';
        end
        
        for iROI = 1:NbROI
            
            for ihs=1:NbHS
                
                for iComp = 1:3
                    
                    Save_dir = fullfile(Dirs.DerDir, 'results', 'PCM', Output_dir);
                    
                    ls_files_2_load = dir(fullfile(Save_dir, ...
                        sprintf('PCM_group_features_%s_%s_%s_%s_%s_%s_%s_20*.mat', ...
                        Stim_suffix, Beta_suffix, ROI(iROI).name, hs_suffix{ihs},...
                        ToPlot{iToPlot}, Split_suffix, Comp_suffix{iComp})));
                    
                    disp(fullfile(Save_dir,ls_files_2_load(end).name))
                    load(fullfile(Save_dir,ls_files_2_load(end).name),...
                        'M','T_group','G_hat','G','G_pred_gr','T_cross','G_pred_cr')
                    
                    M_all{iComp,1} = M; %#ok<*AGROW>
                    T_group_all{iComp,1} = T_group;
                    T_cross_all{iComp,1} = T_cross;
                    
                    clear M G G_hat T_group G_pred_gr T_cross G_pred_cr
                    
                end
                
                Normalize = 0;
                colors={'b';'b';'b';'b';'b';'b';'b';'b';'b';'b';'b';'b'};
                
                for iComp = 1:numel(M_all)
                    
                    Upperceil = T_group_all{iComp,1}.likelihood(:,end);
                    Data2Plot = T_cross_all{iComp,1};
                    M = M_all{iComp,1};
                    
                    T = pcm_plotModelLikelihood(Data2Plot,M,'upperceil',Upperceil, 'colors', colors, ...
                        'normalize',Normalize);
                    Likelihood{iROI,ihs}(:,:,iComp) = T.likelihood;
                    Likelihood_norm{iROI,ihs}(:,:,iComp) = T.likelihood_norm;
                    
                end
            end
        end
        
        %% Do family comparison and plot
        XP = [];
        XP2 = [];
        for iROI = 1:NbROI
            
            close all
            
            %% For ipsi and contra
            for iComp = 1:numel(M_all)
                
                %% RFX: perform bayesian model family comparison
                % Compute exceedance probabilities
                for iCdt = 1:3
                    family = Families{iCdt};
                    loglike = Likelihood{iROI,ihs}(:,family.modelorder+1,iComp);%-Likelihood{iROI,ihs}(:,1,iComp);
                    family = spm_compare_families(loglike,family);
                    XP(iCdt,:,iROI,iComp) = family.xp;
                    
                    family = Families2{iCdt};
                    loglike = Likelihood{iROI,ihs}(:,family.modelorder+1,iComp);%-Likelihood{iROI,ihs}(:,1,iComp);
                    family = spm_compare_families(loglike,family);
                    XP2(iCdt,:,iROI,iComp) = family.xp;
                end
                
            end
        end
        
        
        %% Matrices plot for exceedance probability of I + (S & I)
        close all
        
        save_dir = fullfile(PCM_dir, 'Cdt', '3X3', ToPlot{iToPlot});
        
        for iFam = 1:2
            
            Mat2Save_struct = struct(...
                'comp',{{'Ai VS Vi', 'Ai VS Ti', 'Vi VS Ti', ...
                'Ac VS Vc', 'Ac VS Tc', 'Vc VS Tc'}}, ...
                'p_s',[ ],...
                'p_si',[ ],...
                'p_i',[ ]);
            
            for iComp = 1:size(XP,4)
                
                if iFam==1
                    NbFam = '3';
                    Mat2Plot = squeeze(XP(:,3,:,iComp)+XP(:,1,:,iComp));
                    Mat2Save = cat(1, XP([2 1 3],:,:,iComp), XP([2 1 3],:,:,iComp));
                else
                    NbFam = '2';
                    Mat2Plot = squeeze(XP2(:,1,:,iComp));
                    Mat2Save = zeros(6,3,NbROI);
                end
                
                opt.FigName = sprintf('ExcProba-%sFam-%s-%s-PCM_{grp}-%s-%s-%s', ...
                    NbFam, hs_suffix{ihs}, Comp_suffix{iComp}, ...
                    Stim_suffix, Beta_suffix, ToPlot{iToPlot});
                
                print_PCM_table(Mat2Save, Mat2Save_struct, ROI, NbROI, save_dir, opt)
                
                
                figure('name', opt.FigName, 'Position', FigDim, 'Color', [1 1 1]);
                
                colormap('gray')

                hold on
                box off
                
                imagesc(flipud(Mat2Plot), [0 1])
                
                plot([.5 NbROI+.5], [1.5 1.5], 'color', [.2 .2 .2], 'linewidth', 1)
                plot([.5 NbROI+.5], [2.5 2.5], 'color', [.2 .2 .2], 'linewidth', 1)
                plot([1.5 1.5], [.5 3.5], 'color', [.2 .2 .2], 'linewidth', 1)
                plot([2.5 2.5], [.5 3.5], 'color', [.2 .2 .2], 'linewidth', 1)
                plot([3.5 3.5], [.5 3.5], 'color', [.2 .2 .2], 'linewidth', 1)
                plot([4.5 4.5], [.5 3.5], 'color', [.2 .2 .2], 'linewidth', 1)
                
                patch([2.44 2.56 2.56 2.44], [.5 .5 3.5 3.5], 'w', 'linewidth', 2)
                
                plot([.5 .5], [.5 3.5], 'k', 'linewidth', 2)
                plot([NbROI+.5 NbROI+.5], [.5 3.5], 'k', 'linewidth', 2)
                plot([.5 NbROI+.5], [.5 .5], 'k', 'linewidth', 2)
                plot([.5 NbROI+.5], [3.5 3.5], 'k', 'linewidth', 2)
                
                title(strrep(Comp_suffix{iComp}, '3X3_', ''))

                switch iComp
                    case 1
                        yticklabel = ['V_i VS T_i';'A_i VS T_i';'A_i VS V_i'];
                    case 2
                        yticklabel = ['V_c VS T_c';'A_c VS T_c';'A_c VS V_c'];
                    case 3
                        yticklabel = ['V VS T';'A VS T';'A VS V'];
                end
                
                set(gca,'fontsize', 10, ...
                    'ytick', 1:3,...
                    'yticklabel', yticklabel,...
                    'xtick', 1:NbROI,...
                    'xticklabel', {ROI(1:NbROI).name}, 'Xcolor', 'k')
                
%                 colorbar
                
%                 p=mtit(['Exc probability Idpt + Scaled & Idpdt - ' ToPlot{iToPlot}],...
%                     'fontsize',14,...
%                     'xoff',0,'yoff',.025);
                
                axis([.5 NbROI+.5 .5 3.5])
                axis square

                print(gcf, fullfile(save_dir, [opt.FigName  '.tif'] ), '-dtiff')
                pause(2)
                
                
                ColorMap = brain_colour_maps('hot_increasing');
                colormap(ColorMap)
                print(gcf, fullfile(save_dir, [opt.FigName  '_hot.tif'] ), '-dtiff')
                
                
                
            end
            
            
        end
        
    end
end
