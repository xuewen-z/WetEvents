% ===============================================================
% ProcS_ThresholdSensitivity_Biome.m
% ---------------------------------------------------------------
% 湿润事件识别阈值敏感性分析 —— 生物群系间相对差异比较
%   对每个 Index (Sen/Res/Rec)，逐 biome 计算三个阈值(0.8/1.0/1.2)下的
%   中位数，检查：
%     (1) 各 biome 在三个阈值下的排序(相对大小关系)是否一致
%     (2) 各 biome 内部中位数随阈值变化的幅度
%
%   数据来源：
%     基准(1.0)  : ../output/11_IndexBoxBiome/
%     0.8        : ../output/Threshold_08/11_IndexBoxBiome/
%     1.2        : ../output/Threshold_12/11_IndexBoxBiome/
%
%   输出 : ../output/ThresholdSensitivity/Biome_Median_Comparison.csv
% ===============================================================

clear; clc;
addpath(genpath('./'));

Path_Out = '../output/ThresholdSensitivity/';
system(['mkdir -p ', Path_Out]);

IndexList = {'Sen','Res','Rec'};

PathMap = struct( ...
    'T08','../output/Threshold_08/11_IndexBoxBiome/', ...
    'T10','../output/11_IndexBoxBiome/', ...
    'T12','../output/Threshold_12/11_IndexBoxBiome/' );

VegNames = { ...
    'TrMBF','TrDBF','TrCF','TeBF','TeCF','BoFT', ...
    'TrG','TeG','FlG','MoG','Tu','MeF','DXS','Ma'};

ResultRows = {};

for k = 1:numel(IndexList)
    IndexName = IndexList{k};

    D08 = load([PathMap.T08, IndexName, '_Total.BoxData_Biome.mat']);
    D10 = load([PathMap.T10, IndexName, '_Total.BoxData_Biome.mat']);
    D12 = load([PathMap.T12, IndexName, '_Total.BoxData_Biome.mat']);

    Med08 = nan(numel(VegNames),1);
    Med10 = nan(numel(VegNames),1);
    Med12 = nan(numel(VegNames),1);

    for v = 1:numel(VegNames)
        vn = VegNames{v};

        idx08 = strcmp(D08.BoxLC, vn);
        idx10 = strcmp(D10.BoxLC, vn);
        idx12 = strcmp(D12.BoxLC, vn);

        if any(idx08), Med08(v) = median(D08.BoxVal(idx08),'omitnan'); end
        if any(idx10), Med10(v) = median(D10.BoxVal(idx10),'omitnan'); end
        if any(idx12), Med12(v) = median(D12.BoxVal(idx12),'omitnan'); end
    end

    % ---- 排序一致性: Spearman rank correlation across biomes ----
    valid = isfinite(Med08) & isfinite(Med10) & isfinite(Med12);
    rho_08_10 = corr(Med08(valid), Med10(valid), 'Type','Spearman');
    rho_12_10 = corr(Med12(valid), Med10(valid), 'Type','Spearman');

    fprintf('=== %s: biome-median rank correlation vs baseline ===\n', IndexName);
    fprintf('  SPEI>=0.8 vs 1.0: Spearman rho = %.3f\n', rho_08_10);
    fprintf('  SPEI>=1.2 vs 1.0: Spearman rho = %.3f\n', rho_12_10);

    for v = 1:numel(VegNames)
        ResultRows(end+1,:) = { IndexName, VegNames{v}, Med08(v), Med10(v), Med12(v) }; %#ok<SAGROW>
    end

    ResultRows(end+1,:) = { IndexName, 'SpearmanRho_vs_baseline', rho_08_10, NaN, rho_12_10 }; %#ok<SAGROW>
end

ResultTable = cell2table(ResultRows, ...
    'VariableNames', {'Index','Biome','Median_SPEI08','Median_SPEI10_baseline','Median_SPEI12'});

writetable(ResultTable, [Path_Out,'Biome_Median_Comparison.csv']);

disp('Finished: biome-level threshold sensitivity comparison.');
disp(ResultTable);
