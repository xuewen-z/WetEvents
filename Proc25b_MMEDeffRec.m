clear; clc;
addpath(genpath('./'));

Path_Change = '../output/25_DeffRecCMIP6GPP/';
Path_Out    = '../output/25b_MMEDeffRec/';

system(['rm -rf ',Path_Out]);
system(['mkdir -p ',Path_Out]);

ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR'};
SSPList  = {'ssp126','ssp245','ssp370','ssp585'};

for s = 1:numel(SSPList)
    SSPName = SSPList{s};

    RecAll = [];

    for m = 1:numel(ModeList)
        Mode = ModeList{m};
        File = fullfile(Path_Change,Mode,SSPName,'DeltaRec.mat');
        D = load(File);   % DeltaRec
        RecAll(:,:,m) = D.DeltaRec;
    end

    % === 多模型均值 ===
    MMERec = mean(RecAll,3,'omitnan');

    OutPath = fullfile(Path_Out,SSPName);
    system(['mkdir -p ',OutPath]);

    save(fullfile(OutPath,'DeltaRec_MME.mat'), ...
        'MMERec','-v7.3');
end
