function mycolorpoint=gpp2color(WithNaN)

  

mycolorpoint = [[214 109 44];...
    [237 150 27];...
    [244 191 17];...
    [254 238 10];...
    [188 247 5];...
    [63 230 0];...
    [6 210 37];...    
    [23 178 113];...
    [31 152 147];...
    [19 98 139]];
    mycolorposition=[1 11 21 31 41 51 61 71 81 91];
    mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:91,'linear','extrap');
    mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:91,'linear','extrap');
    mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:91,'linear','extrap');

    colormap=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

    Gpp2Color=round(colormap*10^4)/10^4;%����4λС��
 
    mycolorpoint=Gpp2Color;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        mycolorpoint=[1,1,1;mycolorpoint];
    end
    
end