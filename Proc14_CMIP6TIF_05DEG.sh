#!/bin/bash

InPath="../output/13_CMIP6TIFadj"
OuPath="../output/14_CMIP6TIF_05DEG"

rm -rf   $OuPath/
mkdir -p $OuPath/

Thread=1

# 遍历模型
for Model in $(ls $InPath); do
  # 遍历情景
  for SSP in $(ls $InPath/$Model); do
    mkdir -p $OuPath/$Model/$SSP

    for InName in $(ls $InPath/$Model/$SSP/*.tif); do
      InFile=$(basename $InName)
      OuFile=$OuPath/$Model/$SSP/$InFile

      echo "正在处理 $Model / $SSP / $InFile"

      gdalwarp $InName $OuFile -r bilinear -tr 0.5 0.5 -te -180 -60 180 90 -srcnodata 0 -dstnodata 0 -co COMPRESS=DEFLATE -t_srs "+proj=longlat +ellps=WGS84" &
        

      # 多线程控制
      echo $(( Thread++ ))
      if (( $Thread % 12 == 0 )); then
        wait
      fi
    done
  done
done

wait
echo "全部完成！"

