clear; clc;

Path_CMIP6TIF = '../input/CMIP6TIFmon/';
Path_Output   = '../output/13_CMIP6TIFadj/';

system(['rm -rf ',Path_Output]);
system(['mkdir -p ',Path_Output]);

ModeList = {'CMCC-ESM2','CNRM-ESM2-1','IPSL-CM6A-LR','MPI-ESM1-2-HR'};
SSPList  = {'historical','ssp126','ssp245','ssp370','ssp585'};


for i = 1:length(ModeList)
    ModeName = ModeList{i};
    
    for s = 1:length(SSPList)
        SSPName = SSPList{s};
        
        InPath = fullfile(Path_CMIP6TIF, ModeName, SSPName);
        OutPath = fullfile(Path_Output, ModeName, SSPName);
        system(['mkdir -p ', OutPath]);
        
        Files = dir(fullfile(InPath,'*.tif'));
        
        for f = 1:length(Files)
            InFile  = fullfile(InPath,Files(f).name);
            [GPPTemp,Rin] = readgeoraster(InFile);
            GPPTemp = double(GPPTemp);

            % === Step 1: 方向修正 ===
            GPPTemp = rot90(GPPTemp,1);
          
            nCols = size(GPPTemp,2);
            GPPTemp = cat(2, ...
            GPPTemp(:, nCols/2+1:end, :), ...
            GPPTemp(:, 1:nCols/2, :) );

            %kg/m2/s to gC/m2/year
            GPPTemp = GPPTemp.* (1000/12).*86400.*365; 
            
            % === Step 2: 重新生成空间参考 ===
            nRows = size(GPPTemp,1);
            nCols = size(GPPTemp,2);
            Rfix = georasterref( ...
                'RasterSize',[nRows nCols], ...
                'Latlim',Rin.LatitudeLimits, ...
                'Lonlim',[-180 180]);
            Rfix.ColumnsStartFrom = 'north';

             % === Step 3: 保存 ===
            OutFile = fullfile(OutPath,Files(f).name);
            geotiffwrite(OutFile,GPPTemp,Rfix,'TiffTags',struct('Compression',Tiff.Compression.LZW));

            disp(['Done (no resample): ', ModeName,' - ',SSPName,' - ',Files(f).name]);
        end
    end
end