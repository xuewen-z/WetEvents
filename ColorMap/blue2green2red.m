function Cmap=blue2green2red(WithNaN)

mycolorpoint=[[44 46 121];...
    [51 83 166];...
    [10 113 190];...
    [0 171 175];...
    [104 182 122];...
    [151 192 60];...
    [191 161 51];...
    [250 113 32];...
    [227 57 42];...
    [191 30 38]];
mycolorposition=[1 17 33 49 65 81 97 113 129 145];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:145,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:145,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:145,'linear','extrap');
mycolor=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

Blue2Green2Red=round(mycolor*10^4)/10^4;

Cmap=Blue2Green2Red;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end