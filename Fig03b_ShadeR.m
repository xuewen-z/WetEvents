clc; clear;
addpath(genpath('./'));

Path_Figure    = '../figure/';
Path_LandCover = '../input/';
Path_SumRec    = '../output/09_SumRec17GPP/Climatology/';   % ★ sumRec

LevelNames = {'Moderate','Severe','Extreme'};

% ===============================
% 读取 LandCover
% ===============================
[LandCover, R] = geotiffread( ...
    [Path_LandCover,'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif']);
LandCover = double(LandCover);
Invalid = (LandCover==0 | LandCover==15 | LandCover==16);

% ===============================
% 读取多年平均 Recovery（等级 + 总）
% ===============================
RecLevel = cell(3,1);
for i = 1:3
    load([Path_SumRec,'RecClim.',LevelNames{i},'.mat']);   % RecClimLevel
    tmp = RecClimLevel;
    tmp(Invalid) = NaN;
    tmp(~isfinite(tmp)) = NaN;
    RecLevel{i} = tmp;
end

load([Path_SumRec,'RecClim.Total.mat']);   % RecClimTotal
RecTotal = RecClimTotal;
RecTotal(Invalid) = NaN;
RecTotal(~isfinite(RecTotal)) = NaN;

% ===============================
% ★ 仅用于绘图的 log10(1 + Rec)
% ===============================
RecLevelPlot = cell(3,1);
for i = 1:3
    RecLevelPlot{i} = log10(RecLevel{i});
    RecLevelPlot{i}(~isfinite(RecLevelPlot{i})) = NaN;
end

RecTotalPlot = log10(RecTotal);
RecTotalPlot(~isfinite(RecTotalPlot)) = NaN;

% ===============================
% 构建纬度矩阵
% ===============================
Lower = (min(R.LatitudeLimits) + R.CellExtentInLatitude/2);
Upper = (max(R.LatitudeLimits) - R.CellExtentInLatitude/2);
MatrixLat = (Upper : -R.CellExtentInLatitude : Lower)';

STEP = 1;
Lat = (-65:STEP:90)';

% ===============================
% 纬向统计函数
% ===============================
calcLatMean = @(Data) arrayfun(@(L) ...
    nanmean(Data(MatrixLat > L-STEP/2 & MatrixLat < L+STEP/2,:), 'all'), Lat);

calcLatSTD = @(Data) arrayfun(@(L) ...
    nanstd(Data(MatrixLat > L-STEP/2 & MatrixLat < L+STEP/2,:), 0, 'all'), Lat);

LatMean = nan(length(Lat),4);
LatSTD  = nan(length(Lat),4);

for i = 1:3
    LatMean(:,i) = calcLatMean(RecLevelPlot{i});
    LatSTD(:,i)  = calcLatSTD(RecLevelPlot{i});
end
LatMean(:,4) = calcLatMean(RecTotalPlot);
LatSTD(:,4)  = calcLatSTD(RecTotalPlot);

% ===============================
% 颜色定义（与你 Sen / Res 完全一致）
% ===============================
ColorModerate = [0.98 0.87 0];          % 黄
ColorSevere   = [0.580 0.784 0.937];    % 浅蓝
ColorExtreme  = [0.41 0.35 0.80];       % 深蓝
ColorTotal    = [0.85 0.15 0.15];       % 红

Colors = {
    ColorModerate
    ColorSevere
    ColorExtreme
    ColorTotal
};

LineWidth = [3 3 3 3];

% ===============================
% 绘图
% ===============================
Fig = figure;
set(gcf,'position',[100 100 320 600],'defaultAxesFontSize',18);
set(gca,'Units','Pixels','Position',[30 80 240 470]);
box on; hold on;

for i = 1:4
    plot(Lat, LatMean(:,i), ...
        'Color', Colors{i}, ...
        'LineWidth', LineWidth(i));
end

% ===============================
% 坐标轴设置
% ===============================
set(gca,'xaxislocation','top');
set(gca,'xlim',[-60 90]);
set(gca,'xtick',-30:30:60);
set(gca,'xticklabel',{'30S','0','30N','60N'});

set(gca,'ylim',[-1.3 1]);
set(gca,'ytick',-1.2:0.6:1);
ylabel('log_{10}(resilience)','FontSize',16);

view([90 -90]);
xtickangle(90);

lgd = legend({'moderate','severe','extreme','total'}, ...
             'FontSize',11, ...
             'NumColumns',2);
set(lgd,'Box','off');

% 手动放置 legend
lgd.Units = 'normalized';
lgd.Position = [0.10 0.93 0.80 0.06];

text('String','b)', ...
    'Units','Normalized','Position',[0.05 0.95],'FontSize',18);

% ===============================
% 保存
% ===============================
print(Fig,'-dtiff','-r300', ...
      [Path_Figure,'LatRecLogMean.tif']);
close(Fig);

%% ===============================
% 合并面板
% ===============================
Fig1 = imread([Path_Figure,'RecGPPTotal.tif']);
Fig2 = imread([Path_Figure,'LatRecLogMean.tif']);

Fig = cat(1,cat(2,Fig1,Fig2));
Fig = imresize(Fig,2244/size(Fig,2));
imwrite(Fig,[Path_Figure,'Fig03RecTotal.tif'], ...
        'Compression','LZW','Resolution',300);

delete([Path_Figure,'RecGPPTotal.tif']);
delete([Path_Figure,'LatRecLogMean.tif']);
