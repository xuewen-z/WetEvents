function Cmap=green2blue(WithNaN)

mycolorpoint=[[255 255 240];...
    [255 255 224];...
    [154 226 189];...
    [65 217 204];...
    [2 175 207];...
    [0 126 182];...
    [11 98 165]];
mycolorposition=[1 5 11 21 31 41 51];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:51,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:51,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:51,'linear','extrap');

Green2Blue=[mycolormap_r',mycolormap_g',mycolormap_b']./255;
Green2Blue=round(Green2Blue*10^4)/10^4;


  Cmap=Green2Blue;
  
    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end

end