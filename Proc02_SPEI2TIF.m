 
clear; clc; 
addpath(genpath('./'));

Path_LandCover= '../input/';
Path_SPEInc = '../input/SPEI/';
Path_SPEItif = '../input/SPEI/SPEI2TIF/';

system(['rm -rf ',Path_SPEItif]);
system(['mkdir -p ',Path_SPEItif]);

SPEIList = {'spei01','spei03','spei06',...
    'spei09','spei12','spei18','spei24'};

for i = 1 : numel(SPEIList)
    SPEIName = SPEIList{i};
FileName = [Path_SPEInc,SPEIName,'.nc'];
ncinf = ncinfo(FileName);
Tempor = ncread(FileName,'spei');
Tempor(:,:,1:1200) = [];  % delete 1901-2000


TimeSpan = 12;
Year = 2001 - 1; 

 for Index = 1:TimeSpan:size(Tempor,3)
            Year = Year + 1; 
            YearName = num2str(Year,'%d');

            MSPEI = Tempor(:,:,Index:min(12+Index-1,size(Tempor,3)));  
            MSPEI = rot90(MSPEI); 
   
     SizeInfo = size(MSPEI);
     
     Lon = double(ncread(FileName,ncinf.Variables(1).Name));
     Lat = double(ncread(FileName,ncinf.Variables(2).Name));

%    geotiff write

    R = georasterref('RasterSize',SizeInfo,'Latlim',[min(Lat),max(Lat)],...
        'Lonlim',[min(Lon),max(Lon)]);
    R.ColumnsStartFrom = 'north';
    FileName_TIF =[Path_SPEItif,SPEIName,'M.A',YearName,'01.CMG05DEG.tif'];
    geotiffwrite(FileName_TIF,MSPEI,R,'TiffTags',struct('Compression',Tiff.Compression.Deflate));
    
  
    
 end

   disp(['Done with ',SPEIName]); 
   
end