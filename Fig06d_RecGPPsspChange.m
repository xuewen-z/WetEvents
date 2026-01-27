clear; clc;

%% ===== 输入路径（只改这里）=====
% Path_RiskAnom = '../output/23_DeffSenCMIP6GPP/';   % ← 改为你的未来变化量路径
% Path_RiskAnom = '../output/24_DeffResCMIP6GPP/';
Path_RiskAnom = '../output/25_DeffRecCMIP6GPP/';

Path_LandCover = '../input/';
Path_Figure = '../figure/';

% 读取世界边界数据
WorldShape = shaperead('../misc/WorldCountry/world_country_boundary.shp', 'UseGeoCoords', true);

% 读取 LandCover 影像数据及其地理信息
RefeName = [Path_LandCover,'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];
[LandCover,R]= readgeoraster(RefeName);
Proj = geotiffinfo(RefeName);
LandCover = double(LandCover);

%% ===== 模型 + 情景 =====
ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR'};
CapList  = {'a) ','b) ','c) ','d) '};
SSPList  = {'ssp126','ssp245','ssp370','ssp585'};
IndName  = {'SSP1-2.6','SSP2-4.5','SSP3-7.0','SSP5-8.5'};

%% ===== 读取四个模型的未来变化量数据 =====
for ss = 1:numel(SSPList)
    SSPName = SSPList{ss};

    RiskAll = [];

    for m = 1:numel(ModeList)
        Mode = ModeList{m};

        % ===== 只改这里：文件名 =====
        % File = [Path_RiskAnom Mode '/' SSPName '/DeltaSen.mat'];
        % File = [Path_RiskAnom Mode '/' SSPName '/DeltaRes.mat'];
        File = [Path_RiskAnom Mode '/' SSPName '/DeltaRec.mat'];

        Data = load(File);

        % ===== 只改这里：变量名 =====
        % RiskAll(:,:,m) = Data.DeltaSenTotal;
        % RiskAll(:,:,m) = Data.DeltaRes;
        RiskAll(:,:,m) = Data.DeltaRec;
    end

    %% ===== Multi-model ensemble (MME) =====
    MMEAnom = mean(RiskAll,3,'omitnan');
    MMEAnom = medfilt2(MMEAnom,[2 2],'symmetric');
    %% ====== Fig（以下全部不变）=========

    Thres1 = -2;    % ← 对 ΔSen 建议用对称阈值
    Thres2 =  2;

    Class =   MMEAnom ;
    Class(LandCover == 0 | LandCover == 17) = 999;


% 创建图像
Fig = figure; set(gcf, 'Position', [100, 100, 1200, 600], 'DefaultAxesFontSize', 12);
set(gca, 'Visible', 'off');

% 绘制背景
Background = zeros(size(LandCover));
Background(isnan(Class)) = 2;
ObjImage = grid2image(Background, R);
colormap([1 1 1; 0.3 0.3 0.3]); hold on;
set(ObjImage, 'AlphaData', 0.1);
freezeColors;

% 绘制前景
ObjImage = grid2image(Class, R);

% 设定坐标轴
set(gca, 'Visible', 'on', 'Color', 'none');
set(gca,'Units','Pixels','Position',[25 80 1170 520]);box on;hold on; 
set(gca, 'XLim', [-180 180], 'YLim', [-65 90]);
set(gca, 'XTick', -120:60:120, 'YTick', -30:30:60);
set(gca,'xlabel', [], 'ylabel', []);
set(gca, 'XTickLabel', {}, 'FontSize', 18);
set(gca, 'YTickLabel', {}, 'FontSize', 18);

% 设定颜色映射
ColorMap =  brown2green;
colormap(ColorMap);
set(gca, 'CLim', [Thres1 Thres2]);

% 设置透明度
Class(LandCover == 0 | LandCover == 17) = nan;
AlphaData = ~isnan(Class);
set(ObjImage, 'AlphaData', AlphaData);
set(gca, 'Color', 'white');

% 绘制国家边界
geoshow([WorldShape.Lat], [WorldShape.Lon], 'Color', [0.309 0.309 0.309], 'LineStyle', '-', 'LineWidth', 1.0);


% 颜色条设置
Hbar = colorbar('Location', 'SouthOutside');
Pos = get(Hbar, 'Position');
    % Pos=[Pos(1)+0.45 Pos(2)+0.03 Pos(3)*0.26 Pos(4)*2/3];
  Pos=[Pos(1)+0.25 Pos(2)-0.21+ 0.10 Pos(3)*0.5 Pos(4)];

set(Hbar, 'Position', Pos, 'FontSize', 18);
set(Hbar, 'XLim', [Thres1 Thres2]);
set(Hbar, 'XTick', Thres1:1:Thres2);
TickLabel = cellstr(num2str(get(Hbar, 'XTick')', '%.f'));
TickLabel{1} = '<-2';
TickLabel{end} = '>2';
set(Hbar, 'XTickLabel', TickLabel);


% 标题
text('String',[CapList{ss},IndName{ss},' ensemble mean resilience change'],...
    'Units','Normalized','Position',[0.03 0.1],'Fontsize',20);

% ===============================
% 保存图像
% ===============================
pause(5); set(gcf, 'Position', [100, 100, 1200, 600], 'DefaultAxesFontSize', 20);
print(Fig, '-dtiff', '-r300', [Path_Figure, 'RecGPPchange',SSPName,'.tif']); close(Fig);


end


%% ===============================
% 合并面板
% ===============================
Fig1 = imread([Path_Figure,'RecGPPchangessp126.tif']);
Fig2 = imread([Path_Figure,'RecGPPchangessp245.tif']);
Fig3 = imread([Path_Figure,'RecGPPchangessp370.tif']);
Fig4 = imread([Path_Figure,'RecGPPchangessp585.tif']);

Fig5 = cat(1,cat(2,Fig1,Fig2));
Fig6 = cat(1,cat(2,Fig3,Fig4));

Fig = cat(1,cat(2,Fig5),cat(2,Fig6));
Fig = imresize(Fig,2244/size(Fig,2));

imwrite(Fig,[Path_Figure,'Fig06RecChange.tif'], ...
        'Compression','LZW','Resolution',300);

delete([Path_Figure,'RecGPP*.tif']);

