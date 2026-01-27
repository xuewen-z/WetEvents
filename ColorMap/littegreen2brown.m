function mycolorpoint=littegreen2brown(WithNaN)

 

mycolorpoint = [...
    % [84 47 5];...
    [141 80 13];...
    [191 128 49];...
    [213 185 126];...
    [224 195 127];...
    [241 222 174];...
    % [201 236 229];...
    [31 152 147]]; 
    % [19 98 139]

    mycolorposition=[1 16 31 46 61 76];
    mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:76,'linear','extrap');
    mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:76,'linear','extrap');
    mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:76,'linear','extrap');
    colormap=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

    littegreen2brown=round(colormap*10^4)/10^4;%����4λС��
    
    mycolorpoint=littegreen2brown;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        mycolorpoint=[1,1,1;mycolorpoint];
    end
    
end