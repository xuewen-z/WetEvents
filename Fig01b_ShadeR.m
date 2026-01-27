clc; clear;
addpath(genpath('./'));

Path_Figure    = '../figure/';
Path_LandCover = '../input/';
Path_SumSen    = '../output/07_SumSen17GPP/Climatology/';

LevelNames = {'Moderate','Severe','Extreme'};

% ===============================
% 读取 LandCover
% ===============================
[LandCover, R] = geotiffread( ...
    [Path_LandCover,'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif']);
LandCover = double(LandCover);
Invalid = (LandCover==0 | LandCover==15 | LandCover==16);

% ===============================
% 读取多年平均 Sen（等级 + 总）
% ===============================
SenLevel = cell(3,1);
for i = 1:3
    load([Path_SumSen,'SenClim.',LevelNames{i},'.mat']);  
    tmp = SenClimLevel;
    tmp(Invalid) = NaN;
    SenLevel{i} = tmp;
end

load([Path_SumSen,'SenClim.Total.mat']);  
SenTotal = SenClimTotal;
SenTotal(Invalid) = NaN;

% ===============================
% 构建纬度矩阵
% ===============================
Lower = (min(R.LatitudeLimits) + R.CellExtentInLatitude/2);
Upper = (max(R.LatitudeLimits) - R.CellExtentInLatitude/2);
MatrixLat = (Upper : -R.CellExtentInLatitude : Lower)';

STEP = 1;
Lat = (-65:STEP:90)';

% ===============================
% 纬向统计
% ===============================
calcLatMean = @(Data) arrayfun(@(L) ...
    nanmean(Data(MatrixLat > L-STEP/2 & MatrixLat < L+STEP/2,:), 'all'), Lat);

calcLatSTD = @(Data) arrayfun(@(L) ...
    nanstd(Data(MatrixLat > L-STEP/2 & MatrixLat < L+STEP/2,:), 0, 'all'), Lat);

LatMean = nan(length(Lat),4);
LatSTD  = nan(length(Lat),4);

for i = 1:3
    LatMean(:,i) = calcLatMean(SenLevel{i});
    LatSTD(:,i)  = calcLatSTD(SenLevel{i});
end
LatMean(:,4) = calcLatMean(SenTotal);
LatSTD(:,4)  = calcLatSTD(SenTotal);

% ===============================
% 颜色定义（来自示例图）
% ===============================
ColorModerate = [0.98 0.87 0];   % 黄
ColorSevere   = [0.580  0.784  0.937];   % 浅蓝
ColorExtreme  = [0.41 0.35 0.80];   % 深蓝
ColorTotal    = [0.85 0.15 0.15];   % 红


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

% ---- shaded + line ----
for i = 1:4
    c = Colors{i};


    % 主线
    plot(Lat, LatMean(:,i), ...
        'Color', c, ...
        'LineWidth', LineWidth(i));
end

% ===============================
% 坐标轴
% ===============================
set(gca,'xaxislocation','top');
set(gca,'xlim',[-60 90]);
set(gca,'xtick',-30:30:60);
set(gca,'xticklabel',{'30S','0','30N','60N'});

% set(gca,'ylim',[-0.35 0.62]);
% set(gca,'ytick',-0.4:0.2:0.6);
ylabel('sensitivity','FontSize',16);

view([90 -90]);
xtickangle(90);

lgd = legend({'moderate','severe','extreme','total'}, ...
             'FontSize',11, ...
             'NumColumns',2);
set(lgd,'Box','off');

% ===== 手动放置 legend（axes 内，顶部）=====
lgd.Units = 'normalized';
lgd.Position = [0.10 0.93 0.80 0.06];  
% [x y width height]


text('String','b)', ...
    'Units','Normalized','Position',[0.05 0.95],'FontSize',18);

% ===============================
% 保存
% ===============================
print(Fig,'-dtiff','-r300', ...
      [Path_Figure,'LatSenMean.tif']);
close(Fig);


%% combine
Fig1=imread([Path_Figure,'SenGPPTotal.tif']);
Fig2=imread([Path_Figure,'LatSenMean.tif']);

Fig=cat(1,cat(2,Fig1,Fig2));
Fig=imresize(Fig,2244/size(Fig,2));
imwrite(Fig,[Path_Figure,'Fig01SenTotal.tif'],'Compression','LZW','Resolution',300);


delete([Path_Figure,'SenGPPTotal.tif']);
delete([Path_Figure,'LatSenMean.tif']);