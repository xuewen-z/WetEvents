function Cmap=heatcolor(WithNaN)

 
mycolorpoint=[[46 69 149];...
[79 119 180];...	
[119 169 204];...		
[166 209 225];...		
[218 237 241];...		
[252 222 152];...		
[242 172 112];...		
[226 127 88];...		
[200 77 62];...		
[143 44	49]];
mycolorposition=[1 8 15 22 29 36 43 50 57 64];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:64,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:64,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:64,'linear','extrap');
mycolor=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

Heatcolor=round(mycolor*10^4)/10^4;%±£Áô4Î»Ð¡Êý
    
Cmap=Heatcolor;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end
