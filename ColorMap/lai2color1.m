function mycolorpoint=lai2color1(WithNaN)

  
n = 1;
% [173 164 103];...
mycolorpoint = [[216 199 129];...
    [172 173 19];...
    [145 159 7];...
%     [129 134 57];...    
    [114 122 49];...
%     [103 116 36];...
    [81 96 33];...
    [54 73 37];...
    [30 56 6]];
    mycolorposition=[1 11 21 31 41 51 61];
    mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:61,'linear','extrap');
    mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:61,'linear','extrap');
    mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:61,'linear','extrap');

    colormap=[mycolormap_r',mycolormap_g',mycolormap_b']./255;
%     colormap = mycolorpoint ./255; 
    ET2Color=round(colormap*10^4)/10^4;%����4λС��
 
    mycolorpoint=ET2Color;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        mycolorpoint=[1,1,1;mycolorpoint];
    end
    
end