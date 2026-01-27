clear; clc;

addpath(genpath('./'));

% ===============================
% 路径设置
% ===============================
PathLandCover  = '../input/';
PathMul17GPPts = '../output/01_Mul17MonGPPts/';
PathSPEIts     = '../output/03_MulSPEIts/';
PathGPPnor     = '../output/04_MonGPPnor/';

system(['rm -rf ', PathGPPnor]);
system(['mkdir -p ', PathGPPnor]);

% ===============================
% 读取土地覆盖与掩膜
% ===============================
RefeName = [PathLandCover, ...
    'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];

[LandCover, R] = readgeoraster(RefeName);
Proj = geotiffinfo(RefeName);

Mask = (LandCover >= 1 & LandCover <= 10);   % 自然植被
[nRow, nCol] = size(LandCover);

% ===============================
% 时间参数
% ===============================
Years = 2001:2022;
nYears = length(Years);

% ===============================
% SPEI 参数
% ===============================
SPEIName = 'spei03';
NormalRange = [-1, 1];   % 正常区间

% ===============================
% 初始化累计矩阵
% ===============================
GPPsum   = zeros(nRow, nCol, 12);
GPPcount = zeros(nRow, nCol, 12);

% ===============================
% 主循环：逐年累积
% ===============================
for iYear = 1:nYears

    Year = Years(iYear);
    YearName = num2str(Year);

    disp(['Processing year: ', YearName]);

    % ---- 读取 SPEI ----
    load([PathSPEIts, SPEIName, '.MonSPEI', YearName, '.mat']);
    % 变量应为：MonSPEI (nRow × nCol × 12)

    % ---- 读取 GPP ----
    FileName = [PathMul17GPPts, ...
        'MOD17MonGPP.A', YearName, '.CMG050DEG.tif'];
    GPPmonth = readgeoraster(FileName);
    GPPmonth = double(GPPmonth);   % nRow × nCol × 12

    % ---- 月循环 ----
    for m = 1:12

        SPEIm = MonSPEI(:,:,m);
        GPPm  = GPPmonth(:,:,m);

        % 正常条件掩膜
        NormalMask = ...
            Mask & ...
            SPEIm >= NormalRange(1) & ...
            SPEIm <= NormalRange(2) & ...
            ~isnan(GPPm);

        % 累加
        Temp = zeros(nRow, nCol);
        Temp(NormalMask) = GPPm(NormalMask);

        GPPsum(:,:,m)   = GPPsum(:,:,m)   + Temp;
        GPPcount(:,:,m)= GPPcount(:,:,m) + NormalMask;

    end
end

% ===============================
% 计算多年气候态 GPPnormal
% ===============================
GPPnormal = GPPsum ./ GPPcount;
GPPnormal(GPPcount == 0) = NaN;

% ===============================
% 保存结果
% ===============================
save([PathGPPnor, 'MonGPPnormal.mat'], 'GPPnormal', '-v7.3');

% for m = 1:12
%     FileOut = [PathGPPnor, ...
%         'GPPnormal.Mon', num2str(m, '%02d'), '.tif'];
%     geotiffwrite(FileOut, GPPnormal(:,:,m), R, ...
%         'GeoKeyDirectoryTag', Proj.GeoTIFFTags.GeoKeyDirectoryTag, ...
%         'TiffTags', struct('Compression', Tiff.Compression.LZW));
% end

