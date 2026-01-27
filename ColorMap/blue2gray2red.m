function Cmap=blue2gray2red(WithNaN)

mycolorpoint=[[4 51 107];...
    [31 101 170];...
    [66 148 195];...
    [146 198 219];...
    [204 226 237];...
    [249 216 197];...
    [244 165 134];...
    [218 93 73];...
    [168 30 43];...
    [101 5 32]];
mycolorposition=[1 8 15 22 29 36 43 50 57 64];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:64,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:64,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:64,'linear','extrap');

Blue2Red=[mycolormap_r',mycolormap_g',mycolormap_b']./255;
Blue2Red=round(Blue2Red*10^4)/10^4;

Cmap=Blue2Red;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end