clear; clc;
addpath(genpath('./'));

% ===============================
% 路径设置
% ===============================
Path_LandCover = '../input/';
PathTrend      = '../output/10_TrendSenResRec/';   % ★ 趋势结果
Path_Figure    = '../figure/';

% ===============================
% 读取世界边界
% ===============================
WorldShape = shaperead('../misc/WorldCountry/world_country_boundary.shp', ...
                       'UseGeoCoords', true);

% ===============================
% 读取 LandCover
% ===============================
RefeName = [Path_LandCover,...
    'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];
[LandCover,R] = readgeoraster(RefeName);
Proj = geotiffinfo(RefeName);
LandCover = double(LandCover);

% ===============================
% ★ 读取 Resistance 趋势结果
% ===============================
load([PathTrend,'TrendSlopeRec.mat']);  
% SlopeRes, PRes

Class = SlopeRec;    % ★ 主图变量
Pval  = PRec;        % ★ 显著性

% ===============================
% 绘图参数（趋势可正可负）
% ===============================
lim = prctile(abs(Class(:)),95);   % 稳健色标
Thres1 = -0.2;
Thres2 =  0.2;
IndName = 'sen''s slope of resilience (2001–2022)';

% ===============================
% LandCover 掩膜
% ===============================
Class(LandCover == 0 | LandCover == 17) = 999;

% ===============================
% 创建图像
% ===============================
Fig = figure;
set(gcf,'Position',[100 100 1200 600],'DefaultAxesFontSize',12);
set(gca,'Visible','off');

% ---- 背景 ----
Background = zeros(size(Class));
Background(isnan(Class)) = 2;
ObjImage = grid2image(Background, R);
colormap([1 1 1; 0.3 0.3 0.3]); 
hold on;
set(ObjImage,'AlphaData',0.1);
freezeColors;

% ---- 前景 ----
ObjImage = grid2image(Class, R);

% ---- 坐标轴 ----
set(gca,'Visible','on','Color','none');
set(gca,'Units','Pixels','Position',[25 20 1170 580]); 
box on;
set(gca, 'XLim', [-180 180], 'YLim', [-65 90]);
set(gca, 'XTick', -120:60:120, 'YTick', -30:30:60);
set(gca,'xlabel', [], 'ylabel', []);
set(gca, 'XTickLabel', {}, 'FontSize', 18);
set(gca, 'YTickLabel', {}, 'FontSize', 18);


% ---- 颜色映射 ----
ColorMap = red2green;
colormap(ColorMap);
set(gca,'CLim',[Thres1 Thres2]);

% ---- Alpha ----
Class(LandCover == 0 | LandCover == 17) = nan;
AlphaData = ~isnan(Class);
set(ObjImage,'AlphaData',AlphaData);
set(gca,'Color','white');

% ---- 国界 ----
geoshow([WorldShape.Lat],[WorldShape.Lon], ...
        'Color',[0.709 0.709 0.709], ...
        'LineWidth',1.0);

% 显著性检验标记
hold on;
[LonGrid, LatGrid] = meshgrid(-180+0.5/2:0.5:180-0.5/2, -60+0.5/2:0.5:90-0.5/2);
Mask = Pval < 0.05; % 95% 显著性检验
stipple(LonGrid, LatGrid, flipud(Mask), 'Density', 350, 'Color', 'k', 'Marker', '.', 'MarkerSize', 8);


% ---- Colorbar ----
Hbar = colorbar('Location','SouthOutside');
Pos = get(Hbar,'Position');
Pos = [Pos(1)+0.6 Pos(2)+0.03 Pos(3)*0.30 Pos(4)*2/3];
set(Hbar,'Position',Pos,'FontSize',16);
set(Hbar,'XLim',[Thres1 Thres2]);
set(Hbar,'XTick',Thres1:0.1:Thres2);
TickLabel = cellstr(num2str(get(Hbar,'XTick')','%.1f'));
TickLabel{1} = '<-0.2';
TickLabel{end} = '>0.2';
set(Hbar,'XTickLabel',TickLabel);

% ---- 标题 ----
text('String',IndName,'Units','Normalized',...
     'Position',[0.62 0.14],'FontSize',16);
text('String','c)','Units','Normalized',...
     'Position',[0.03 0.95],'FontSize',20);

% ===============================
% 保存
% % ===============================
print(Fig,'-dtiff','-r300', ...
      [Path_Figure,'TrendSlopeRec.tif']);
close(Fig);


%% ===============================
% 合并面板
% ===============================
% Fig1 = imread([Path_Figure,'TrendSlopeSen.tif']);
% Fig2 = imread([Path_Figure,'TrendSlopeRes.tif']);
% Fig3 = imread([Path_Figure,'TrendSlopeRec.tif']);
% 
% Fig = cat(1,cat(2,Fig1),cat(2,Fig2),cat(2,Fig3));
% Fig = imresize(Fig,2244/size(Fig,2));
% imwrite(Fig,[Path_Figure,'Fig04TrendSlope.tif'], ...
%         'Compression','LZW','Resolution',300);
% 
% delete([Path_Figure,'TrendSlopeSen.tif']);
% delete([Path_Figure,'TrendSlopeRes.tif']);
% delete([Path_Figure,'TrendSlopeRec.tif']);
