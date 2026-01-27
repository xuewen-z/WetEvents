function Cmap=fixred2green(WithNaN)

 
n = 50;
Cmap = [  repmat([104 1 31],[n 1]);...
    repmat([191 55 57],[n 1]);...    
    repmat([218 93 73],[n 1]);...
    repmat([244 165 134],[n 1]);...
    repmat([211 232 198],[n 1]);...
    repmat([184 220 124],[n 1]);...    
    repmat([126 167 47],[n 1]);...
    repmat([78 115 1],[n 1])];    
    colormap=Cmap./255;  


    Red2Green=round(colormap*10^4)/10^4;%����4λС��

Cmap=Red2Green;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end