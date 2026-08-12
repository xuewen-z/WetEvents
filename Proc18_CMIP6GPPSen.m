clear; clc;
addpath(genpath('./'));

% ===============================
% 路径设置
% ===============================
PathLandCover = '../input/';
PathGPP       = '../output/14_CMIP6TIF_05DEG/';
PathSPEI      = '../output/16_CMIP6SPEI_05DEG/';
PathGPPnor    = '../output/17_CMIP6MonGPPnormal/';
PathGPPSen    = '../output/18_CMIP6GPPSen/';

system(['rm -rf ', PathGPPSen]);
system(['mkdir -p ', PathGPPSen]);

% ===============================
% 读取土地覆盖与掩膜
% ===============================
RefeName = [PathLandCover,...
    'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];

[LandCover, R] = readgeoraster(RefeName);
LandCover = double(LandCover);

Mask = (LandCover >= 1 & LandCover <= 10);
[nRow, nCol] = size(LandCover);

% ===============================
% 模型
% ===============================
ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR','CNRM-ESM2-1','IPSL-CM6A-LR','NorESM2-MM'};

% ===============================
% 时期定义（关键）
% ===============================
PeriodList = { ...
    struct('name','baseline', ...
           'years',1981:2010, ...
           'SSPList',{{'historical'}}), ...
    struct('name','future', ...
           'years',2071:2100, ...
           'SSPList',{{'ssp126','ssp245','ssp370','ssp585'}}) ...
};

% ===============================
% SPEI 等级
% ===============================
LevelList  = {[1.0,1.5], [1.5,2.0], [2.0,inf]};
LevelNames = {'Moderate','Severe','Extreme'};
nLevel     = numel(LevelList);

GPPmin = 0.1; 
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

            disp(['Processing: ',ModeName,' - ',SSPName,' - ',PeriodName]);

            % === 读取对应时期的 GPPnormal ===
            load(fullfile(PathGPPnor,ModeName,SSPName,...
                ['MonGPPnormal_',PeriodName,'.mat']), 'GPPnormal');
            % GPPnormal (nRow × nCol × 12)

            for y = 1:numel(Years)
                Year = Years(y);
                YearName = num2str(Year);

                YearPath = fullfile(PathGPPSen,ModeName,SSPName,PeriodName,YearName);
                system(['mkdir -p ', YearPath]);

                % ---- 读取 SPEI ----
                SPEIfile = fullfile(PathSPEI,ModeName,SSPName,...
                    [ModeName,'_SPEI_3_',SSPName,'_',YearName,'.MonSPEI_050DEG.tif']);
                MonSPEI = double(readgeoraster(SPEIfile));

                % ---- 读取 GPP ----
                GPPfile = fullfile(PathGPP,ModeName,SSPName,...
                    ['CMIP6.',ModeName,'.MonGPP.',YearName,'.tif']);
                GPPmonth = double(readgeoraster(GPPfile));

                % ===============================
                % 按湿润等级计算 Sen
                % ===============================
                for iLev = 1:nLevel

                    Range = LevelList{iLev};
                    SenMonth = nan(nRow, nCol, 12);

                    for m = 1:12
                        SPEIm = MonSPEI(:,:,m);
                        GPPm  = GPPmonth(:,:,m);
                        GPPn  = GPPnormal(:,:,m);

                        LevMask = ...
                            Mask & ...
                            SPEIm >= Range(1) & SPEIm < Range(2) & GPPn > GPPmin;

                        if any(LevMask(:))
                            Temp = nan(nRow, nCol);
                            Temp(LevMask) = ...
                                (GPPm(LevMask) - GPPn(LevMask)) ./ ...
                                (GPPn(LevMask) .* SPEIm(LevMask));
                            SenMonth(:,:,m) = Temp;
                        end
                    end

                    % 年尺度 Sen
                    SenYear = mean(SenMonth, 3, 'omitnan');

                    % ---- 保存 ----
                    save(fullfile(YearPath,...
                        ['YrGPPSen.',LevelNames{iLev},'.mat']), ...
                        'SenYear','SenMonth','-v7.3');
                end
            end
        end
    end
end
