% ===============================================================
% ProcRa07_SumSen17GPP.m
% ---------------------------------------------------------------
% 阈值敏感性分析 (Threshold sensitivity test)
%   使用阈值 : SPEI-03 >= 1.2   (对照原基准 SPEI-03 >= 1.0)
%   对应原始脚本 : Proc07_SumSen17GPP.m
%   测试目的 : 聚合 ProcRa05 (SPEI>=1.2) 输出的逐年 Sensitivity，
%              计算多年气候态 (Climatology)。计算逻辑与
%              Proc07 完全一致，仅输入/输出路径重定向。
%   输出目录 : ../output/Threshold_12/07_SumSen17GPP/
% ===============================================================

clear; clc;
addpath(genpath('./'));

% ===============================
% 路径设置（以 Sensitivity 为例）
% ===============================
PathSen = '../output/Threshold_12/05_Sen17GPP/';      % 输入：YrGPPSen.*
PathOut = '../output/Threshold_12/07_SumSen17GPP/';   % 输出：汇总结果

system(['rm -rf ', PathOut]);
system(['mkdir -p ', PathOut]);

% ===============================
% 时间 & 等级
% ===============================
Years      = 2001:2022;
LevelNames = {'Moderate','Severe','Extreme'};
nLevel     = length(LevelNames);

% ===============================
% 初始化多年累计
% ===============================
SumTotal = [];
CntTotal = [];

SumLevel = cell(nLevel,1);
CntLevel = cell(nLevel,1);

% ===============================
% 主循环：逐年
% ===============================
for y = 1:length(Years)

    Year     = Years(y);
    YearName = num2str(Year);
    disp(['Processing aggregation: ', YearName]);

    YearPathOut = [PathOut, YearName, '/'];
    system(['mkdir -p ', YearPathOut]);

    SenYearTotal = [];
    SenYearCnt   = [];

    % ===============================
    % 按等级
    % ===============================
    for iLev = 1:nLevel

        load([PathSen, YearName, '/YrGPPSen.', LevelNames{iLev}, '.mat']);
        % 假定变量名为 SenYear (nRow × nCol)
        SenYear = SenYear;

        % ---- 保存：该年该等级 ----
        save([YearPathOut,'SenYear.',LevelNames{iLev},'.mat'], ...
             'SenYear','-v7.3');

        % ---- 初始化 ----
        if isempty(SenYearTotal)
            SenYearTotal = zeros(size(SenYear));
            SenYearCnt   = zeros(size(SenYear));
        end

        valid = ~isnan(SenYear);
        SenYearTotal(valid) = SenYearTotal(valid) + SenYear(valid);
        SenYearCnt(valid)   = SenYearCnt(valid) + 1;

        % ---- 多年等级累积 ----
        if isempty(SumLevel{iLev})
            SumLevel{iLev} = zeros(size(SenYear));
            CntLevel{iLev} = zeros(size(SenYear));
        end

        SumLevel{iLev}(valid) = SumLevel{iLev}(valid) + SenYear(valid);
        CntLevel{iLev}(valid) = CntLevel{iLev}(valid) + 1;
    end

    % ===============================
    % 年尺度：所有等级加和
    % ===============================
    SenYearTotal(SenYearCnt == 0) = NaN;

    save([YearPathOut,'SenYear.Total.mat'], ...
         'SenYearTotal','-v7.3');

    % ===============================
    % 多年总累积
    % ===============================
    if isempty(SumTotal)
        SumTotal = zeros(size(SenYearTotal));
        CntTotal = zeros(size(SenYearTotal));
    end

    validT = ~isnan(SenYearTotal);
    SumTotal(validT) = SumTotal(validT) + SenYearTotal(validT);
    CntTotal(validT) = CntTotal(validT) + 1;
end

% ===============================
% 多年平均
% ===============================
PathClim = [PathOut,'Climatology/'];
system(['mkdir -p ', PathClim]);

% ---- 等级内多年平均 ----
for iLev = 1:nLevel
    SenClimLevel = SumLevel{iLev} ./ CntLevel{iLev};
    SenClimLevel(CntLevel{iLev} == 0) = NaN;

    save([PathClim,'SenClim.',LevelNames{iLev},'.mat'], ...
         'SenClimLevel','-v7.3');
end

% ---- 总体多年平均 ----
SenClimTotal = SumTotal ./ CntTotal;
SenClimTotal(CntTotal == 0) = NaN;

save([PathClim,'SenClim.Total.mat'], ...
     'SenClimTotal','-v7.3');

disp('Finished: aggregation & climatology. (Threshold_12, SPEI-03 >= 1.2)');
