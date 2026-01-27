clear;clc;

addpath(genpath('./'));

Path_LandCover = '../input/';
Path_MOD17DGPP = '/public/data/xuewen/MOD17A2HGF/03_WGS178DGPP/';
Path_Mul17GPPts = '../output/01_Mul17MonGPPts/';

system(['rm -rf ',Path_Mul17GPPts]);
system(['mkdir -p ',Path_Mul17GPPts]);

RefeName = [Path_LandCover,'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];  %Landcover坐标
[LandCover,R]= readgeoraster(RefeName);
Proj = geotiffinfo(RefeName);

LandCover = double(LandCover);


for Year = 2001:2023
    YearName = num2str(Year,'%d');
       
    k = 0;
    Mul17GPPts = nan([R.RasterSize,46]) ;


    for Date = 1: 8 : 365
        DateName = sprintf('%03d',Date);
        k = k+1;
        FileName = dir([Path_MOD17DGPP,YearName,'/','MOD17GPP.A',YearName,'.',DateName,'.tif']);
        MOD17DGPP = readgeoraster(fullfile(FileName.folder,FileName.name));
        MOD17DGPP(301:360,:) = [];
        MOD17DGPP =double(MOD17DGPP).* 0.1;   %1/10000 scale factors  kg to 1000 g
        MOD17DGPP(MOD17DGPP<0) = nan;
        MOD17DGPP(LandCover == 0 | LandCover == 17| LandCover == 13|LandCover == 15 | LandCover == 16) =nan;
        Mul17GPPts(:,:,k) = MOD17DGPP;
    end

    StartDate = datetime(Year,1,1);
    Dates = StartDate + days(8*(0:45));  % 46个8天期
    Months = month(Dates);              % 对应每个8天期的月份

    % 初始化每月 GPP（总量）
    GPPmonth = nan([size(Mul17GPPts,1), size(Mul17GPPts,2), 12]);
    
    for m = 1:12
        idx = find(Months == m);
        Temp = Mul17GPPts(:,:,idx);
        
        % 判断每个像元是否在该月全部为 NaN
        Allnanmask = all(isnan(Temp), 3);
        
        % 按月求和（跳过 NaN）
        TempGPPmon = sum(Temp, 3, 'omitnan');% 按月求和  gC/m2/month
        
        % 把那些原本全为 NaN 的像元重新设回 NaN（避免变成 0）
        TempGPPmon(Allnanmask) = NaN;
        GPPmonth(:,:,m) = TempGPPmon;

       
    end

 
    FileName=[Path_Mul17GPPts,'MOD17MonGPP.A',YearName,'.CMG050DEG.tif'];
             geotiffwrite(FileName,GPPmonth,R,'GeoKeyDirectoryTag',...
             Proj.GeoTIFFTags.GeoKeyDirectoryTag,'TiffTags',struct('Compression',Tiff.Compression.LZW));

    disp(['Done with ',YearName])
   
 end
       
       