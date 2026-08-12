% ===============================================================
% ProcS_ThresholdSensitivity_Figure_2x3.m
% ---------------------------------------------------------------
% 湿润事件识别阈值敏感性分析 —— 正文讨论章节用图（3行×2列）
%   仅保留两个替代阈值 SPEI-03 >= 0.8 和 >= 1.2（基准 >= 1.0 已在
%   正文主图中出现，此处不重复），与 Fig01a/Fig02a/Fig03a 完全
%   相同的单图风格（含面积占比 inset 条形图、色标、国界）。
%
%   排版：
%     第一行 = Sensitivity，SPEI-03 >= 0.8 / >= 1.2
%     第二行 = Resistance，SPEI-03 >= 0.8 / >= 1.2
%     第三行 = Resilience，SPEI-03 >= 0.8 / >= 1.2
%     编号 a-f
%
%   数据来源：
%     0.8 : ../output/Threshold_08/07-09_Sum*17GPP/Climatology/
%     1.2 : ../output/Threshold_12/07-09_Sum*17GPP/Climatology/
%
%   输出 : ../figure/FigS_ThresholdSensitivity_3x2.tif
% ===============================================================

clear; clc;
addpath(genpath('./'));

Path_LandCover = '../input/';
Path_Figure    = '../figure/';

WorldShape = shaperead('../misc/WorldCountry/world_country_boundary.shp', ...
                       'UseGeoCoords', true);

