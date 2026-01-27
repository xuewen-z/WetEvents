function Cmap= singlered(WithNaN)

 
mycolorpoint=[[252 222 152];...		
[242 172 112];...		
[226 127 88];...		
[200 77 62];...		
[143 44	49]];
mycolorposition=[1 8 15 22 29];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:29,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:29,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:29,'linear','extrap');
mycolor=[mycolormap_r',mycolormap_g',mycolormap_b']./255;

singlered =round(mycolor*10^4)/10^4;


Cmap=singlered;

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end
    
end
