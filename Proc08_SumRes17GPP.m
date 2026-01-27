clear; clc;
addpath(genpath('./'));

% ===============================
% 路径设置（Resistance）
% ===============================
PathRes   = '../output/06_ResRec17GPP/';     % 输入：YrGPPRes.*
PathOut = '../output/08_SumRes17GPP/';     % 输出：汇总结果

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
    disp(['Processing Resistance aggregation: ', YearName]);

    YearPathOut = [PathOut, YearName, '/'];
    system(['mkdir -p ', YearPathOut]);

    ResYearTotal = [];
    ResYearCnt   = [];

    % ===============================
    % 按等级
    % ===============================
    for iLev = 1:nLevel

        load([PathRes, YearName, '/YrGPPRes.', LevelNames{iLev}, '.mat']);
        % 变量名：OmegaYear
        ResYear = OmegaYear;

        % ---- 保存：该年该等级 ----
        save([YearPathOut,'ResYear.',LevelNames{iLev},'.mat'], ...
             'ResYear','-v7.3');

        % ---- 初始化 ----
        if isempty(ResYearTotal)
            ResYearTotal = zeros(size(ResYear));
            ResYearCnt   = zeros(size(ResYear));
        end

        valid = ~isnan(ResYear);
        ResYearTotal(valid) = ResYearTotal(valid) + ResYear(valid);
        ResYearCnt(valid)   = ResYearCnt(valid) + 1;

        % ---- 多年等级累积 ----
        if isempty(SumLevel{iLev})
            SumLevel{iLev} = zeros(size(ResYear));
            CntLevel{iLev} = zeros(size(ResYear));
        end

        SumLevel{iLev}(valid) = SumLevel{iLev}(valid) + ResYear(valid);
        CntLevel{iLev}(valid) = CntLevel{iLev}(valid) + 1;
    end

    % ===============================
    % 年尺度：所有等级加和
    % ===============================
    ResYearTotal(ResYearCnt == 0) = NaN;

    save([YearPathOut,'ResYear.Total.mat'], ...
         'ResYearTotal','-v7.3');

    % ===============================
    % 多年总累积
    % ===============================
    if isempty(SumTotal)
        SumTotal = zeros(size(ResYearTotal));
        CntTotal = zeros(size(ResYearTotal));
    end

    validT = ~isnan(ResYearTotal);
    SumTotal(validT) = SumTotal(validT) + ResYearTotal(validT);
    CntTotal(validT) = CntTotal(validT) + 1;
end

% ===============================
% 多年平均
% ===============================
PathClim = [PathOut,'Climatology/'];
system(['mkdir -p ', PathClim]);

% ---- 等级内多年平均 ----
for iLev = 1:nLevel
    ResClimLevel = SumLevel{iLev} ./ CntLevel{iLev};
    ResClimLevel(CntLevel{iLev} == 0) = NaN;

    save([PathClim,'ResClim.',LevelNames{iLev},'.mat'], ...
         'ResClimLevel','-v7.3');
end

% ---- 总体多年平均 ----
ResClimTotal = SumTotal ./ CntTotal;
ResClimTotal(CntTotal == 0) = NaN;

save([PathClim,'ResClim.Total.mat'], ...
     'ResClimTotal','-v7.3');

disp('Finished: Resistance aggregation & climatology.');
