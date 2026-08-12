clear; clc; 
addpath(genpath('./'));

Path_LandCover= '../input/';
Path_SSPnc   = '../input/CMIP6/';
Path_SSPtif  = '../input/CMIP6TIFmon/';

% parameter set 
TimeSpan = 12;

ModeList = {'NorESM2-MM'};   % 先举例 MPI 模型
SSPList  = {'ssp126','ssp245','ssp370','ssp585'};



for i = 1:length(ModeList)
    ModeName = ModeList{i};

    for s = 1:length(SSPList)
        SSPName = SSPList{s}; 
        
        PathMode = fullfile(Path_SSPnc, ModeName);
        Pattern  = ['gpp_Lmon_',ModeName,'_',SSPName,'_*.nc'];
        Files    = dir(fullfile(PathMode, Pattern));
        
                
        % ---- 拼接所有文件数据 ----
        GeoTempAll = [];
        for f = 1:length(Files)
            FileName = fullfile(PathMode, Files(f).name);
            Tempor   = ncread(FileName,'gpp');
            GeoTempAll = cat(3, GeoTempAll, double(Tempor));
            
            if f == 1
                Lat = double(ncread(FileName,'lat'));
                Lon = double(ncread(FileName,'lon'));
            end
        end
        
         % delete Year 保留 2071-2100
         GeoTempAll(:,:,1:671) = []; 

        % ---- 从 2071 开始逐年计算 ----
        Year = 2071 - 1;  % initialYear - 1

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
            
            % 输出路径
            FilePath = fullfile(Path_SSPtif, ModeName, SSPName);
            system(['mkdir -p ',FilePath]);
            
            OutName = [FilePath,'/CMIP6.',ModeName,'.MonGPP.',YearName,'.tif'];
            geotiffwrite(OutName,MonGPP,R,'TiffTags',struct('Compression',Tiff.Compression.LZW));
            
            disp(['Done with ',ModeName,' ',SSPName,' ',YearName]); 
        end
    end
end
