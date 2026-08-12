% ===============================================================
% ProcRa11_IndexBoxBiome.m
% ---------------------------------------------------------------
% 阈值敏感性分析 (Threshold sensitivity test)
%   使用阈值 : SPEI-03 >= 1.2   (对照原基准 SPEI-03 >= 1.0)
%   对应原始脚本 : Proc11_IndexBoxBiome.m
%   测试目的 : 基于 ProcRa07/ProcRa08/ProcRa09 (SPEI>=1.2) 的
%              气候态结果，按 14 个生物群系提取 Sensitivity/
%              Resistance/Resilience 的箱线图数据，用于检验不同
%              阈值下各生态系统间相对差异是否保持一致。计算逻辑
%              与 Proc11 完全一致，仅输入/输出路径重定向。
%   输出目录 : ../output/Threshold_12/11_IndexBoxBiome/
% ===============================================================

clear; clc;
addpath(genpath('./'));

Path_LandCover = '../input/';
Path_Boxdata   = '../output/Threshold_12/11_IndexBoxBiome/';

system(['rm -rf ',Path_Boxdata]);
system(['mkdir -p ',Path_Boxdata]);

% ===============================
% 指标与路径设置
% ===============================
IndexList = {'Sen','Res','Rec'};

IndexPathMap = struct( ...
    'Sen','../output/Threshold_12/07_SumSen17GPP/Climatology/', ...
    'Res','../output/Threshold_12/08_SumRes17GPP/Climatology/', ...
    'Rec','../output/Threshold_12/09_SumRec17GPP/Climatology/' );

LevelNames = {'Moderate','Severe','Extreme','Total'};

% ===============================
% 读取 biome（14 类）
% ===============================
RefeName = [Path_LandCover,'WWF_TerrEcosBIome14_CMG050DEG.tif'];
[LandCover,R] = readgeoraster(RefeName);
Proj = geotiffinfo(RefeName);

VegTypes = 1:14;
VegNames = { ...
    'TrMBF','TrDBF','TrCF','TeBF','TeCF','BoFT', ...
    'TrG','TeG','FlG','MoG','Tu','MeF','DXS','Ma'};

nType = numel(VegTypes);

% ===============================
% 主循环：Index × Level
% ===============================
for k = 1:numel(IndexList)

    IndexName = IndexList{k};
    IndexPath = IndexPathMap.(IndexName);

    for l = 1:numel(LevelNames)

        LevName = LevelNames{l};
        disp(['Processing ',IndexName,' - ',LevName]);

        % ===============================
        % 读取多年平均数据
        % ===============================
        load([IndexPath,IndexName,'Clim.',LevName,'.mat']);

        % === 统一变量名 ===
        switch IndexName
            case 'Sen'
                if strcmp(LevName,'Total')
                    ValMap = SenClimTotal;
                else
                    ValMap = SenClimLevel;
                end
            case 'Res'
                if strcmp(LevName,'Total')
                    ValMap = ResClimTotal;
                else
                    ValMap = ResClimLevel;
                end
            case 'Rec'
                if strcmp(LevName,'Total')
                    ValMap = RecClimTotal;
                else
                    ValMap = RecClimLevel;
                end
        end

        % ===============================
        % 有效掩膜
        % ===============================
        mask_valid = isfinite(ValMap) & isfinite(LandCover);
        V  = ValMap(mask_valid);
        LC = LandCover(mask_valid);

        % ===============================
        % 组织 box 数据
        % ===============================
        BoxLC  = [];
        BoxVal = [];

        for i = 1:nType
            id  = VegTypes(i);
            idx = (LC == id);
            if any(idx)
                BoxLC  = [BoxLC;  repmat(VegNames(i), sum(idx), 1)];
                BoxVal = [BoxVal; V(idx)];
            end
        end

        % ===============================
        % 保存
        % ===============================
        save([Path_Boxdata,IndexName,'_',LevName,'.BoxData_Biome.mat'], ...
             'BoxLC','BoxVal','-v7.3');

    end
end
