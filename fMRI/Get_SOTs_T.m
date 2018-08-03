%%
clc; clear all; close all;

Subjects = [0];

IndStart = 5;% first row of data points in txt file

StartDirectory = pwd;

for SubjInd = 1:length(Subjects)

    cd(fullfile(StartDirectory, strcat('Subject_', num2str(Subjects(SubjInd))), 'fMRI'))

    LogFileList = dir(strcat('Logfile_Subject_', num2str(Subjects(SubjInd)), '_Run_4*.txt'));
    TrialListFileList = dir(strcat('Trial_List_Subject_', num2str(Subjects(SubjInd)), '_Run_4*.txt'));

    SOT=cell(1,2,length(LogFileList));
    
    AllSOTs = cell(length(LogFileList),1);

    for iFile = 1:length(LogFileList)

        % Loads trial type order presented
        TrialList = load(['Trial_List_Subject_', num2str(Subjects(SubjInd)), ...
            '_Run_' LogFileList(iFile).name(end-23:end-20) '.txt']);
        TrialList(TrialList==0) = [];

        disp(['Trial_List_Subject_', num2str(Subjects(SubjInd)), ...
            '_Run_' LogFileList(iFile).name(end-23:end-20) '.txt'])

        % Loads side order presented
        SideList = load(['Side_List_Subject_', num2str(Subjects(SubjInd)), ...
            '_Run_' LogFileList(iFile).name(end-23:end-20) '.txt']);
        SideList(SideList==0) = [];

        disp(['Side_List_Subject_', num2str(Subjects(SubjInd)), ...
            '_Run_' LogFileList(iFile).name(end-23:end-20) '.txt'])


        % Loads log file
        disp(LogFileList(iFile).name)

        fid = fopen(fullfile (pwd, LogFileList(iFile).name));
        FileContent = textscan(fid,'%s %s %s %s %s %s %s %s %s %s %s %s', 'headerlines', IndStart, 'returnOnError',0);
        fclose(fid);
        clear fid

        EOF = find(strcmp('Final_Fixation', FileContent{1,3}));
        if isempty(EOF)
            EOF = find(strcmp('Quit', FileContent{1,2})) - 1;
        end

        Stim_Time{1,1} = FileContent{1,3}(1:EOF);
        Stim_Time{1,2} = char(FileContent{1,4}(1:EOF));

        StartTime =  str2num(Stim_Time{1,2}(find(strcmp('Start', Stim_Time{1,1})),:));

        Duration =  (str2num(Stim_Time{1,2}(end,:)) - StartTime)/600000

        TEMP = find(strcmp('30', Stim_Time{1,1}));
        TEMP = [TEMP ; find(strcmp('ISI', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Final_Fixation', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('Start', Stim_Time{1,1}))];
        TEMP = [TEMP ; find(strcmp('5', Stim_Time{1,1}))];

        Stim_Time{1,1}(TEMP,:) = [];
        Stim_Time{1,2}(TEMP,:) = [];
        clear TEMP

        NbTTrial=sum(TrialList==5);
        NbTTarget=sum(TrialList==8);
        NbResp=sum(strcmp('1', Stim_Time{1,1}));

        iTrial = 1;

        for i=1:length(TrialList)
            
            if SideList(i)<8
                Side = 1;
            else
                Side = 2;
            end
          
            if strcmp('1', Stim_Time{1,1}(iTrial,:))
                SOT{1,Side,iFile}(end+1) = (str2double(Stim_Time{1,2}(iTrial,:)) - StartTime)/10000;
                iTrial = iTrial+1;
            end

            SOT{1,Side,iFile}(end+1) = (str2double(Stim_Time{1,2}(iTrial,:)) - StartTime)/10000;
            iTrial = iTrial+1;
            
            AllSOTs{iFile,1}(end+1) = (str2double(Stim_Time{1,2}(iTrial,:)) - StartTime)/10000;

        end
        
        S.bf = 'hrf';
        S.HC = 128;
        S.TR = 3;
        S.t0 = 3;

        S.CM{1} = [1 0];
        S.CM{2} = [0 1];

        S.sots{1} = abs(SOT{1,1,iFile}/S.TR);
        S.sots{2} = abs(SOT{1,2,iFile}/S.TR);

        S.Ns = ceil((Duration*60/S.TR));
        
        cd(StartDirectory)
        [e, X] = fMRI_GLM_efficiency(S);
        
        close all
        Colors = 'rgbcmky';
        figure('name', 'AV', 'position', [100 100 1200 550])
        subplot(2,2,1)
        hold on
        for i=1:length(S.sots)
            stem(S.sots{i},ones(1,length(S.sots{i})), Colors(i))
        end
        axis([0 10+S.Ns 0 1.2])
        set(gca,'tickdir', 'out', 'xtick', 0:10:(10+S.Ns) ,...
            'xticklabel', (0:10:(10+S.Ns))*S.TR, ...
            'ticklength', [0.01 0.01], 'fontsize', 10)
        t=xlabel('Time (s)');
        set(t,'fontsize',10);

        subplot(2,2,3)
        hold on
        for i=1:length(S.sots)
            plot(X(:,i), Colors(i))
        end
        axis([0 10+S.Ns min(X(:)) max(X(:))])
        set(gca,'tickdir', 'out', 'xtick', 0:10:(10+S.Ns) ,...
            'xticklabel', (0:10:(10+S.Ns))*S.TR, ...
            'ticklength', [0.01 0.01], 'fontsize', 10)
        t=xlabel('Time (s)');
        set(t,'fontsize',10);

        subplot(2,2,[2 4])
        colormap(gray)
        imagesc(X)
        
        
        tmp = diff(AllSOTs{iFile,1});
        tmp(tmp>6) = [];
        fprintf('%f +/- %f secs\n\n', mean(tmp), std(tmp))

    end

end

