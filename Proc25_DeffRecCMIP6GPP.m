clear; clc;
addpath(genpath('./'));

PathRec = '../output/22_SumRecCMIP6GPP/Climatology/';
PathOut = '../output/25_DeffRecCMIP6GPP/';

system(['rm -rf ',PathOut]);
system(['mkdir -p ',PathOut]);

% ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR'};
ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR','CNRM-ESM2-1','IPSL-CM6A-LR','NorESM2-MM'};

SSPList  = {'ssp126','ssp245','ssp370','ssp585'};

for i = 1:numel(ModeList)
    ModeName = ModeList{i};

    BasePath = fullfile(PathRec,ModeName,'historical','baseline');
    load(fullfile(BasePath,'RecClimTotal.mat'),'RecClimTotal');
    LogRecBase = log(RecClimTotal);

    for s = 1:numel(SSPList)
        SSPName = SSPList{s};

        FutPath = fullfile(PathRec,ModeName,SSPName,'future');
        system(['mkdir -p ',fullfile(PathOut,ModeName,SSPName)]);

        load(fullfile(FutPath,'RecClimTotal.mat'),'RecClimTotal');
        LogRecFut = log(RecClimTotal);

        DeltaRec = LogRecFut - LogRecBase;
        DeltaRec(~isfinite(DeltaRec)) = NaN;

        save(fullfile(PathOut,ModeName,SSPName,'DeltaRec.mat'), ...
            'DeltaRec','ModeName','SSPName','-v7.3');
    end
end

disp('Finished: ΔRec calculation.');
