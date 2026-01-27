function Cmap = red2green(WithNaN)

% ==========================================
% 连续渐变：Red → Green（插值形式）
% ==========================================

% 关键控制色
mycolorpoint = [
    104   1   31;    % 深红
    191  55   57;    % 红
    218  93   73;    % 浅红
    244 165  134;    % 粉红
    211 232  198;    % 近中性（过渡）
    184 220  124;    % 浅绿
    126 167   47;    % 绿
     78 115    1     % 深绿
];

% 控制位置（等距即可，也可自己微调）
mycolorposition = linspace(1, 64, size(mycolorpoint,1));

% 插值生成连续色带
mycolormap_r = interp1(mycolorposition, mycolorpoint(:,1), 1:64, 'linear','extrap');
mycolormap_g = interp1(mycolorposition, mycolorpoint(:,2), 1:64, 'linear','extrap');
mycolormap_b = interp1(mycolorposition, mycolorpoint(:,3), 1:64, 'linear','extrap');

mycolor = [mycolormap_r', mycolormap_g', mycolormap_b'] ./ 255;

% 保留 4 位小数（与你原函数一致）
Cmap = round(mycolor * 1e4) / 1e4;

% ===============================
% NaN 处理（保持你原来的逻辑）
% ===============================
if nargin < 1
    WithNaN = 0;
end

if WithNaN ~= 0
    Cmap = [1 1 1; Cmap];
end

end
