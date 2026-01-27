function Cmap=fixbrown2purp(WithNaN)

 
n = 375;
Cmap = [repmat([84 47 5],[n 1]);
    repmat([141 80 13],[n 1]);...
    repmat([191 128 49],[n 1]);...
    repmat([224 195 127],[n 1]);...
    repmat([217 218 236],[n 1]);...
    repmat([178 172 210],[n 1]);...
    repmat([130 117 173],[n 1]);...    
    repmat([85 39 137],[n 1])];    
  
    colormap=Cmap./255;

    Brown2Purp=round(colormap*10^4)/10^4;%����4λС��

Cmap=Brown2Purp;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end