clear; clc;
addpath(genpath('./'));

% ===============================
% 路径设置
% ===============================
Path_LandCover = '../input/';
PathSumRec     = '../output/09_SumRec17GPP/';   % ★ sumRec
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
% 读取多年平均总恢复力
% ===============================
load([PathSumRec,'Climatology/RecClim.Total.mat']);
% RecClimTotal (nRow × nCol)

Class = RecClimTotal;

% ===============================
% 绘图参数（恢复力 ≥ 1，无负值）
% ===============================
Thres1  = 0;
Thres2  = 6;                         % 可与前面统计一致
IndName = 'resilience  (2001–2022)';

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

% ---- 颜色映射（顺序型，适合 recovery）----
ColorMap = yellow2purple2;
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
set(Hbar,'XTick',Thres1:2:Thres2);
TickLabel = cellstr(num2str(get(Hbar,'XTick')','%.f'));
TickLabel{end} = '>6';
set(Hbar,'XTickLabel',TickLabel);

% ---- 标题 ----
text('String',IndName,'Units','Normalized',...
     'Position',[0.67 0.14],'FontSize',16);
text('String','a)','Units','Normalized',...
     'Position',[0.03 0.95],'FontSize',20);

%% ===============================
% 条形图统计（多年平均总恢复力）
% ===============================

recVals = RecClimTotal;
recVals(LandCover == 0 | LandCover == 11 | LandCover == 13 | ...
         LandCover == 15 | LandCover == 16 | LandCover == 17 | ...
         LandCover == 255) = NaN;
recVals = recVals(isfinite(recVals));

% ===============================
% 区间定义（与你前面一致）
% ===============================
BinEdges  = [0 1 2 4 6 inf];
BinLabels = {'(0,1]','(1,2]','(2,4]','(4,6]','>6'};

% ===============================
% 面积占比
% ===============================
[counts,~] = histcounts(recVals, BinEdges);
areaFrac = counts ./ sum(counts) * 100;

% ===============================
% inset axes
% ===============================
axInset = axes('Position',[0.08 0.16 0.24 0.35]);
hold(axInset,'on');

% 与空间分布一致的颜色
BarColors = [
    255 228 140;
    252 182 45;   
    241 130 79;    
    179 44 139;    
    % 129, 4, 165;
    95  30 170] ./ 255;

b = bar(axInset, areaFrac, 'FaceColor','flat','EdgeColor','none');
for i = 1:length(areaFrac)
    b.CData(i,:) = BarColors(i,:);
end

for i = 1:length(areaFrac)
    text(i, areaFrac(i)+3.5, sprintf('%.1f',areaFrac(i)), ...
        'HorizontalAlignment','center', ...
        'FontSize',14,'Parent',axInset);
end

set(axInset,'Box','off','FontSize',16,'Color','none');
set(axInset,'XTick',1:length(BinLabels),'XTickLabel',BinLabels);
ylabel(axInset,'area fractions (%)','FontSize',16);
ylim(axInset,[0 max(areaFrac)*1.3]);

% ===============================
% 保存图像
% ===============================
pause(5);
set(gcf, 'Position', [100, 100, 1200, 600], 'DefaultAxesFontSize', 20);
print(Fig, '-dtiff', '-r300', ...
      [Path_Figure, 'RecGPPTotal.tif']);
close(Fig);
