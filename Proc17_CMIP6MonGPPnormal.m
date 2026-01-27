clear; clc;
addpath(genpath('./'));

% ===============================
% 路径设置
% ===============================
PathLandCover = '../input/';
PathGPP       = '../output/14_CMIP6TIF_05DEG/';
PathSPEI      = '../output/16_CMIP6SPEI_05DEG/';
PathGPPnor    = '../output/17_CMIP6MonGPPnormal/';

system(['rm -rf ', PathGPPnor]);
system(['mkdir -p ', PathGPPnor]);

% ===============================
% 读取土地覆盖与掩膜
% ===============================
RefeName = [PathLandCover,...
    'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];

[LandCover, R] = readgeoraster(RefeName);
LandCover = double(LandCover);

Mask = (LandCover >= 1 & LandCover <= 10);   % 自然植被
[nRow, nCol] = size(LandCover);

% ===============================
% 模型
% ===============================
ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR'};

% ===============================
% 时间段定义（关键修改点）
% ===============================
PeriodList = { ...
    struct('name','baseline', ...
           'years',1981:2010, ...
           'SSPList',{{'historical'}}), ...
    struct('name','future', ...
           'years',2071:2100, ...
           'SSPList',{{'ssp126','ssp245','ssp370','ssp585'}}) ...
};

NormalRange = [-1, 1];

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

            % 初始化
            GPPsum   = zeros(nRow, nCol, 12);
            GPPcount = zeros(nRow, nCol, 12);

            % ========== 年循环 ==========
            for y = 1:numel(Years)
                Year = Years(y);
                YearName = num2str(Year);

                % ---- 读取 SPEI ----
                SPEIfile = fullfile(PathSPEI,ModeName,SSPName,...
                    [ModeName,'_SPEI_3_',SSPName,'_',YearName,'.MonSPEI_050DEG.tif']);
                SPEImon = double(readgeoraster(SPEIfile));

                % ---- 读取 GPP ----
                GPPfile = fullfile(PathGPP,ModeName,SSPName,...
                    ['CMIP6.',ModeName,'.MonGPP.',YearName,'.tif']);
                GPPmon = double(readgeoraster(GPPfile));

                % ---- 月循环 ----
                for m = 1:12
                    SPEIm = SPEImon(:,:,m);
                    GPPm  = GPPmon(:,:,m);

                    NormalMask = ...
                        Mask & ...
                        SPEIm >= NormalRange(1) & ...
                        SPEIm <= NormalRange(2) & ...
                        ~isnan(GPPm);

                    Temp = zeros(nRow,nCol);
                    Temp(NormalMask) = GPPm(NormalMask);

                    GPPsum(:,:,m)    = GPPsum(:,:,m)    + Temp;
                    GPPcount(:,:,m) = GPPcount(:,:,m) + NormalMask;
                end
            end

            % ========== 计算 GPPnormal ==========
            GPPnormal = GPPsum ./ GPPcount;
            
            % === 新增：跨月 normal 月数约束 ===
            GPPcount_all = sum(GPPcount, 3);   % 30 年内 normal 月总数
            Nmin_normal_all = 120;             % 推荐起点（可调）
            
            BadPix = (GPPcount_all < Nmin_normal_all);
            GPPnormal(repmat(BadPix,[1 1 12])) = NaN;


            % ========== 保存 ==========
            OutPath = fullfile(PathGPPnor,ModeName,SSPName);
            system(['mkdir -p ',OutPath]);

            save(fullfile(OutPath,...
                ['MonGPPnormal_',PeriodName,'.mat']), ...
                'GPPnormal','GPPcount','Nmin_normal_all','-v7.3');

            disp(['Saved GPPnormal: ',ModeName,' - ',SSPName,' - ',PeriodName]);
        end
    end
end

