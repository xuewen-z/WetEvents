clear; clc;
addpath(genpath('./'));

PathRes = '../output/21_SumResCMIP6GPP/Climatology/';
PathOut = '../output/24_DeffResCMIP6GPP/';

system(['rm -rf ',PathOut]);
system(['mkdir -p ',PathOut]);

ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR'};
SSPList  = {'ssp126','ssp245','ssp370','ssp585'};

for i = 1:numel(ModeList)
    ModeName = ModeList{i};

    % ===============================
    % 历史基线
    % ===============================
    BasePath = fullfile(PathRes,ModeName,'historical','baseline');
    load(fullfile(BasePath,'ResClimTotal.mat'),'ResClimTotal');
    ResBase = ResClimTotal;

    % ---- 物理约束（理论上不会触发，仅保险）----
    ResBase(ResBase <= 0) = NaN;
    LogResBase = log(ResBase);

    for s = 1:numel(SSPList)
        SSPName = SSPList{s};

        FutPath = fullfile(PathRes,ModeName,SSPName,'future');
        system(['mkdir -p ',fullfile(PathOut,ModeName,SSPName)]);

        load(fullfile(FutPath,'ResClimTotal.mat'),'ResClimTotal');
        ResFut = ResClimTotal;

        ResFut(ResFut <= 0) = NaN;
        LogResFut = log(ResFut);

        % ===============================
        % Δlog(Res) —— 关键修改点
        % ===============================
        OmegaRes = LogResFut - LogResBase;

        OmegaRes(~isfinite(OmegaRes)) = NaN;

        save(fullfile(PathOut,ModeName,SSPName,'OmegaRes.mat'), ...
            'OmegaRes','ModeName','SSPName','-v7.3');
    end
end

disp('Finished: Δlog(Res) calculation (physically & statistically consistent).');
