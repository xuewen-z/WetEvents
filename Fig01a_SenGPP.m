clear; clc;
addpath(genpath('./'));

% ===============================
% 路径设置
% ===============================
Path_LandCover = '../input/';
PathSumSen     = '../output/07_SumSen17GPP/';
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
% 读取多年平均总敏感性
% ===============================
load([PathSumSen,'Climatology/SenClim.Total.mat']);
% SenClimTotal (nRow × nCol)

Class = SenClimTotal;

% ===============================
% 绘图参数（⚠️ 敏感性是无量纲，可正可负）
% ===============================
Thres1  = -1;
Thres2  =  1;
IndName = 'sensitivity (2001–2022)';

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
colormap([1 1 1; 0.3 0.3 0.3]); hold on;
set(ObjImage,'AlphaData',0.1);
freezeColors;

% ---- 前景 ----
ObjImage = grid2image(Class, R);

% ---- 坐标轴 ----
set(gca,'Visible','on','Color','none');
set(gca,'Units','Pixels','Position',[25 20 1170 580]); box on;
set(gca, 'XLim', [-180 180], 'YLim', [-65 90]);
set(gca, 'XTick', -120:60:120, 'YTick', -30:30:60);
set(gca,'xlabel', [], 'ylabel', []);
set(gca, 'XTickLabel', {}, 'FontSize', 18);
set(gca, 'YTickLabel', {}, 'FontSize', 18);

% ---- 颜色映射 ----
ColorMap = brown2blue2;
colormap(ColorMap);
set(gca,'CLim',[Thres1 Thres2]);

% ---- Alpha ----
Class(LandCover == 0 | LandCover == 17) = nan;
AlphaData = ~isnan(Class);
set(ObjImage, 'AlphaData', AlphaData);
set(gca, 'Color', 'white');

% ---- 国界 ----
geoshow([WorldShape.Lat],[WorldShape.Lon], ...
        'Color',[0.709 0.709 0.709], ...
        'LineWidth',1.0);

% ---- Colorbar ----
Hbar = colorbar('Location','SouthOutside');
Pos = get(Hbar,'Position');
Pos = [Pos(1)+0.65 Pos(2)+0.03 Pos(3)*0.26 Pos(4)*2/3];
set(Hbar,'Position',Pos,'FontSize',16);
set(Hbar,'XLim',[Thres1 Thres2]);
set(Hbar,'XTick',Thres1:0.5:Thres2);
TickLabel = cellstr(num2str(get(Hbar,'XTick')','%.1f'));
% TickLabel{1} = '<-1';
TickLabel{end} = '>1';
set(Hbar,'XTickLabel',TickLabel);

% ---- 标题 ----
text('String',IndName,'Units','Normalized',...
     'Position',[0.67 0.14],'FontSize',16);
text('String','a)','Units','Normalized',...
     'Position',[0.03 0.95],'FontSize',20);

%% ===============================
% 条形图统计（多年平均总敏感性）
% ===============================

senVals = SenClimTotal;
senVals(LandCover == 0 | LandCover >= 11) = NaN;
senVals = senVals(isfinite(senVals));

% ===============================
% 区间定义
% ===============================
BinEdges  = [-1 -0.5 0 0.5 1 inf];
BinLabels = {'[-1,-0.5)','[-0.5,0)', ...
             '[0,0.5)','[0.5,1)','>1'};

% ===============================
% 面积占比
% ===============================
[counts,~] = histcounts(senVals, BinEdges);
areaFrac = counts ./ sum(counts) * 100;

% ===============================
% inset axes
% ===============================
axInset = axes('Position',[0.08 0.16 0.24 0.35]);
hold(axInset,'on');

BarColors = [
    % 84 47 5;
    120  60  20;
    191 128 49;
    120 175 205;
    37  92 170;
    10  40 100] ./ 255;

b = bar(axInset, areaFrac, 'FaceColor','flat','EdgeColor','none');
for i = 1:length(areaFrac)
    b.CData(i,:) = BarColors(i,:);
end

for i = 1:length(areaFrac)
    text(i, areaFrac(i)+3.5, sprintf('%.1f',areaFrac(i)), ...
        'HorizontalAlignment','center', ...
        'FontSize',12,'Parent',axInset);
end

set(axInset,'Box','off','FontSize',16,'Color','none');
set(axInset,'XTick',1:length(BinLabels),'XTickLabel',BinLabels);
ylabel(axInset,'area fractions (%)','FontSize',16);
ylim(axInset,[0 max(areaFrac)*1.3]);

% ===============================
% 保存图像
% ===============================
pause(5); set(gcf, 'Position', [100, 100, 1200, 600], 'DefaultAxesFontSize', 20);
print(Fig, '-dtiff', '-r300', [Path_Figure, 'SenGPPTotal.tif']); close(Fig);

