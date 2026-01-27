clear; clc;
addpath(genpath('./'));

% ===============================
% 路径设置
% ===============================
Path_LandCover = '../input/';
Path_Country   = '../output/26_CountryResGPP/';
Path_Figure    = '../figure/';
system(['mkdir -p ',Path_Figure]);

% ===============================
% 国家边界
% ===============================
WorldShape = shaperead( ...
    '../misc/WorldCountry/world_country_boundary.shp', ...
    'UseGeoCoords',true);

% ===============================
% 参考栅格（用于 R）
% ===============================
RefeName = [Path_LandCover,...
    'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];
[LC, R] = readgeoraster(RefeName);

% ===============================
% 情景
% ===============================
SSPList = {'ssp126','ssp245','ssp370','ssp585'};
CapList = {'a) ','b) ','c) ','d) '};
IndName = {'SSP1-2.6','SSP2-4.5','SSP3-7.0','SSP5-8.5'};

%% =====================================================
% 统一分位数阈值（基于所有 SSP）
% ======================================================
AllVals = [];

for s0 = 1:numel(SSPList)
    D0 = load(fullfile(Path_Country,SSPList{s0},'CountryDeltaRes.mat'));
    v  = D0.CountryRes;
    v  = v(isfinite(v));
    AllVals = [AllVals; v(:)];
end

NegVals = AllVals(AllVals < 0);
PosVals = AllVals(AllVals > 0);

Qneg = prctile(NegVals,[33 66]);   % negative quantiles
Qpos = prctile(PosVals,[33 66]);   % positive quantiles

epsilon = 0.01;   % no-change 带宽（Δlog 单位）

%% =====================================================
% 你指定的 7 类颜色（严格按顺序）
% ======================================================
ColorMap = [
     96  28   2;    % extreme decrease  (very dark brown, colder)
    166  54   3;    % large decrease    (brown-orange)
    223 122  41;    % moderate decrease
    224 226 217;    % no change
     90 180 172;    % moderate increase
      0 120 110;    % large increase
      0  80  75     % extreme increase
] / 255;

%% =====================================================
% 主循环：逐 SSP 作图
% ======================================================
for s = 1:numel(SSPList)

    SSPName = SSPList{s};

    % ===============================
    % 读取国家尺度 Δlog(Res)
    % ===============================
    Data  = load(fullfile(Path_Country,SSPName,'CountryDeltaRes.mat'));
    Class = Data.CountryRes;
    Class(LC==0 | LC==17) = NaN;

    % ===============================
    % 7 类严格分级（不吞信息）
    % ===============================
    ClassID = nan(size(Class));

    ClassID(Class <= Qneg(1))                                   = 1; % large dec <=33
    ClassID(Class > Qneg(1) & Class <= Qneg(2))                 = 2; % mod dec 33-66
    ClassID(Class > Qneg(2) & Class <  -epsilon)                = 3; % slight dec >=66
    ClassID(Class >= -epsilon & Class <=  epsilon)              = 4; % no change
    ClassID(Class >  epsilon & Class <  Qpos(1))                = 5; % slight inc
    ClassID(Class >= Qpos(1) & Class < Qpos(2))                 = 6; % mod inc
    ClassID(Class >= Qpos(2))                                   = 7; % large inc

    % ===============================
    % 作图
    % ===============================
    Fig = figure;
    set(gcf,'Position',[100,100,1200,600],...
        'DefaultAxesFontSize',12);

    ObjImage = grid2image(ClassID, R);
 
    set(gca, 'Visible', 'on', 'Color', 'none');
    set(gca,'Units','Pixels','Position',[25 80 1170 520]);box on;hold on; 
    set(gca, 'XLim', [-180 180], 'YLim', [-65 90]);
    set(gca, 'XTick', -120:60:120, 'YTick', -30:30:60);
    set(gca,'xlabel', [], 'ylabel', []);
    set(gca, 'XTickLabel', {}, 'FontSize', 18);
    set(gca, 'YTickLabel', {}, 'FontSize', 18);

    colormap(ColorMap);
    
    %强制把颜色映射范围设为 0.5–7.5，使整数 1–7 这 7 个类别在 colorbar 上“等宽、居中、对齐颜色块”
    clim([0.5 7.5]);

    set(ObjImage,'AlphaData',~isnan(ClassID));

    geoshow([WorldShape.Lat],[WorldShape.Lon], ...
        'Color',[0.3 0.3 0.3],'LineWidth',0.8);

    % ===============================
    % colorbar（离散、等宽）
    % ===============================
    Hbar = colorbar('SouthOutside');
    Pos  = get(Hbar,'Position');
    Pos=[Pos(1)+0.1 Pos(2)-0.11 Pos(3)*0.8 Pos(4)];
    % Pos = [Pos(1)+0.6 Pos(2)+0.03 Pos(3)*0.30 Pos(4)*2/3];

    set(Hbar,'Position',Pos,'FontSize',14);

    set(Hbar,'Ticks',1:7);
    set(Hbar,'TickLabels', ...
        {'Large −','Moderate −','Slight −','No change',...
         'Slight +','Moderate +','Large +'});

    % 标题
    text('String',[CapList{s},IndName{s},' ensemble mean resistance change'],...
    'Units','Normalized','Position',[0.03 0.1],'Fontsize',20);

    % ===============================
    % 输出
    % ===============================
    print(Fig,'-dtiff','-r300', ...
        fullfile(Path_Figure, ...
        ['GeoCountryRes_',SSPName,'.tif']));
    close(Fig);

end

%% =====================================================
% 合并 4 个面板
% ======================================================
Fig1 = imread([Path_Figure,'GeoCountryRes_ssp126.tif']);
Fig2 = imread([Path_Figure,'GeoCountryRes_ssp245.tif']);
Fig3 = imread([Path_Figure,'GeoCountryRes_ssp370.tif']);
Fig4 = imread([Path_Figure,'GeoCountryRes_ssp585.tif']);

FigTop = cat(2,Fig1,Fig2);
FigBot = cat(2,Fig3,Fig4);
FigAll = cat(1,FigTop,FigBot);

FigAll = imresize(FigAll,2244/size(FigAll,2));

imwrite(FigAll,[Path_Figure,'Fig07CountryResChange.tif'], ...
    'Compression','LZW','Resolution',300);

delete([Path_Figure,'GeoCountryRes_*.tif']);
