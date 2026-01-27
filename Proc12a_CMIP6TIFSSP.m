
clear; clc; 
addpath(genpath('./'));

Path_LandCover= '../input/';
Path_SSPnc = '../input/CMIP6/';
Path_SSPtif = '../input/CMIP6TIFmon/';

% parameter set 
TimeSpan = 12;

ModeList = {'CMCC-ESM2','CNRM-ESM2-1','IPSL-CM6A-LR'};
SSPList = {'ssp126','ssp245','ssp370','ssp585'};


for  i = 1 : 3
     ModeName = ModeList{i};

     for s = 1 : 4
         SSPName = SSPList{s}; 
       
         Path = fullfile(Path_SSPnc, ModeName);  
         Pattern = ['/gpp_Lmon_',ModeName,'_',SSPName,'_*.nc'];
         Files = dir(fullfile(Path, Pattern));
         FileName = fullfile(Path,Files(1).name);
    
     
     ncinf = ncinfo(FileName);
     Tempor = ncread(FileName,'gpp');

     GeoTemp= double(Tempor); 
     
     % delete Year 保留 2071-2100
     GeoTemp(:,:,1:672) = []; 

     Lat = double(ncread(FileName,'lat'));
     Lon = double(ncread(FileName,'lon'));    
    
     Year = 2071 - 1;  % initialYear - 1

     % geotiff write
       for Index = 1:TimeSpan:size(GeoTemp,3)
            Year = Year + 1; 
            YearName = num2str(Year,'%d');

            MonGPP = GeoTemp(:,:,Index:min(12+Index-1,size(GeoTemp,3)));  
                    
% GeoInfo

            SizeInfo = size(MonGPP);
            R = georasterref('RasterSize',SizeInfo,'Latlim',[min(Lat),max(Lat)],...
                'Lonlim',[min(Lon),max(Lon)]);
            R.ColumnsStartFrom = 'north';


            % AnuGPP = sum(MonGPP,3,'omitnan');

        FilePath =[Path_SSPtif,ModeName,'/',SSPName,'/'];
        system(['mkdir -p ',FilePath]);
        
        FileName = [FilePath,'CMIP6.',ModeName,'.MonGPP.',YearName,'.tif'];
        geotiffwrite(FileName,MonGPP,R,'TiffTags',struct('Compression',Tiff.Compression.LZW));

        disp(['Done with ',YearName]); 
    
       end

      
     end
end




