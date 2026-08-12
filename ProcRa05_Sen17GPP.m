% ===============================================================
% ProcRa05_Sen17GPP.m
% ---------------------------------------------------------------
% 阈值敏感性分析 (Threshold sensitivity test)
%   使用阈值 : SPEI-03 >= 1.2   (对照原基准 SPEI-03 >= 1.0)
%   对应原始脚本 : Proc05_Sen17GPP.m
%   测试目的 : 回应审稿人 "How sensitive are results to the
%              selected threshold of SPEI >= 1?" —— 除湿润事件
%              识别阈值下限由 1.0 改为 1.2 外，其余计算逻辑、
%              数据、参数与 Proc05 完全一致。
%   输出目录 : ../output/Threshold_12/05_Sen17GPP/
% ===============================================================

clear; clc;

addpath(genpath('./'));

% ===============================
% 路径设置
% ===============================
PathLandCover  = '../input/';
PathMul17GPPts = '../output/01_Mul17MonGPPts/';
PathSPEIts     = '../output/03_MulSPEIts/';
PathGPPnor     = '../output/04_MonGPPnor/';
PathGPPSen     = '../output/Threshold_12/05_Sen17GPP/';

system(['rm -rf ', PathGPPSen]);
system(['mkdir -p ', PathGPPSen]);

% ===============================
% 读取土地覆盖与掩膜
% ===============================
RefeName = [PathLandCover, ...
    'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];

[LandCover, R] = readgeoraster(RefeName);
Proj = geotiffinfo(RefeName);

Mask = (LandCover >= 1 & LandCover <= 10);
[nRow, nCol] = size(LandCover);

% ===============================
% 时间参数
% ===============================
Years = 2001:2022;

% ===============================
% SPEI 与等级（敏感性测试：下限 1.0 -> 1.2）
% ===============================
SPEIName   = 'spei03';
LevelList  = {[1.2,1.5], [1.5,2.0], [2.0,inf]};
LevelNames = {'Moderate','Severe','Extreme'};
nLevel     = length(LevelList);

% ===============================
% 读取 GPPnormal
% ===============================
load([PathGPPnor,'MonGPPnormal.mat']);
% GPPnormal (nRow × nCol × 12)

% ===============================
% 主循环：逐年
% ===============================
for y = 1:length(Years)

    Year = Years(y);
    YearName = num2str(Year);
    disp(['Processing year: ', YearName]);

    % 年目录
    YearPath = [PathGPPSen, YearName, '/'];
    system(['mkdir -p ', YearPath]);

    % ---- 读取 SPEI ----
    load([PathSPEIts, SPEIName, '.MonSPEI', YearName, '.mat']);
    % MonSPEI (nRow × nCol × 12)

    % ---- 读取 GPP ----
    FileName = [PathMul17GPPts, ...
        'MOD17MonGPP.A', YearName, '.CMG050DEG.tif'];
    GPPmonth = double(readgeoraster(FileName));

    GPPmin = 0.1;
    % ===============================
    % 按湿润等级
    % ===============================
    for iLev = 1:nLevel

        Range = LevelList{iLev};

        % 月尺度缓存
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

        % 年尺度（等级内）
        SenYear = mean(SenMonth, 3, 'omitnan');

        % ---- 保存 ----
        save([YearPath,'YrGPPSen.',LevelNames{iLev},'.mat'], ...
             'SenYear','SenMonth','-v7.3');
    end
end
