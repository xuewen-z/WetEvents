clear; clc; 
addpath(genpath('./'));

Path_LandCover= '../input/';
Path_SSPnc = '../input/CMIP6/';
Path_SSPtif = '../input/CMIP6TIFmon/';

% parameter set 
TimeSpan = 12;

ModeList = {'MPI-ESM1-2-HR'};  
HistPattern = 'gpp_Lmon_MPI-ESM1-2-HR_historical_*.nc';  % 历史文件通配符

for i = 1:length(ModeList)
    
    ModeName = ModeList{i};
    PathMode = fullfile(Path_SSPnc, ModeName);
    
    % 找到该模式下所有历史时期文件（按5年分割）
    Files = dir(fullfile(PathMode, HistPattern));
    
    
    % ---- 拼接所有文件数据 ----
    GeoTempAll = [];
    for f = 1:length(Files)
        FileName = fullfile(PathMode, Files(f).name);
        Tempor   = ncread(FileName,'gpp');
        GeoTempAll = cat(3, GeoTempAll, double(Tempor));
        
        if f == 1
            % 只需要一次读取经纬度信息
            Lat = double(ncread(FileName,'lat'));
            Lon = double(ncread(FileName,'lon')); 
        end
    end
    
  
    % ---- 从1980年开始逐年计算 ----
    Year = 1980 - 1;  % initialYear - 1
    for Index = 1:TimeSpan:size(GeoTempAll,3)
        Year = Year + 1; 
        YearName = num2str(Year,'%d');
        
        MonGPP = GeoTempAll(:,:,Index:min(Index+11,size(GeoTempAll,3)));  
        
        % GeoInfo
        SizeInfo = size(MonGPP(:,:,1));
        R = georasterref('RasterSize',SizeInfo,'Latlim',[min(Lat),max(Lat)],...
            'Lonlim',[min(Lon),max(Lon)]);
        R.ColumnsStartFrom = 'north';
        
        % 年际总和
        % AnuGPP = sum(MonGPP,3,'omitnan');
        
        % 保存输出
        FilePath = fullfile(Path_SSPtif, ModeName,'/historical/');
        system(['mkdir -p ',FilePath]);
        
        OutName = [FilePath,'/CMIP6.',ModeName,'.MonGPP.',YearName,'.tif'];
        geotiffwrite(OutName,MonGPP,R,'TiffTags',struct('Compression',Tiff.Compression.LZW));
        
        disp(['Done with ',YearName]); 
    end
end
