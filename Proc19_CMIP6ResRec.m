clear; clc;
addpath(genpath('./'));

% ===============================
% 路径设置
% ===============================
PathLandCover = '../input/';
PathGPP       = '../output/14_CMIP6TIF_05DEG/';
PathSPEI      = '../output/16_CMIP6SPEI_05DEG/';
PathGPPnor    = '../output/17_CMIP6MonGPPnormal/';
PathResRec    = '../output/19_CMIP6ResRec/';

system(['rm -rf ', PathResRec]);
system(['mkdir -p ', PathResRec]);

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

GPPmin = 0.1;
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
% 湿润等级
% ===============================
LevelList  = {[1.0,1.5], [1.5,2.0], [2.0,inf]};
LevelNames = {'Moderate','Severe','Extreme'};
nLevel     = numel(LevelList);

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

            for y = 1:numel(Years)

                Year = Years(y);
                YearName = num2str(Year);

                YearPath = fullfile(PathResRec,ModeName,SSPName,PeriodName,YearName);
                system(['mkdir -p ',YearPath]);

                % ---- 读取当年 GPP ----
                GPPnow = double(readgeoraster(fullfile(PathGPP,ModeName,SSPName,...
                    ['CMIP6.',ModeName,'.MonGPP.',YearName,'.tif'])));

                % ---- 读取 SPEI ----
                SPEIfile = fullfile(PathSPEI,ModeName,SSPName,...
                    [ModeName,'_SPEI_3_',SSPName,'_',YearName,'.MonSPEI_050DEG.tif']);
                MonSPEI = double(readgeoraster(SPEIfile));

                % ---- 读取下一年 GPP（处理 m=12）----
                if y < numel(Years)
                    GPPnext = double(readgeoraster(fullfile(PathGPP,ModeName,SSPName,...
                        ['CMIP6.',ModeName,'.MonGPP.',num2str(Years(y+1)),'.tif'])));
                else
                    GPPnext = nan(nRow,nCol,12);
                end

                % ===============================
                % 按湿润等级
                % ===============================
                for iLev = 1:nLevel

                    Range = LevelList{iLev};
                    OmegaMonth = nan(nRow,nCol,12);
                    DeltaMonth = nan(nRow,nCol,12);

                    for m = 1:12

                        GPPm  = GPPnow(:,:,m);
                        GPPm1 = (m < 12) * GPPnow(:,:,min(m+1,12)) + ...
                                (m == 12) * GPPnext(:,:,1);

                        GPPn  = GPPnormal(:,:,m);
                        SPEIm = MonSPEI(:,:,m);

                  

                        % 事件掩膜：只由气候决定
                        WetMask = ...
                            Mask & ...
                            SPEIm >= Range(1) & SPEIm < Range(2) & GPPn > GPPmin;
                        
                        GPPwet = nan(nRow, nCol);
                        GPPwet(WetMask) = GPPm(WetMask);

                        % === 抵抗力 Ω ===
                        Omega = nan(nRow,nCol);
                        Omega = ...
                            GPPn./ abs(GPPm - GPPn);

                        
                        GPPwet1 = nan(nRow, nCol);
                        GPPwet1(WetMask) = GPPm1(WetMask);

                        % === 恢复调节 Δ ===
                        Delta = nan(nRow,nCol);
                        Delta = abs(GPPwet - GPPn) ./ abs(GPPwet1 - GPPn);

                        Delta(Delta==0) = 1;
                        
                        OmegaMonth(:,:,m) = Omega;
                        DeltaMonth(:,:,m) = Delta;
                    end

                    % === 年尺度 ===
                    OmegaYear = mean(OmegaMonth,3,'omitnan');
                    DeltaYear = mean(DeltaMonth,3,'omitnan');

                    % ---- 保存 ----
                    save(fullfile(YearPath,...
                        ['YrGPPRes.',LevelNames{iLev},'.mat']), ...
                        'OmegaYear','OmegaMonth','-v7.3');

                    save(fullfile(YearPath,...
                        ['YrGPPRec.',LevelNames{iLev},'.mat']), ...
                        'DeltaYear','DeltaMonth','-v7.3');
                end
            end
        end
    end
end
