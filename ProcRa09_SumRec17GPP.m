% ===============================================================
% ProcRa09_SumRec17GPP.m
% ---------------------------------------------------------------
% 阈值敏感性分析 (Threshold sensitivity test)
%   使用阈值 : SPEI-03 >= 1.2   (对照原基准 SPEI-03 >= 1.0)
%   对应原始脚本 : Proc09_SumRec17GPP.m
%   测试目的 : 聚合 ProcRa06 (SPEI>=1.2) 输出的逐年 Recovery
%              (Resilience)，计算多年气候态 (Climatology)。
%              计算逻辑与 Proc09 完全一致，仅输入/输出路径
%              重定向。
%   输出目录 : ../output/Threshold_12/09_SumRec17GPP/
% ===============================================================

clear; clc;
addpath(genpath('./'));

% ===============================
% 路径设置（Recovery）
% ===============================
PathRec = '../output/Threshold_12/06_ResRec17GPP/';     % 输入：YrGPPRec.*
PathOut = '../output/Threshold_12/09_SumRec17GPP/';     % 输出：汇总结果

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
    disp(['Processing Recovery aggregation: ', YearName]);

    YearPathOut = [PathOut, YearName, '/'];
    system(['mkdir -p ', YearPathOut]);

    RecYearTotal = [];
    RecYearCnt   = [];

    % ===============================
    % 按等级
    % ===============================
    for iLev = 1:nLevel

        load([PathRec, YearName, '/YrGPPRec.', LevelNames{iLev}, '.mat']);
        % 变量名：DeltaYear
        RecYear = DeltaYear;

        % ---- 保存：该年该等级 ----
        save([YearPathOut,'RecYear.',LevelNames{iLev},'.mat'], ...
             'RecYear','-v7.3');

        % ---- 初始化 ----
        if isempty(RecYearTotal)
            RecYearTotal = zeros(size(RecYear));
            RecYearCnt   = zeros(size(RecYear));
        end

        valid = ~isnan(RecYear);
        RecYearTotal(valid) = RecYearTotal(valid) + RecYear(valid);
        RecYearCnt(valid)   = RecYearCnt(valid) + 1;

        % ---- 多年等级累积 ----
        if isempty(SumLevel{iLev})
            SumLevel{iLev} = zeros(size(RecYear));
            CntLevel{iLev} = zeros(size(RecYear));
        end

        SumLevel{iLev}(valid) = SumLevel{iLev}(valid) + RecYear(valid);
        CntLevel{iLev}(valid) = CntLevel{iLev}(valid) + 1;
    end

    % ===============================
    % 年尺度：所有等级加和
    % ===============================
    RecYearTotal(RecYearCnt == 0) = NaN;

    save([YearPathOut,'RecYear.Total.mat'], ...
         'RecYearTotal','-v7.3');

    % ===============================
    % 多年总累积
    % ===============================
    if isempty(SumTotal)
        SumTotal = zeros(size(RecYearTotal));
        CntTotal = zeros(size(RecYearTotal));
    end

    validT = ~isnan(RecYearTotal);
    SumTotal(validT) = SumTotal(validT) + RecYearTotal(validT);
    CntTotal(validT) = CntTotal(validT) + 1;
end

% ===============================
% 多年平均
% ===============================
PathClim = [PathOut,'Climatology/'];
system(['mkdir -p ', PathClim]);

% ---- 等级内多年平均 ----
for iLev = 1:nLevel
    RecClimLevel = SumLevel{iLev} ./ CntLevel{iLev};
    RecClimLevel(CntLevel{iLev} == 0) = NaN;

    save([PathClim,'RecClim.',LevelNames{iLev},'.mat'], ...
         'RecClimLevel','-v7.3');
end

% ---- 总体多年平均 ----
RecClimTotal = SumTotal ./ CntTotal;
RecClimTotal(CntTotal == 0) = NaN;

save([PathClim,'RecClim.Total.mat'], ...
     'RecClimTotal','-v7.3');

disp('Finished: Recovery aggregation & climatology. (Threshold_12, SPEI-03 >= 1.2)');
