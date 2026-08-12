clear; clc;
addpath(genpath('./'));

Path_Change = '../output/24_DeffResCMIP6GPP/';
Path_Out    = '../output/24b_MMEDeffRes/';

system(['rm -rf ',Path_Out]);
system(['mkdir -p ',Path_Out]);

% ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR'};
ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR','CNRM-ESM2-1','IPSL-CM6A-LR','NorESM2-MM'};

SSPList  = {'ssp126','ssp245','ssp370','ssp585'};

MinModel = 2;   % 可调

for s = 1:numel(SSPList)
    SSPName = SSPList{s};

    ResAll = [];

    for m = 1:numel(ModeList)
        Mode = ModeList{m};
        File = fullfile(Path_Change,Mode,SSPName,'OmegaRes.mat');
        D = load(File);   % Δlog(Res)
        ResAll(:,:,m) = D.OmegaRes;
    end

    % === 再保险清洗 ===
    ResAll(~isfinite(ResAll)) = NaN;

    % === 多模型均值（log 空间） ===
    ValidN = sum(isfinite(ResAll),3);
    MMERes = mean(ResAll,3,'omitnan');
    MMERes(ValidN < MinModel) = NaN;

    OutPath = fullfile(Path_Out,SSPName);
    system(['mkdir -p ',OutPath]);

    save(fullfile(OutPath,'OmegaRes_MME.mat'), ...
        'MMERes','-v7.3');
end
