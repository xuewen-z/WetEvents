function Cmap=blue2yellow2red(WithNaN)

 
mycolorpoint=[[7 85 152];...
[110 191 214];...	
[208 237 248];...		
[247 246 195];...		
[251 228 118];...		
[236 162 59];...		
[234 137 47];...		
[214 99 38];...		
[188 72 38];...		
[147 51	30]];
mycolorposition=[1 8 15 22 29 36 43 50 57 64];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:64,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:64,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:64,'linear','extrap');
mycolor=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

Bule2Yellow2Red=round(mycolor*10^4)/10^4;%±£Áô4Î»Ð¡Êý
    
Cmap=Bule2Yellow2Red;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end
