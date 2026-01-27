function Cmap=brown2green(WithNaN)

 
mycolorpoint=[[84 47 5];...
    [141 80 13];...
    [191 128 49];...
    [224 195 127];...
%     [176 176 176];...
    [211 232 198];...
    [195 222 148];...    
    [86 157 53];...
    [20 91 48]];
mycolorposition=[1 16 31 46 61 76 91 106];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:106,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:106,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:106,'linear','extrap');
colormap=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

Brown2Green=[mycolormap_r',mycolormap_g',mycolormap_b']./255;
Brown2Green=round(colormap*10^4)/10^4;%����4λС��
% Brown2Green=flipud(colormap);
 
Cmap=Brown2Green;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end