RefeName = [Path_LandCover,'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];
[LandCover,R] = readgeoraster(RefeName);
LandCover = double(LandCover);

RowPath = { ...
    '../output/Threshold_08/', ...
    '../output/Threshold_12/' };
RowThreshLabel = {'SPEI-03 \geq 0.8','SPEI-03 \geq 1.2'};
RowTag = {'SPEI08','SPEI12'};

%% =====================================================
% 指标配置（与 Fig01a/Fig02a/Fig03a 完全一致）
% ======================================================
IndexCfg = struct();

IndexCfg.Sen.SumFolder = '07_SumSen17GPP';
IndexCfg.Sen.ClimFile  = 'SenClim.Total.mat';
IndexCfg.Sen.VarName   = 'SenClimTotal';
IndexCfg.Sen.Thres1    = -1;
IndexCfg.Sen.Thres2    = 1;
IndexCfg.Sen.TickStep  = 0.5;
IndexCfg.Sen.ColorMap  = brown2blue2;
IndexCfg.Sen.NameBase  = 'sensitivity';
IndexCfg.Sen.BinEdges  = [-1 -0.5 0 0.5 1 inf];
IndexCfg.Sen.BinLabels = {'[-1,-0.5)','[-0.5,0)','[0,0.5)','[0.5,1)','>1'};
IndexCfg.Sen.BarColors = [120 60 20; 191 128 49; 120 175 205; 37 92 170; 10 40 100]./255;
IndexCfg.Sen.ExcludeExtra = 11;

IndexCfg.Res.SumFolder = '08_SumRes17GPP';
IndexCfg.Res.ClimFile  = 'ResClim.Total.mat';
IndexCfg.Res.VarName   = 'ResClimTotal';
IndexCfg.Res.Thres1    = 0;
IndexCfg.Res.Thres2    = 40;
IndexCfg.Res.TickStep  = 10;
IndexCfg.Res.ColorMap  = gpp2color;
IndexCfg.Res.NameBase  = 'resistance';
IndexCfg.Res.BinEdges  = [0 10 20 30 40 inf];
IndexCfg.Res.BinLabels = {'(0,10]','(10,20]','(20,30]','(30,40]','>40'};
IndexCfg.Res.BarColors = [214 109 44; 244 191 17; 188 247 5; 6 210 37; 31 152 147]./255;
IndexCfg.Res.ExcludeExtra = [11 13 15 16 255];

IndexCfg.Rec.SumFolder = '09_SumRec17GPP';
IndexCfg.Rec.ClimFile  = 'RecClim.Total.mat';
IndexCfg.Rec.VarName   = 'RecClimTotal';
IndexCfg.Rec.Thres1    = 0;
IndexCfg.Rec.Thres2    = 6;
IndexCfg.Rec.TickStep  = 2;
IndexCfg.Rec.ColorMap  = yellow2purple2;
IndexCfg.Rec.NameBase  = 'resilience';
IndexCfg.Rec.BinEdges  = [0 1 2 4 6 inf];
IndexCfg.Rec.BinLabels = {'(0,1]','(1,2]','(2,4]','(4,6]','>6'};
IndexCfg.Rec.BarColors = [255 228 140; 252 182 45; 241 130 79; 179 44 139; 95 30 170]./255;
IndexCfg.Rec.ExcludeExtra = [11 13 15 16 255];

IndexList = {'Sen','Res','Rec'};
CapList   = {'a) ','b) ','c) ','d) ','e) ','f) '};
RowImgs   = cell(1,numel(IndexList));

for k = 1:numel(IndexList)
    IndexName = IndexList{k};
    Cfg = IndexCfg.(IndexName);
    PanelFiles = cell(1,numel(RowPath));

    for rIdx = 1:numel(RowPath)

        S = load(fullfile(RowPath{rIdx}, Cfg.SumFolder, 'Climatology', Cfg.ClimFile));
        Class = S.(Cfg.VarName);

        Thres1 = Cfg.Thres1;
        Thres2 = Cfg.Thres2;
        IndName = [Cfg.NameBase, ' (', RowThreshLabel{rIdx}, ')'];

        Class(LandCover == 0 | LandCover == 17) = 999;

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
        colormap(Cfg.ColorMap);
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
        set(Hbar,'XTick',Thres1:Cfg.TickStep:Thres2);
        TickLabel = cellstr(num2str(get(Hbar,'XTick')','%.1f'));
        TickLabel{end} = ['>',num2str(Thres2)];
        set(Hbar,'XTickLabel',TickLabel);

        % ---- 标题（阈值信息替换）----
        text('String',IndName,'Units','Normalized',...
             'Position',[0.67 0.14],'FontSize',20);
        text('String',CapList{(k-1)*numel(RowPath)+rIdx},'Units','Normalized',...
             'Position',[0.03 0.95],'FontSize',24);

        %% ---- 条形图统计 ----
        Vals = S.(Cfg.VarName);
        ExcludeSet = [0, 17, Cfg.ExcludeExtra];
        Vals(ismember(LandCover, ExcludeSet)) = NaN;
        Vals = Vals(isfinite(Vals));

        [counts,~] = histcounts(Vals, Cfg.BinEdges);
        areaFrac = counts ./ sum(counts) * 100;

        axInset = axes('Position',[0.08 0.16 0.24 0.35]);
        hold(axInset,'on');

        b = bar(axInset, areaFrac, 'FaceColor','flat','EdgeColor','none');
        for i = 1:length(areaFrac)
            b.CData(i,:) = Cfg.BarColors(i,:);
        end
        for i = 1:length(areaFrac)
            text(i, areaFrac(i)+3.5, sprintf('%.1f',areaFrac(i)), ...
                'HorizontalAlignment','center', ...
                'FontSize',16,'Parent',axInset);
        end

        set(axInset,'Box','off','FontSize',16,'Color','none');
        set(axInset,'XTick',1:length(Cfg.BinLabels),'XTickLabel',Cfg.BinLabels);
        ylabel(axInset,'area fractions (%)','FontSize',20);
        ylim(axInset,[0 max(areaFrac)*1.3]);

        %% ---- 保存单图 ----
        pause(5);
        set(gcf, 'Position', [100, 100, 1200, 600], 'DefaultAxesFontSize', 20);
        PanelFile = [Path_Figure, 'ThresholdPanel3x2_',IndexName,'_',RowTag{rIdx},'.tif'];
        print(Fig, '-dtiff', '-r300', PanelFile);
        close(Fig);

        PanelFiles{rIdx} = PanelFile;
    end

    %% ===============================
    % 拼接两个阈值面板（横向，单指标一行）
    % ===============================
    Img1 = imread(PanelFiles{1});
    Img2 = imread(PanelFiles{2});

    RowImgs{k} = cat(2, Img1, Img2);

    delete(PanelFiles{1}); delete(PanelFiles{2});

    fprintf('Finished row: %s\n', IndexName);
end

%% =====================================================
% 拼接三行为一张 3x2 总图
% ======================================================
ImgAll3x2 = cat(1, RowImgs{1}, RowImgs{2}, RowImgs{3});

OutName3x2 = [Path_Figure, 'FigS_ThresholdSensitivity_3x2.tif'];
imwrite(ImgAll3x2, OutName3x2, 'Compression','LZW','Resolution',300);

fprintf('Finished: 3x2 combined figure -> %s\n', OutName3x2);
disp('Finished: threshold sensitivity 3x2 figure (Fig01a/02a/03a style).');
