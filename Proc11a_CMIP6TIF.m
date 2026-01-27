
clear; clc; 
addpath(genpath('./'));

Path_LandCover= '../input/';
Path_SSPnc = '../input/CMIP6/';
Path_SSPtif = '../input/CMIP6TIFmon/';

system(['rm -rf ',Path_SSPtif]);
system(['mkdir -p ',Path_SSPtif]);

% parameter set 
TimeSpan = 12;

ModeList = {'CMCC-ESM2','CNRM-ESM2-1','IPSL-CM6A-LR'};
FileList ={'gpp_Lmon_CMCC-ESM2_historical_r1i1p1f1_gn_185001-201412.nc',...
           'gpp_Lmon_CNRM-ESM2-1_historical_r1i1p1f2_gr_185001-201412.nc',...
           'gpp_Lmon_IPSL-CM6A-LR_historical_r1i1p1f1_gr_185001-201412.nc'};


for  i = 1 : 3
    
     ModeName = ModeList{i};
         
     FileName = [Path_SSPnc,ModeName,'/',FileList{i}];
     ncinf = ncinfo(FileName);
     Tempor = ncread(FileName,'gpp');

     GeoTemp= double(Tempor); 
     
     % delete Year 1850-1979  保留 1980-2100
     GeoTemp(:,:,1:1560) = []; 
     
     Lat = double(ncread(FileName,'lat'));
     Lon = double(ncread(FileName,'lon'));    
    
     Year = 1980 - 1;  % initialYear - 1

     % geotiff write
       for  Index = 1:TimeSpan:size(GeoTemp,3)
            Year = Year + 1; 
            YearName = num2str(Year,'%d');

            MonGPP = GeoTemp(:,:,Index:min(12+Index-1,size(GeoTemp,3)));  
                    
% GeoInfo

            SizeInfo = size(MonGPP);
            R = georasterref('RasterSize',SizeInfo,'Latlim',[min(Lat),max(Lat)],...
                'Lonlim',[min(Lon),max(Lon)]);
            R.ColumnsStartFrom = 'north';


            % AnuGPP = sum(MonGPP,3,'omitnan');

        FilePath =[Path_SSPtif,ModeName,'/historical/'];
        system(['mkdir -p ',FilePath]);

        FileName = [FilePath,'CMIP6.',ModeName,'.MonGPP.',YearName,'.tif'];
        geotiffwrite(FileName,MonGPP,R,'TiffTags',struct('Compression',Tiff.Compression.LZW));

        disp(['Done with ',YearName]); 
    
       end

       
end




