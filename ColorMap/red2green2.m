function Cmap = red2green(WithNaN)

% ==========================================
% 连续渐变：Red → Green（0 偏绿版）
% ==========================================

mycolorpoint = [
    104   1   31;    % 深红
    191  55   57;    % 红
    218  93   73;    % 浅红
    244 165  134;    % 粉红
    211 232  198;    % 中性（偏绿）
    184 220  124;    % 浅绿
    126 167   47;    % 绿
     78 115    1     % 深绿
];

% ★ 关键修改：绿色提前出现
mycolorposition = [1 8 14 20 24 36 52 64];

mycolormap_r = interp1(mycolorposition, mycolorpoint(:,1), 1:64, 'linear','extrap');
mycolormap_g = interp1(mycolorposition, mycolorpoint(:,2), 1:64, 'linear','extrap');
mycolormap_b = interp1(mycolorposition, mycolorpoint(:,3), 1:64, 'linear','extrap');

mycolor = [mycolormap_r', mycolormap_g', mycolormap_b'] ./ 255;
Cmap = round(mycolor * 1e4) / 1e4;

if nargin < 1
    WithNaN = 0;
end

if WithNaN ~= 0
    Cmap = [1 1 1; Cmap];
end

end
