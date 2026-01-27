clear; clc;

addpath(genpath('./'));

% ===============================
% 路径设置
% ===============================
PathLandCover  = '../input/';
PathMul17GPPts = '../output/01_Mul17MonGPPts/';
PathSPEIts     = '../output/03_MulSPEIts/';
PathGPPnor     = '../output/04_MonGPPnor/';
PathResRec     = '../output/06_ResRec17GPP/';

system(['rm -rf ', PathResRec]);
system(['mkdir -p ', PathResRec]);

% ===============================
% 读取土地覆盖与掩膜
% ===============================
RefeName = [PathLandCover, ...
    'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];

[LandCover, R] = readgeoraster(RefeName);
Mask = (LandCover >= 1 & LandCover <= 10);   % 自然植被
[nRow, nCol] = size(LandCover);

% ===============================
% 时间参数
% ===============================
Years = 2001:2022;    % 最后一年 m=12 时需用到 2023.01
nYears = length(Years);

% ===============================
% SPEI 与湿润等级
% ===============================
SPEIName   = 'spei03';
LevelList  = {[1.0,1.5], [1.5,2.0], [2.0,inf]};
LevelNames = {'Moderate','Severe','Extreme'};
nLevel     = length(LevelList);

% ===============================
% 读取 GPPnormal（多年同月正常态）
% ===============================
load([PathGPPnor,'MonGPPnormal.mat']);
% GPPnormal: nRow × nCol × 12

GPPmin = 0.1;

% ===============================
% 主循环：逐年
% ===============================
for y = 1:nYears

    Year = Years(y);
    YearName = num2str(Year);
    disp(['Processing resistance & recovery: ', YearName]);

    % 年输出目录
    YearPath = [PathResRec, YearName, '/'];
    system(['mkdir -p ', YearPath]);

    % ---- 读取当年 GPP ----
    GPPnow = double(readgeoraster([PathMul17GPPts, ...
        'MOD17MonGPP.A', YearName, '.CMG050DEG.tif']));

    % ---- 读取 SPEI ----
    load([PathSPEIts, SPEIName, '.MonSPEI', YearName, '.mat']);
    % MonSPEI: nRow × nCol × 12

    % ---- 读取下一年 GPP（用于 m=12）----
    if y < nYears
        GPPnextYear = double(readgeoraster([PathMul17GPPts, ...
            'MOD17MonGPP.A', num2str(Years(y+1)), '.CMG050DEG.tif']));
    else
        GPPnextYear = nan(nRow, nCol, 12);
    end

    % ===============================
    % 按湿润等级
    % ===============================
    for iLev = 1:nLevel

        Range = LevelList{iLev};
        OmegaMonth = nan(nRow, nCol, 12);
        DeltaMonth = nan(nRow, nCol, 12);

        for m = 1:12

            % ---- 当前月 GPP ----
            GPPm = GPPnow(:,:,m);

            % ---- 下一个月 GPP ----
            if m < 12
                GPPm1 = GPPnow(:,:,m+1);
            else
                GPPm1 = GPPnextYear(:,:,1);  % 跨年到 1 月
            end

            % ---- 同月正常态（固定参照）----
            GPPn = GPPnormal(:,:,m);

            SPEIm = MonSPEI(:,:,m);

            % ---- 湿润等级掩膜 ----
            WetMask = ...
                Mask & ...
                SPEIm >= Range(1) & SPEIm < Range(2) & GPPn > GPPmin;

           
            if ~any(WetMask(:))
                continue;
            end

            % ===============================
            % Ω(τ) 抵抗力
            % ===============================
            Omega = nan(nRow, nCol);
            Omega(WetMask) = ...
                GPPn(WetMask) ./ ...
                abs(GPPm(WetMask) - GPPn(WetMask));
           
            % ===============================
            % Δ(τ) 恢复调节（τ+1 = 下一个月）
            % ===============================
            Delta = nan(nRow, nCol);
            Delta(WetMask) = ...
                abs(GPPm(WetMask) - GPPn(WetMask)) ./ ...
                abs(GPPm1(WetMask) - GPPn(WetMask));
            Delta(Delta==0) =1;

            OmegaMonth(:,:,m) = Omega;
            DeltaMonth(:,:,m) = Delta;
        end

        % ===============================
        % 年尺度（等级内）
        % ===============================
        OmegaYear = mean(OmegaMonth, 3, 'omitnan');
        DeltaYear = mean(DeltaMonth, 3, 'omitnan');


        % ---- 保存 ----
         save([YearPath,'YrGPPRes.',LevelNames{iLev},'.mat'], ...
             'OmegaYear','OmegaMonth','-v7.3');

        save([YearPath,'YrGPPRec.',LevelNames{iLev},'.mat'], ...
             'DeltaYear','DeltaMonth','-v7.3');
    end
end

