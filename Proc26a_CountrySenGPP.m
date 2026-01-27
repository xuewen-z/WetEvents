clear; clc;
addpath(genpath('./'));

% ===============================
% 路径
% ===============================
Path_LandCover = '../input/';
Path_Change    = '../output/23b_MMEDeffSen/';   % pixel-scale MME ΔSen
Path_Out       = '../output/26_CountrySenGPP/';

system(['rm -rf ', Path_Out]);
system(['mkdir -p ', Path_Out]);

% ===============================
% 情景
% ===============================
SSPList = {'ssp126','ssp245','ssp370','ssp585'};

% ===============================
% LandCover（仅自然植被）
% ===============================
LCfile = [Path_LandCover,...
    'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];
LandCover = double(readgeoraster(LCfile));

InValidLC = (LandCover == 0 | LandCover == 17 | LandCover == 15);

% ===============================
% 国家栅格
% ===============================
[CountryID, R] = readgeoraster([Path_LandCover,'Country_CMG050DEG.tif']);
CountryID = double(CountryID);

CountryID(InValidLC) = NaN;   % 非植被一律剔除
CountryList = unique(CountryID(~isnan(CountryID)));

% ===============================
% 主循环
% ===============================
for s = 1:numel(SSPList)

    SSPName = SSPList{s};
    disp(['Processing country ΔSen (clean): ', SSPName]);

    % ---- 读取像元尺度 MME ΔSen ----
    Data = load(fullfile(Path_Change, SSPName, 'DeltaSen_MME.mat'));
    DeltaMap = Data.MMESen;

    % ---- 仅保留有限值 ----
    DeltaMap(~isfinite(DeltaMap)) = NaN;

    % ===============================
    % 国家尺度统计
    % ===============================
    CountryStat = nan(size(CountryList));
    MinPix = 10;   % 最少有效像元阈值（强烈推荐）

    for c = 1:numel(CountryList)
        idx = (CountryID == CountryList(c));
        vals = DeltaMap(idx);

        vals = vals(isfinite(vals));   % 再保险

        if numel(vals) >= MinPix
            CountryStat(c) = mean(vals,'omitnan');   % 或 median
        else
            CountryStat(c) = NaN;
        end
    end

    % ===============================
    % 回填国家尺度栅格（一个国家一个值）
    % ===============================
    CountrySen = nan(size(DeltaMap));
    for c = 1:numel(CountryList)
        CountrySen(CountryID == CountryList(c)) = CountryStat(c);
    end

    % ===============================
    % 输出
    % ===============================
    OutPath = fullfile(Path_Out, SSPName);
    system(['mkdir -p ', OutPath]);

    CountryTable = table(CountryList(:), CountryStat(:), ...
        'VariableNames', {'CountryID','DeltaSen'});

    save(fullfile(OutPath,'CountryDeltaSen.mat'), ...
        'CountrySen','CountryTable','-v7.3');
end

