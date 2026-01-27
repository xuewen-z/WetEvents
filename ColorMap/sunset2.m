function Cmap=sunset2(WithNaN)
 
mycolorpoint=[[93 31 82];...
    [168 78 78];...
    [178 62 63];...
    [216 114 89];...
    [255 161 110];...
    [254 188 128];...
    [243 214 210]];
mycolorposition=[1 11 21 31 41 51 61];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:61,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:61,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:61,'linear','extrap');
mycolor=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

Sunset2=round(mycolor*10^4)/10^4;%±£Áô4Î»Ð¡Êý

    
  Cmap=Sunset2;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end