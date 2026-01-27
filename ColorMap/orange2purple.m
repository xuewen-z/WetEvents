function Cmap=orange2purple(WithNaN)

mycolorpoint=[[255 183 105];...
    [246 252 216];...
    [179 235 172];...
    [8 193 188];...
    [65 124 194];...
    [92 24 145]];
mycolorposition=[1 11 21 31 41 51];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:51,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:51,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:51,'linear','extrap');

Orange2Purple=[mycolormap_r',mycolormap_g',mycolormap_b']./255;
Orange2Purple=round(Orange2Purple*10^4)/10^4;

  Cmap=Orange2Purple;
  
    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end

end