clear; clc;
addpath(genpath('./'));

% ===============================
% 路径
% ===============================
PathSen = '../output/18_CMIP6GPPSen/';     % Sen 原始结果
PathOut = '../output/20_SumSenCMIP6GPP/';     % 汇总输出

system(['rm -rf ', PathOut]);
system(['mkdir -p ', PathOut]);

% ===============================
% 模型 & 时期 & 情景
% ===============================
% ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR'};
ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR','CNRM-ESM2-1','IPSL-CM6A-LR','NorESM2-MM'};

PeriodList = { ...
    struct('name','baseline', ...
           'years',1981:2010, ...
           'SSPList',{{'historical'}}), ...
    struct('name','future', ...
           'years',2071:2100, ...
           'SSPList',{{'ssp126','ssp245','ssp370','ssp585'}}) ...
};

LevelNames = {'Moderate','Severe','Extreme'};
nLevel = numel(LevelNames);

% ===============================
% 主循环：Model × Period × SSP
% ===============================
for i = 1:numel(ModeList)
    ModeName = ModeList{i};

    for p = 1:numel(PeriodList)

        PeriodName = PeriodList{p}.name;
        Years      = PeriodList{p}.years;
        SSPListUse = PeriodList{p}.SSPList;

        for s = 1:numel(SSPListUse)
            SSPName = SSPListUse{s};

            disp(['Processing climatology: ',ModeName,' - ',SSPName,' - ',PeriodName]);

            % ===============================
            % 初始化多年累计器（关键！）
            % ===============================
            SumTotal = [];
            CntTotal = [];

            SumLevel = cell(nLevel,1);
            CntLevel = cell(nLevel,1);

            % ===============================
            % 年循环
            % ===============================
            for y = 1:numel(Years)

                Year = Years(y);
                YearName = num2str(Year);

                disp(['  Aggregating year: ',YearName]);

                YearPathOut = fullfile(PathOut,YearName);
                system(['mkdir -p ',YearPathOut]);

                SenYearTotal = [];
                SenYearCnt   = [];
                SenYearLevel = cell(nLevel,1);

                % ===============================
                % 按等级读取 Sen
                % ===============================
                for iLev = 1:nLevel

                    SenFile = fullfile(PathSen,ModeName,SSPName,...
                        PeriodName,YearName,...
                        ['YrGPPSen.',LevelNames{iLev},'.mat']);

                    if ~isfile(SenFile)
                        continue;
                    end

                    load(SenFile,'SenYear');   % nRow × nCol
                    SenYearLevel{iLev} = SenYear;

                    if isempty(SenYearTotal)
                        SenYearTotal = zeros(size(SenYear));
                        SenYearCnt   = zeros(size(SenYear));
                    end

                    valid = ~isnan(SenYear);
                    SenYearTotal(valid) = SenYearTotal(valid) + SenYear(valid);
                    SenYearCnt(valid)   = SenYearCnt(valid) + 1;
                end

                % ===============================
                % 年内等级加和
                % ===============================
                SenYearTotal(SenYearCnt == 0) = NaN;

                % ===============================
                % 保存逐年结果
                % ===============================
                save(fullfile(YearPathOut,...
                    ['SenYear_',ModeName,'_',SSPName,'_',PeriodName,'.mat']), ...
                    'SenYearTotal','SenYearLevel', ...
                    'ModeName','SSPName','PeriodName','Year', ...
                    '-v7.3');

                % ===============================
                % === 多年累计（就在这里加）===
                % ===============================
                if isempty(SumTotal)
                    SumTotal = zeros(size(SenYearTotal));
                    CntTotal = zeros(size(SenYearTotal));
                end

                validT = ~isnan(SenYearTotal);
                SumTotal(validT) = SumTotal(validT) + SenYearTotal(validT);
                CntTotal(validT) = CntTotal(validT) + 1;

                for iLev = 1:nLevel
                    SenLev = SenYearLevel{iLev};
                    if isempty(SenLev), continue; end

                    if isempty(SumLevel{iLev})
                        SumLevel{iLev} = zeros(size(SenLev));
                        CntLevel{iLev} = zeros(size(SenLev));
                    end

                    validL = ~isnan(SenLev);
                    SumLevel{iLev}(validL) = SumLevel{iLev}(validL) + SenLev(validL);
                    CntLevel{iLev}(validL) = CntLevel{iLev}(validL) + 1;
                end
            end

            % ===============================
            % === 多年平均（period climatology）===
            % ===============================
            SenClimTotal = SumTotal ./ CntTotal;
            SenClimTotal(CntTotal == 0) = NaN;

            SenClimLevel = cell(nLevel,1);
            for iLev = 1:nLevel
                SenClimLevel{iLev} = SumLevel{iLev} ./ CntLevel{iLev};
                SenClimLevel{iLev}(CntLevel{iLev} == 0) = NaN;
            end

            % ===============================
            % 保存多年平均
            % ===============================
            ClimPath = fullfile(PathOut,'Climatology',ModeName,SSPName,PeriodName);
            system(['mkdir -p ',ClimPath]);

            save(fullfile(ClimPath,'SenClimTotal.mat'), ...
                 'SenClimTotal','CntTotal', ...
                 'ModeName','SSPName','PeriodName','-v7.3');

            for iLev = 1:nLevel
                save(fullfile(ClimPath,...
                    ['SenClim.',LevelNames{iLev},'.mat']), ...
                    'SenClimLevel','CntLevel', ...
                    'ModeName','SSPName','PeriodName','-v7.3');
            end
        end
    end
end

disp('Finished: yearly aggregation + period climatology.');
