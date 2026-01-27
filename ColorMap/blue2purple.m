function Cmap=blue2purple(WithNaN)

mycolorpoint=[[199 216 235];...
    [169 195 222];...
    [148 166 206];...
    [140 131 188];...
    [137 93 170];...
    [134 53 148];...
    [122 13 118]];
mycolorposition=[1 5 11 21 31 41 51];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:51,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:51,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:51,'linear','extrap');

Blue2Purple=[mycolormap_r',mycolormap_g',mycolormap_b']./255;
Blue2Purple=round(Blue2Purple*10^4)/10^4;


  Cmap=Blue2Purple;
  
    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end

end