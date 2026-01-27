function Cmap=fixred2blueType(WithNaN)

 
n = 50;

Cmap = [  repmat([255 0 0],[n 1]);...
    repmat([255 60 60],[n 1]);...              % 明亮红
    repmat([255 110 110],[n 1]);...            % 偏粉红/亮红
    repmat([255 180 180],[n 1]);...            % 很浅的粉色红
    repmat([175 210 245],[n 1]);...       % 浅蓝（天蓝过渡）
    repmat([100 160 220],[n 1]);...       % 正常浅蓝
    repmat([50 115 200],[n 1]);...        % 适中深蓝
    repmat([20 60 130],[n 1])];           % 深蓝（但不黑
    colormap=Cmap./255;  

    Red2Blue=round(colormap*10^4)/10^4;%����4λС��

Cmap=Red2Blue;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end