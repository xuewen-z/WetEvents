function mycolorpoint=rbycolor()
        % 原始颜色点（红 → 蓝 →黄 ）
        baseColors = [211 43 43;
                      61 96 137;
                      249 206 61] / 255;  % 转换为 0-1 范围
        
        % 指定生成的 colormap 长度，例如 256 级
        nColors = 256;
        
        % 在三种颜色之间做插值
        % 创建一个分段插值索引
        interpSteps = linspace(1, 3, nColors);
        
        % 对每个通道分别插值
        r = interp1(1:3, baseColors(:,1), interpSteps, 'linear');
        g = interp1(1:3, baseColors(:,2), interpSteps, 'linear');
        b = interp1(1:3, baseColors(:,3), interpSteps, 'linear');
        
        % 合并为 colormap
        mycolorpoint = [r', g', b'];
        
end
