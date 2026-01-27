clc; clear;
addpath(genpath('./'));

% =====================================================
% 路径设置
% =====================================================
PathSen = '../output/07_SumSen17GPP/';
PathRes = '../output/08_SumRes17GPP/';
PathRec = '../output/09_SumRec17GPP/';
PathOut = '../output/10_TrendSenResRec/';

system(['rm -rf ', PathOut]);
system(['mkdir -p ', PathOut]);

% =====================================================
% 时间设置
% =====================================================
Years  = 2001:2022;
nYears = length(Years);
t = (1:nYears)';

% =====================================================
% 读取第一年，确定空间尺寸
% =====================================================
load([PathSen, num2str(Years(1)), '/SenYear.Total.mat']);
[nRow, nCol] = size(SenYearTotal);
nPix = nRow * nCol;

% =====================================================
% 一次性读取 22 年数据（3D）
% =====================================================
disp('Loading all years into memory ...');

Sen3D = nan(nRow, nCol, nYears);
Res3D = nan(nRow, nCol, nYears);
Rec3D = nan(nRow, nCol, nYears);

for k = 1:nYears
    Y = num2str(Years(k));

    load([PathSen,Y,'/SenYear.Total.mat'],'SenYearTotal');
    load([PathRes,Y,'/ResYear.Total.mat'],'ResYearTotal');
    load([PathRec,Y,'/RecYear.Total.mat'],'RecYearTotal');

    Sen3D(:,:,k) = SenYearTotal;
    Res3D(:,:,k) = ResYearTotal;
    Rec3D(:,:,k) = RecYearTotal;
end

% =====================================================
% reshape 为 (pixel × year)
% =====================================================
Sen2D = reshape(Sen3D, nPix, nYears);
Res2D = reshape(Res3D, nPix, nYears);
Rec2D = reshape(Rec3D, nPix, nYears);

clear Sen3D Res3D Rec3D   % 省内存

% =====================================================
% 初始化结果
% =====================================================
SlopeSen = nan(nPix,1);  PSen = nan(nPix,1);
SlopeRes = nan(nPix,1);  PRes = nan(nPix,1);
SlopeRec = nan(nPix,1);  PRec = nan(nPix,1);

% =====================================================
% 像元级趋势计算（快很多）
% =====================================================
disp('Computing Sen slope + MK (pixel-wise) ...');

for p = 1:nPix

    % ---------- Sensitivity ----------
    x = Sen2D(p,:)';
    idx = isfinite(x);
    if sum(idx) >= 8
        SlopeSen(p) = senslope(x(idx), t(idx));
        PSen(p)     = mannkendall(x(idx));
    end

    % ---------- Resistance ----------
    x = Res2D(p,:)';
    idx = isfinite(x) & x > 0;
    if sum(idx) >= 8
        SlopeRes(p) = senslope(x(idx), t(idx));
        PRes(p)     = mannkendall(x(idx));
    end

    % ---------- Recovery ----------
    x = Rec2D(p,:)';
    idx = isfinite(x) & x > 0;
    if sum(idx) >= 8
        SlopeRec(p) = senslope(x(idx), t(idx));
        PRec(p)     = mannkendall(x(idx));
    end
end

% =====================================================
% reshape 回空间栅格
% =====================================================
SlopeSen = reshape(SlopeSen, nRow, nCol);
PSen     = reshape(PSen,     nRow, nCol);

SlopeRes = reshape(SlopeRes, nRow, nCol);
PRes     = reshape(PRes,     nRow, nCol);

SlopeRec = reshape(SlopeRec, nRow, nCol);
PRec     = reshape(PRec,     nRow, nCol);

% =====================================================
% 保存结果
% =====================================================
save([PathOut,'TrendSlopeSen.mat'], 'SlopeSen','PSen','-v7.3');
save([PathOut,'TrendSlopeRes.mat'], 'SlopeRes','PRes','-v7.3');
save([PathOut,'TrendSlopeRec.mat'], 'SlopeRec','PRec','-v7.3');

