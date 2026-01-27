clear;clc;

addpath(genpath('./'));

Path_LandCover = '../input/';
Path_YrSPEImon = '../input/SPEI/SPEI2TIF/';
Path_SPEIts = '../output/03_MulSPEIts/';

system(['rm -rf ',Path_SPEIts]);
system(['mkdir -p ',Path_SPEIts]);

RefeName = [Path_LandCover,'LCTIGBP_USGS_MCD12Q1_Y10_CMG050DEG_20012010.tif'];  %Landcover坐标
[LandCover,R]= readgeoraster(RefeName);
Proj = geotiffinfo(RefeName);
LandCover = double(LandCover);


SPEIList = {'spei03'};
SPEIName = SPEIList{1};

for Year = 2001:2022
    YearName = num2str(Year,'%d');
       
      MonSPEI = readgeoraster([Path_YrSPEImon,SPEIName,'M.A',YearName,'01.CMG05DEG.tif']);
      MonSPEI(301:360,:,:)= [];
      
      Mask = (LandCover == 0 | LandCover == 17 | LandCover == 13 | LandCover == 15 | LandCover == 16);  % 2D逻辑掩膜
      % 扩展掩膜到3D
      Mask3D = repmat(Mask, [1, 1,size(MonSPEI,3)]);
      MonSPEI(Mask3D) =nan;

      save([Path_SPEIts,SPEIName,'.MonSPEI',YearName,'.mat'],'-regexp','^MonSPEI*');
      disp(['Done with ',YearName])
    
end

  



