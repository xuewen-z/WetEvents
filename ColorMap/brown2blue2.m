function mycolorpoint=brown2blue2(WithNaN)

  

mycolorpoint = [[84 47 5];...
    [141 80 13];...
    [191 128 49];...
    [200 170 120] ;...
    [170 200 215];...
    [146 198 219];...    
    [66 148 195];...
    [37 92 170]];    

    mycolorposition=[1 16 31 46 61 76 91 106];
    mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:106,'linear','extrap');
    mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:106,'linear','extrap');
    mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:106,'linear','extrap');
    colormap=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

    Brown2Blue2=round(colormap*10^4)/10^4;%����4λС��
 
mycolorpoint=Brown2Blue2;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        mycolorpoint=[1,1,1;mycolorpoint];
    end
    
end