function Cmap=blue2red2purple(WithNaN)

 
mycolorpoint=[[0 143 214];...	
[148 219 239];...		
[0 193 29];...		
[177 238 143];...		
[241 12 0];...		
[248 168 161];...		
[255 138 0];...		
[255 203 112];...		
[148 82	190];...
[225 190 230]];
mycolorposition=[1 8 15 22 29 36 43 50 57 64];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:64,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:64,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:64,'linear','extrap');
mycolor=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

Bule2Red2Purple=round(mycolor*10^4)/10^4;%±£Áô4Î»Ð¡Êý
    
Cmap=Bule2Red2Purple;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end
