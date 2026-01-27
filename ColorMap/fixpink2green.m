function Cmap=fixpink2green(WithNaN)

 
n = 50;
Cmap = [  repmat([136 0 183], [n 1]);...   % 深玫红色 (Dark Magenta)
    repmat([197 27 125], [n 1]);...  % 玫红色 (Magenta)
    repmat([222 119 174], [n 1]);... % 粉玫红色 (Pink Magenta)
    repmat([241 182 218], [n 1]);... % 浅玫红色 (Light Magenta)
    repmat([211 232 198],[n 1]);...
    repmat([184 220 124],[n 1]);...    
    repmat([126 167 47],[n 1]);...
    repmat([78 115 1],[n 1])];    
    colormap=Cmap./255;  


    Pink2Green=round(colormap*10^4)/10^4;%����4λС��

Cmap=Pink2Green;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end