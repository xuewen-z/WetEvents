function Cmap=phenometric(WithNaN)

mycolorpoint=[[28 135 201];...
    [110 202 203];...
    [129 195 64];...
    [242 235 23];...
    [229 191 32];...
    [245 127 33];...
    [238 31 35];...
    [86 40 122];...
    [126 75 157];...
    [63 77 160]];
    
   
mycolorposition=[1 17 33 49 65 81 97 113 129 145];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:145,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:145,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:145,'linear','extrap');
mycolor=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

Colorful=round(mycolor*10^4)/10^4;

Cmap=Colorful;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end