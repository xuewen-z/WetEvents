function mycolorpoint=et2color(WithNaN)

  
n = 400;

mycolorpoint = [[253 138 54];...
    [254 178 74];...
    [253 212 114];...
    [255 237 170];...
    [247 255 189];...
    [202 222 242];...    
    [158 205 231];...
    [108 175 214];...
    [67 149 200];...
    [34 92 172]];
%     [13 44 124]
    mycolorposition=[1 11 21 31 41 51 61 71 81 91];
    mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:91,'linear','extrap');
    mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:91,'linear','extrap');
    mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:91,'linear','extrap');

    colormap=[mycolormap_r',mycolormap_g',mycolormap_b']./255;
    ET2Color=round(colormap*10^4)/10^4;%����4λС��
 
    mycolorpoint=ET2Color;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        mycolorpoint=[1,1,1;mycolorpoint];
    end
    
end