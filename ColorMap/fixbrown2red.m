function Cmap=fixbrown2red(WithNaN)

 
n = 375;
Cmap = [repmat([111 55 32],[n 1]);
    repmat([179 130 97],[n 1]);...
    repmat([208 133 60],[n 1]);...
    repmat([221 199 130],[n 1]);...
    repmat([244 165 134],[n 1]);...
    repmat([218 93 73],[n 1]);...    
    repmat([168 30 43],[n 1]);...
    repmat([101 5 32],[n 1])];    
    colormap=Cmap./255;

    Brown2Red=round(colormap*10^4)/10^4;%����4λС��

Cmap=Brown2Red;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end