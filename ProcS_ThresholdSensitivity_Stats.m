% ===============================================================
% ProcS_ThresholdSensitivity_Stats.m
% ---------------------------------------------------------------
% 湿润事件识别阈值敏感性分析 —— 统计部分
%   对照方案 : SPEI-03 >= 1.0  (baseline, 原有 Proc05-11 结果)
%   替代方案 : SPEI-03 >= 0.8  (ProcR05-11 结果, output/Threshold_08/)
%              SPEI-03 >= 1.2  (ProcRa05-11 结果, output/Threshold_12/)
%
%   本脚本不改变任何原始计算逻辑，仅读取三套阈值已生成的结果，
%   完成以下统计：
%     (1) 三个阈值下湿润事件（像元-月）识别数量及空间分布
%     (2) Sensitivity / Resistance / Resilience 在 0.8 和 1.2
%         阈值下与基准(1.0)结果的空间 Pearson r、p 值、RMSE、MAE
%     (3) 输出统计结果表 CSV
%
%   输出目录 : ../output/ThresholdSensitivity/
% ===============================================================

clear; clc;
addpath(genpath('./'));

Path_LandCover = '../input/';
Path_SPEIts    = '../output/03_MulSPEIts/';   % 连续 SPEI 值，阈值无关
Path_Out       = '../output/ThresholdSensitivity/';

system(['rm -rf ', Path_Out]);
system(['mkdir -p ', Path_Out]);

Years = 2001:2022;

RefeName = [Path_LandCover,'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];
[LandCover, R] = readgeoraster(RefeName);
LandCover = double(LandCover);
Mask = (LandCover >= 1 & LandCover <= 10);   % 自然植被，同 Proc05/06

% ===============================================================
% (1) 湿润事件（像元-月）识别数量统计
% ===============================================================
Thresholds = [0.8, 1.0, 1.2];
ThreshNames = {'SPEI08','SPEI10','SPEI12'};

EventCountByYear = zeros(numel(Years), numel(Thresholds));
EventMapTotal    = cell(numel(Thresholds),1);   % 每阈值：22年累计湿润月数空间分布

for th = 1:numel(Thresholds)
    EventMapTotal{th} = zeros(size(LandCover));
end

for y = 1:numel(Years)
    Year = Years(y);
    YearName = num2str(Year);
    load([Path_SPEIts,'spei03.MonSPEI',YearName,'.mat']);   % MonSPEI: nRow x nCol x 12

    for th = 1:numel(Thresholds)
        WetMask3D = (MonSPEI >= Thresholds(th)) & repmat(Mask,[1 1 size(MonSPEI,3)]);
        EventCountByYear(y,th) = sum(WetMask3D(:));
        EventMapTotal{th} = EventMapTotal{th} + sum(WetMask3D,3);
    end
end

EventCountSummary = table(Years(:), EventCountByYear(:,1), EventCountByYear(:,2), EventCountByYear(:,3), ...
    'VariableNames', {'Year','NPixelMonths_SPEI08','NPixelMonths_SPEI10','NPixelMonths_SPEI12'});

writetable(EventCountSummary, [Path_Out,'WetEvent_PixelMonth_Count_ByYear.csv']);

TotalEvents = sum(EventCountByYear,1);
fprintf('Total wet-event pixel-months 2001-2022:\n');
fprintf('  SPEI-03 >= 0.8 : %d  (%.1f%% relative to baseline)\n', TotalEvents(1), 100*TotalEvents(1)/TotalEvents(2));
fprintf('  SPEI-03 >= 1.0 : %d  (baseline)\n', TotalEvents(2));
fprintf('  SPEI-03 >= 1.2 : %d  (%.1f%% relative to baseline)\n', TotalEvents(3), 100*TotalEvents(3)/TotalEvents(2));

save([Path_Out,'WetEvent_SpatialCount_Maps.mat'], 'EventMapTotal','Thresholds','ThreshNames','-v7.3');

% ===============================================================
% (2) Sensitivity / Resistance / Resilience 空间格局比较
% ===============================================================
IndexList  = {'Sen','Res','Rec'};
IndexFile  = struct('Sen','SenClim.Total.mat','Res','ResClim.Total.mat','Rec','RecClim.Total.mat');
IndexVar   = struct('Sen','SenClimTotal','Res','ResClimTotal','Rec','RecClimTotal');

PathBaseline = struct( ...
    'Sen','../output/07_SumSen17GPP/Climatology/', ...
    'Res','../output/08_SumRes17GPP/Climatology/', ...
    'Rec','../output/09_SumRec17GPP/Climatology/' );

Path08 = struct( ...
    'Sen','../output/Threshold_08/07_SumSen17GPP/Climatology/', ...
    'Res','../output/Threshold_08/08_SumRes17GPP/Climatology/', ...
    'Rec','../output/Threshold_08/09_SumRec17GPP/Climatology/' );

Path12 = struct( ...
    'Sen','../output/Threshold_12/07_SumSen17GPP/Climatology/', ...
    'Res','../output/Threshold_12/08_SumRes17GPP/Climatology/', ...
    'Rec','../output/Threshold_12/09_SumRec17GPP/Climatology/' );

ResultRows = {};   % accumulate rows for the summary table

DataStore = struct();   % keep loaded maps for later figure script reuse

for k = 1:numel(IndexList)
    IndexName = IndexList{k};
    fn = IndexFile.(IndexName);
    vn = IndexVar.(IndexName);

    Sb = load([PathBaseline.(IndexName), fn]);  MapBase = Sb.(vn);
    S8 = load([Path08.(IndexName), fn]);        Map08   = S8.(vn);
    S12 = load([Path12.(IndexName), fn]);       Map12   = S12.(vn);

    DataStore.(IndexName).Base = MapBase;
    DataStore.(IndexName).T08  = Map08;
    DataStore.(IndexName).T12  = Map12;

    AltMaps  = {Map08, Map12};
    AltNames = {'SPEI>=0.8','SPEI>=1.2'};

    for a = 1:numel(AltMaps)
        MapAlt = AltMaps{a};

        validCommon = isfinite(MapBase) & isfinite(MapAlt) & Mask;
        v1 = MapBase(validCommon);
        v2 = MapAlt(validCommon);

        n = numel(v1);
        [r,p] = corr(v1, v2, 'Type','Pearson');
        RMSE = sqrt(mean((v1-v2).^2));
        MAE  = mean(abs(v1-v2));

        fprintf('%s vs baseline (%s): N=%d r=%.3f p=%.3g RMSE=%.4f MAE=%.4f\n', ...
            IndexName, AltNames{a}, n, r, p, RMSE, MAE);

        ResultRows(end+1,:) = { IndexName, AltNames{a}, n, r, p, RMSE, MAE }; %#ok<SAGROW>
    end
end

ResultTable = cell2table(ResultRows, ...
    'VariableNames', {'Index','AlternativeThreshold','N_CommonValidPixels','PearsonR','PValue','RMSE','MAE'});

writetable(ResultTable, [Path_Out,'ThresholdSensitivity_SpatialComparison.csv']);

save([Path_Out,'ThresholdSensitivity_DataStore.mat'], 'DataStore','LandCover','R','Mask','-v7.3');

disp('Finished: threshold sensitivity statistics.');
disp(ResultTable);
