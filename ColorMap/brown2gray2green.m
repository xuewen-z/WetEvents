function Cmap=brown2gray2green(WithNaN)

mycolorpoint=[[208 133 60];...
    [227 164 97];...
    [247 205 130];...
    [246 224 157];...
    [224 226 217];...
    [211 232 198];...
    [164 213 169];...
    [77 190 159];...
    [70 168 165]];
mycolorposition=[1 8 15 22 29 36 43 50 57];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:57,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:57,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:57,'linear','extrap');

Brown2green=[mycolormap_r',mycolormap_g',mycolormap_b']./255;
Brown2green=round(Brown2green*10^4)/10^4;

Cmap=Brown2green;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end