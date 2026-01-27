function Cmap=colorful2(WithNaN)

mycolorpoint=[[196 0 0];...
    [253 1 0];...
    [254 51 0];...
    [255 168 0];...
    [253 226 2];...
    [225 227 16];...
    [162 211 112];...
    [69 171 165];...
    [80 109 171];...
    [211 218 237]];
mycolorposition=[1 17 33 49 65 81 97 113 129 145];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:145,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:145,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:145,'linear','extrap');
mycolor=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

Colorful2=round(mycolor*10^4)/10^4;

Cmap=Colorful2;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end