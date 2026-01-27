 
clear; clc; 
addpath(genpath('./'));

Path_LandCover= '../input/';
Path_CRUdata = '../input/CRU-TS/';


%% Temp 2001-2024

TmpData =[];

        FileName = dir([Path_CRUdata,'*tmp*.nc']);

        for i = 1 : length(FileName)
            ncfile = fullfile(FileName(i).folder, FileName(i).name);
            ncinf = ncinfo(ncfile);
            TmpTempor = ncread(ncfile,'tmp');
      
            TmpTempor =rot90(TmpTempor);
            TmpTempor(301:360,:,:) = [];
    
            %拼接所有月份数据
            TmpData = cat(3, TmpData, TmpTempor);
        end

    nMonth = size(TmpData,3);
    nYear = floor(nMonth / 12);
    
    % === 重塑为年度数据 ===
    TmpData = TmpData(:,:,1:nYear*12);
    DataYear = reshape(TmpData, size(TmpData,1), size(TmpData,2), 12, nYear);
    
    % 年均温（12个月的平均值）
    TaAnnual = squeeze(mean(DataYear,3,'omitnan'));

    % === 计算多年平均 ===
    MulTaAvg = mean(TaAnnual(:,:,1:22),3,'omitnan');

%% pre  2001-2024
     PreData =[];

        FileName = dir([Path_CRUdata,'*pre*.nc']);

        for i = 1 : length(FileName)
            ncfile = fullfile(FileName(i).folder, FileName(i).name);
            ncinf = ncinfo(ncfile);
            PreTempor = ncread(ncfile,'pre');
      
            PreTempor =rot90(PreTempor);
            PreTempor(301:360,:,:) = [];
    
            %拼接所有月份数据
            PreData = cat(3, PreData, PreTempor);
        end

    nMonth = size(PreData,3);
    nYear = floor(nMonth / 12);
    
    % === 重塑为年度数据 ===
    PreData = PreData(:,:,1:nYear*12);
    DataYear = reshape(PreData, size(PreData,1), size(PreData,2), 12, nYear);
    
    % 年均温（12个月的总值）
    PreAnnual = squeeze(sum(DataYear,3,'omitnan'));

    % === 计算多年平均 ===
    MulPreSum = mean(PreAnnual(:,:,1:22),3,'omitnan');

  
    % write
    save([Path_CRUdata,'CRUTS.Mulavg.A20012022.mat'],'-regexp','^Mul*');
        