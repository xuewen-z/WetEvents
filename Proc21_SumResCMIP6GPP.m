clear; clc;
addpath(genpath('./'));

% ===============================
% 路径
% ===============================
PathRes = '../output/19_CMIP6ResRec/';   % Res / Rec 原始结果
PathOut = '../output/21_SumResCMIP6GPP/';   % Res 汇总输出

system(['rm -rf ', PathOut]);
system(['mkdir -p ', PathOut]);

% ===============================
% 模型 & 时期 & 情景
% ===============================
ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR'};

PeriodList = { ...
    struct('name','baseline','years',1981:2010,'SSPList',{{'historical'}}), ...
    struct('name','future','years',2071:2100,'SSPList',{{'ssp126','ssp245','ssp370','ssp585'}}) ...
};

LevelNames = {'Moderate','Severe','Extreme'};
nLevel = numel(LevelNames);

% ===============================
% 主循环
% ===============================
for i = 1:numel(ModeList)
    ModeName = ModeList{i};

    for p = 1:numel(PeriodList)
        PeriodName = PeriodList{p}.name;
        Years      = PeriodList{p}.years;
        SSPListUse = PeriodList{p}.SSPList;

        for s = 1:numel(SSPListUse)
            SSPName = SSPListUse{s};

            disp(['Processing Res: ',ModeName,' - ',SSPName,' - ',PeriodName]);

            % === 多年累计器 ===
            SumTotal = [];  CntTotal = [];
            SumLevel = cell(nLevel,1);
            CntLevel = cell(nLevel,1);

            % ===============================
            % 年循环
            % ===============================
            for y = 1:numel(Years)
                Year = Years(y);
                YearName = num2str(Year);

                YearPathOut = fullfile(PathOut,YearName);
                system(['mkdir -p ',YearPathOut]);

                ResYearTotal = [];
                ResYearCnt   = [];
                ResYearLevel = cell(nLevel,1);

                % ---- 等级循环 ----
                for iLev = 1:nLevel
                    ResFile = fullfile(PathRes,ModeName,SSPName,...
                        PeriodName,YearName,...
                        ['YrGPPRes.',LevelNames{iLev},'.mat']);

                    if ~isfile(ResFile), continue; end
                    load(ResFile,'OmegaYear');   % Ω 年尺度

                    ResYearLevel{iLev} = OmegaYear;

                    if isempty(ResYearTotal)
                        ResYearTotal = zeros(size(OmegaYear));
                        ResYearCnt   = zeros(size(OmegaYear));
                    end

                    valid = ~isnan(OmegaYear);
                    ResYearTotal(valid) = ResYearTotal(valid) + OmegaYear(valid);
                    ResYearCnt(valid)   = ResYearCnt(valid) + 1;
                end

                ResYearTotal(ResYearCnt == 0) = NaN;

                save(fullfile(YearPathOut,...
                    ['ResYear_',ModeName,'_',SSPName,'_',PeriodName,'.mat']), ...
                    'ResYearTotal','ResYearLevel', ...
                    'ModeName','SSPName','PeriodName','Year','-v7.3');

                % ---- 多年累计 ----
                if isempty(SumTotal)
                    SumTotal = zeros(size(ResYearTotal));
                    CntTotal = zeros(size(ResYearTotal));
                end

                validT = ~isnan(ResYearTotal);
                SumTotal(validT) = SumTotal(validT) + ResYearTotal(validT);
                CntTotal(validT) = CntTotal(validT) + 1;

                for iLev = 1:nLevel
                    ResLev = ResYearLevel{iLev};
                    if isempty(ResLev), continue; end

                    if isempty(SumLevel{iLev})
                        SumLevel{iLev} = zeros(size(ResLev));
                        CntLevel{iLev} = zeros(size(ResLev));
                    end

                    validL = ~isnan(ResLev);
                    SumLevel{iLev}(validL) = SumLevel{iLev}(validL) + ResLev(validL);
                    CntLevel{iLev}(validL) = CntLevel{iLev}(validL) + 1;
                end
            end

            % ===============================
            % 多年平均（climatology）
            % ===============================
            ResClimTotal = SumTotal ./ CntTotal;
            ResClimTotal(CntTotal == 0) = NaN;

            ResClimLevel = cell(nLevel,1);
            for iLev = 1:nLevel
                ResClimLevel{iLev} = SumLevel{iLev} ./ CntLevel{iLev};
                ResClimLevel{iLev}(CntLevel{iLev} == 0) = NaN;
            end

            % ===============================
            % 保存 climatology（⭐唯一关键修正点）
            % ===============================
            ClimPath = fullfile(PathOut,'Climatology',ModeName,SSPName,PeriodName);
            system(['mkdir -p ',ClimPath]);

            % ---- 总体 ----
            save(fullfile(ClimPath,'ResClimTotal.mat'), ...
                 'ResClimTotal','CntTotal','-v7.3');

            % ---- 分等级 ----
            for iLev = 1:nLevel
                ResClimLev = ResClimLevel{iLev};
                CntLev    = CntLevel{iLev};

                save(fullfile(ClimPath,...
                    ['ResClim.',LevelNames{iLev},'.mat']), ...
                    'ResClimLev','CntLev','-v7.3');
            end
        end
    end
end

disp('Finished: Res aggregation & climatology.');
