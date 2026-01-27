function Cmap=sunset(WithNaN)
 
mycolorpoint=[[99 80 112];...
    [184 123 120];...
    [223 74 68];...
    [243 138 33];...
    [247 217 119]];
mycolorposition=[1 11 21 31 41];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:41,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:41,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:41,'linear','extrap');
mycolor=[mycolormap_r',mycolormap_g',mycolormap_b']./255;
colormap=round(mycolor*10^4)/10^4;%±£Áô4Î»Ð¡Êý

Sunset=flipud(colormap);
    
  Cmap=Sunset;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end