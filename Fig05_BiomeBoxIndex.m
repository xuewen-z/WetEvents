clear; clc;
addpath(genpath('./'));

Path_Boxdata = '../output/11_IndexBoxBiome/';
Path_Figure  = '../figure/';

IndexList = {'Sen','Res','Rec'};
LevelList = {'Moderate','Severe','Extreme','Total'};

% === 颜色：4 个等级 ===
ColorLevel = [
    253 191 111;   % Moderate
    158 202 225;   % Severe
    106 81 163;    % Extreme
    222 45 38      % Total
] ./ 255;

for k = 1:numel(IndexList)

    IndexName = IndexList{k};
    disp(['=== Plotting ',IndexName,' ===']);

    % ===============================
    % 读取 4 个等级的 BoxData
    % ===============================
    DataLevel = cell(numel(LevelList),1);
    for l = 1:numel(LevelList)
        tmp = load([Path_Boxdata,IndexName,'_',LevelList{l},'.BoxData_Biome.mat']);
        DataLevel{l} = tmp;
    end

    % biome 顺序（以第一个等级为准）
    [BiomeID,~,~] = unique(DataLevel{1}.BoxLC,'stable');
    nBiome = numel(BiomeID);

    % ===============================
    % 组织 boxplot 输入
    % ===============================
    BoxValAll = [];
    BoxGroup  = {};
    BoxPos    = [];

    gap   = 1;        % biome 间距
    width = 0.18;     % 单箱宽
    pos0  = 1;

    for i = 1:nBiome
        for l = 1:numel(LevelList)

            idx = strcmp(DataLevel{l}.BoxLC, BiomeID{i});
            v   = DataLevel{l}.BoxVal(idx);

            % === Res / Rec 取 log10，Sen 不变 ===
            if ismember(IndexName, {'Res','Rec'})
                v = v(v > 0);        % log10 只能用于正值
                v = log10(v);
            end

            if isempty(v)
                continue;
            end

            BoxValAll = [BoxValAll; v];
            BoxGroup  = [BoxGroup; ...
                repmat({[BiomeID{i},'_',LevelList{l}]}, numel(v), 1)];

            BoxPos = [BoxPos; pos0 + (l-2.5)*width];
        end
        pos0 = pos0 + gap;
    end

    % ===============================
    % 绘图
    % ===============================
    Fig = figure;
    set(gcf,'Position',[100 100 1200 480],'Color','w');
    hold on;

    boxplot(BoxValAll, BoxGroup, ...
        'Positions',BoxPos, ...
        'Symbol','', ...
        'Widths',width*0.9, ...
        'Whisker',1.5, ...
        'Colors','k');

    % === 填充箱体颜色 ===
    boxes = findobj(gca,'Tag','Box');
    boxes = flipud(boxes);   % 修正顺序

    cID = repmat(1:4,1,nBiome);
    for j = 1:numel(boxes)
        patch(get(boxes(j),'XData'), get(boxes(j),'YData'), ...
              ColorLevel(cID(j),:), ...
              'FaceAlpha',0.85, 'EdgeColor','k');
    end

    % ===============================
    % 坐标轴
    % ===============================
    set(gca,'XTick',1:nBiome, ...
        'XTickLabel',BiomeID, ...
        'FontSize',14, ...
        'LineWidth',1.2);
    xtickangle(30);

    % ★ 关键：锁定 y 轴模式（否则 ylim 不生效）
    ax = gca;
    ax.YLimMode = 'manual';

    % === y 轴标签 & 范围 ===
    switch IndexName
        case 'Sen'
            ylabel('sensitivity','FontSize',18);
            ylim([-1 1]);
            yticks(-1:0.5:1);

        case 'Res'
            ylabel('log_{10}(resistance)','FontSize',18);
            ylim([0 3.5]);                 % = log10(5)
            yticks(0:1:4);

        case 'Rec'
            ylabel('log_{10}(resilience)','FontSize',18);
            ylim([-1.5 2]);                % = log10(3)
            yticks(-1:1:2);
    end

    box on;
    ax.TickDir = 'out';

    % ===============================
    % 图例
    % ===============================
    lgd = legend(LevelList, ...
        'Location','northoutside', ...
        'Orientation','horizontal', ...
        'FontSize',14);
    set(lgd,'Box','off');

    % ===============================
    % 面板标注
    % ===============================
    text(0.02,0.92,[char('a'+k-1),')'], ...
        'Units','normalized','FontSize',20);

    % ===============================
    % 保存（需要时再打开）
    % ===============================
    print(Fig,'-dtiff','-r300', ...
        [Path_Figure,IndexName,'BoxplotBiome.tif']);
    close(Fig);

end


%% ===============================
% 合并面板
% ===============================
Fig1 = imread([Path_Figure,'SenBoxplotBiome.tif']);
Fig2 = imread([Path_Figure,'ResBoxplotBiome.tif']);
Fig3 = imread([Path_Figure,'RecBoxplotBiome.tif']);

Fig = cat(1,cat(2,Fig1),cat(2,Fig2),cat(2,Fig3));
Fig = imresize(Fig,2244/size(Fig,2));
imwrite(Fig,[Path_Figure,'Fig05BoxplotBiome.tif'], ...
        'Compression','LZW','Resolution',300);

delete([Path_Figure,'SenBoxplotBiome.tif']);
delete([Path_Figure,'ResBoxplotBiome.tif']);
delete([Path_Figure,'RecBoxplotBiome.tif']);
