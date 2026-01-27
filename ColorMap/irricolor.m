function Cmap=irricolor(WithNaN)
% 240, 244, 41
mycolorpoint=[[249 206 61];...  
    [252, 182, 45];...
    [241, 130, 79];...
    [213, 86, 108];...
    [179, 44, 139];...
    [129, 4, 165];...
    [68, 4, 157]];
mycolorposition=[1 17 33 49 65 81 97];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:97,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:97,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:97,'linear','extrap');
mycolor=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

IrriColor=round(mycolor*10^4)/10^4;

Cmap=IrriColor;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end