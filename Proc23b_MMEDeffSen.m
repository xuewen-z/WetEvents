clear; clc;
addpath(genpath('./'));

Path_Change = '../output/23_DeffSenCMIP6GPP/';
Path_Out    = '../output/23b_MMEDeffSen/';

system(['rm -rf ',Path_Out]);
system(['mkdir -p ',Path_Out]);

ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR'};
SSPList  = {'ssp126','ssp245','ssp370','ssp585'};

for s = 1:numel(SSPList)
    SSPName = SSPList{s};

    SenAll = [];

    for m = 1:numel(ModeList)
        Mode = ModeList{m};
        File = fullfile(Path_Change,Mode,SSPName,'DeltaSen.mat');
        D = load(File);   % DeltaSen
        SenAll(:,:,m) = D.DeltaSen;
    end

    % === 多模型均值 ===
    MMESen = mean(SenAll,3,'omitnan');

    OutPath = fullfile(Path_Out,SSPName);
    system(['mkdir -p ',OutPath]);

    save(fullfile(OutPath,'DeltaSen_MME.mat'), ...
        'MMESen','-v7.3');
end
