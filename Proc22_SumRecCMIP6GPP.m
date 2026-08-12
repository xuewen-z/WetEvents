clear; clc;
addpath(genpath('./'));

% ===============================
% 路径
% ===============================
PathRec = '../output/19_CMIP6ResRec/';
PathOut = '../output/22_SumRecCMIP6GPP/';

system(['rm -rf ', PathOut]);
system(['mkdir -p ', PathOut]);

% ===============================
% 模型 & 时期 & 情景
% ===============================
% ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR'};
ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR','CNRM-ESM2-1','IPSL-CM6A-LR','NorESM2-MM'};

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

            disp(['Processing Rec: ',ModeName,' - ',SSPName,' - ',PeriodName]);

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

                RecYearTotal = [];
                RecYearCnt   = [];
                RecYearLevel = cell(nLevel,1);

                % ---- 等级循环 ----
                for iLev = 1:nLevel
                    RecFile = fullfile(PathRec,ModeName,SSPName,...
                        PeriodName,YearName,...
                        ['YrGPPRec.',LevelNames{iLev},'.mat']);

                    if ~isfile(RecFile), continue; end
                    load(RecFile,'DeltaYear');   % Ω 年尺度

                    RecYearLevel{iLev} = DeltaYear;

                    if isempty(RecYearTotal)
                        RecYearTotal = zeros(size(DeltaYear));
                        RecYearCnt   = zeros(size(DeltaYear));
                    end

                    valid = ~isnan(DeltaYear);
                    RecYearTotal(valid) = RecYearTotal(valid) + DeltaYear(valid);
                    RecYearCnt(valid)   = RecYearCnt(valid) + 1;
                end

                RecYearTotal(RecYearCnt == 0) = NaN;

                save(fullfile(YearPathOut,...
                    ['RecYear_',ModeName,'_',SSPName,'_',PeriodName,'.mat']), ...
                    'RecYearTotal','RecYearLevel', ...
                    'ModeName','SSPName','PeriodName','Year','-v7.3');

                % ---- 多年累计 ----
                if isempty(SumTotal)
                    SumTotal = zeros(size(RecYearTotal));
                    CntTotal = zeros(size(RecYearTotal));
                end

                validT = ~isnan(RecYearTotal);
                SumTotal(validT) = SumTotal(validT) + RecYearTotal(validT);
                CntTotal(validT) = CntTotal(validT) + 1;

                for iLev = 1:nLevel
                    RecLev = RecYearLevel{iLev};
                    if isempty(RecLev), continue; end

                    if isempty(SumLevel{iLev})
                        SumLevel{iLev} = zeros(size(RecLev));
                        CntLevel{iLev} = zeros(size(RecLev));
                    end

                    validL = ~isnan(RecLev);
                    SumLevel{iLev}(validL) = SumLevel{iLev}(validL) + RecLev(validL);
                    CntLevel{iLev}(validL) = CntLevel{iLev}(validL) + 1;
                end
            end

            % ===============================
            % 多年平均（climatology）
            % ===============================
            RecClimTotal = SumTotal ./ CntTotal;
            RecClimTotal(CntTotal == 0) = NaN;

            RecClimLevel = cell(nLevel,1);
            for iLev = 1:nLevel
                RecClimLevel{iLev} = SumLevel{iLev} ./ CntLevel{iLev};
                RecClimLevel{iLev}(CntLevel{iLev} == 0) = NaN;
            end

            % ===============================
            % 保存 climatology（⭐唯一关键修正点）
            % ===============================
            ClimPath = fullfile(PathOut,'Climatology',ModeName,SSPName,PeriodName);
            system(['mkdir -p ',ClimPath]);

            % ---- 总体 ----
            save(fullfile(ClimPath,'RecClimTotal.mat'), ...
                 'RecClimTotal','CntTotal','-v7.3');

            % ---- 分等级 ----
            for iLev = 1:nLevel
                RecClimLev = RecClimLevel{iLev};
                CntLev    = CntLevel{iLev};

                save(fullfile(ClimPath,...
                    ['RecClim.',LevelNames{iLev},'.mat']), ...
                    'RecClimLev','CntLev','-v7.3');
            end
        end
    end
end

disp('Finished: Rec aggregation & climatology.');
