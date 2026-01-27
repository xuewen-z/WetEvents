function Cmap=fixblue2red(WithNaN)

 
n = 375;
Cmap = [repmat([0 0 139],[n 1]);...
    repmat([30 144 255],[n 1]);...
    repmat([59 176 73],[n 1]);...
    repmat([102 205 170],[n 1]);...
    repmat([234 208 36],[n 1]);...    
    repmat([227 164 33],[n 1]);...
    repmat([197 101 97],[n 1]); ...
    repmat([209 24 26],[n 1])];    
    colormap=Cmap./255;

    Blue2Red=round(colormap*10^4)/10^4;%����4λС��

Cmap=Blue2Red;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end
