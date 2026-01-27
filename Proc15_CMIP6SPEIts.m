clear;clc;
addpath(genpath('./'));

% 输入输出路径
Path_LandCover = '../input/';
Path_YrSPEImon = '../input/CMIP6SPEI/';   % 解压后的 SPEI 月度 tif
Path_SPEIts    = '../output/15_CMIP6SPEIts/';

% system(['rm -rf ',Path_SPEIts]);
% system(['mkdir -p ',Path_SPEIts]);


% 参考文件
RefeName = [Path_LandCover,'LCTIGBP_USGS_MCD12Q1_Y10_CMG025DEG_20012010.tif'];  
[LandCover,R]= readgeoraster(RefeName);
LandCover = double(LandCover);

% 掩膜 (非陆地)
Mask = (LandCover == 0 | LandCover == 17 | LandCover == 13 | ...
        LandCover == 15 | LandCover == 16);

% 模型 & 情景 & SPEI
ModeList = {'CMCC-ESM2','MPI-ESM1-2-HR'};
SSPList  = {'historical','ssp126','ssp245','ssp370','ssp585'};
SPEIList = {'SPEI_3'};

for i = 2:numel(ModeList)
    ModeName = ModeList{i};

    for j = 1:numel(SPEIList)
        SPEIName = SPEIList{j};

        InPath = fullfile(Path_YrSPEImon, [ModeName '-' SPEIName], SPEIName);
        Files  = dir(fullfile(InPath,'*.tif'));

        for s = 1:numel(SSPList)
            SSPName = SSPList{s};

            SSPFiles = Files(contains({Files.name}, SSPName));

            % 提取年份
            Years = unique(cellfun(@(x) str2double(x(end-9:end-6)), ...
                                   {SSPFiles.name}));

            % === 每一年单独处理 ===
            for y = 1:numel(Years)

                Year = Years(y);
                YearFiles = SSPFiles(contains({SSPFiles.name}, num2str(Year)));

                MonStack = [];

                for f = 1:numel(YearFiles)
                    MonFile = fullfile(InPath,YearFiles(f).name);
                    MonSPEI = readgeoraster(MonFile);
                    MonSPEI = double(MonSPEI);

                    % 掩膜
                    MonSPEI(Mask) = nan;

                    MonStack = cat(3,MonStack,MonSPEI);
                end

                % === 直接保存“年 × 月（12 band）” ===
                FilePath = fullfile(Path_SPEIts,ModeName,SSPName);
                system(['mkdir -p ',FilePath]);

                OutName = fullfile(FilePath, ...
                    [ModeName,'_',SPEIName,'_',SSPName,'_',num2str(Year),'.MonSPEI_025DEG.tif']);

                geotiffwrite(OutName,MonStack,R, ...
                    'TiffTags',struct('Compression',Tiff.Compression.LZW));

                disp(['Done: ',ModeName,' - ',SPEIName,' - ',SSPName,' - ',num2str(Year)]);
            end
        end
    end
end
