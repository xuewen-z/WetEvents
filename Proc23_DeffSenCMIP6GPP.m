clear; clc;
addpath(genpath('./'));

PathSen = '../output/20_SumSenCMIP6GPP/Climatology/';   % ★ 敏感性路径
PathOut = '../output/23_DeffSenCMIP6GPP/';

system(['rm -rf ',PathOut]);
system(['mkdir -p ',PathOut]);

% ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR'};
ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR','CNRM-ESM2-1','IPSL-CM6A-LR','NorESM2-MM'};

SSPList  = {'ssp126','ssp245','ssp370','ssp585'};

for i = 1:numel(ModeList)
    ModeName = ModeList{i};

    % ===============================
    % 历史基线（Sensitivity）
    % ===============================
    BasePath = fullfile(PathSen,ModeName,'historical','baseline');
    load(fullfile(BasePath,'SenClimTotal.mat'),'SenClimTotal');
    SenBase = SenClimTotal;

    % ---- 物理约束（仅清除非法值）----
    SenBase(~isfinite(SenBase)) = NaN;

    for s = 1:numel(SSPList)
        SSPName = SSPList{s};

        FutPath = fullfile(PathSen,ModeName,SSPName,'future');
        system(['mkdir -p ',fullfile(PathOut,ModeName,SSPName)]);

        load(fullfile(FutPath,'SenClimTotal.mat'),'SenClimTotal');
        SenFut = SenClimTotal;

        SenFut(~isfinite(SenFut)) = NaN;

        % ===============================
        % ΔSensitivity —— 正确做法
        % ===============================
        DeltaSen = SenFut - SenBase;

        DeltaSen(~isfinite(DeltaSen)) = NaN;

        save(fullfile(PathOut,ModeName,SSPName,'DeltaSen.mat'), ...
            'DeltaSen','ModeName','SSPName','-v7.3');
    end
end

disp('Finished: ΔSensitivity calculation (physically consistent).');
