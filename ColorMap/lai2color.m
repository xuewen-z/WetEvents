function mycolorpoint=lai2color(WithNaN)

  
n = 1;
% repmat([173 164 103],[n 1]);...
mycolorpoint = [repmat([216 199 129],[n 1]);...
    repmat([172 173 19],[n 1]);...
    repmat([145 159 7],[n 1]);...
%     repmat([129 134 57],[n 1]);...    
    repmat([114 122 49],[n 1]);...
%     repmat([103 116 36],[n 1]);...
    repmat([81 96 33],[n 1]);...
    repmat([54 73 37],[n 1]);...
    repmat([30 56 6],[n 1])];
%     mycolorposition=[1 11 21 31 41 51 61 71 81 91 101];
%     mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:101,'linear','extrap');
%     mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:101,'linear','extrap');
%     mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:101,'linear','extrap');

%     Gpp2Color=[mycolormap_r',mycolormap_g',mycolormap_b']./255;
    colormap = mycolorpoint ./255; 
    ET2Color=round(colormap*10^4)/10^4;%����4λС��
 
    mycolorpoint=ET2Color;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        mycolorpoint=[1,1,1;mycolorpoint];
    end
    
end