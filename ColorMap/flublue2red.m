% function Cmap=fixblue2red(WithNaN)
% 
% 
% n = 375;
% Cmap = [[0 0 139];...
%     [30 144 255];...
%     [59 176 73];...
%     [102 205 170];...
%     [234 208 36];...    
%     [227 164 33];...
%     [197 101 97]; ...
%     [209 24 26]];    
%     colormap=Cmap./255;
% 
%     Blue2Red=round(colormap*10^4)/10^4;%����4λС��
% 
% Cmap=Blue2Red;
% 
%     if nargin<1
%       WithNaN=0;
%     end
% 
%     if WithNaN ~= 0
%         Cmap=[1,1,1;Cmap];
%     end
% 
% end

function Cmap=flublue2red(WithNaN)

mycolorpoint=[[0 0 139];...
    [30 144 255];...
    [59 176 73];...
    [102 205 170];...
    [234 208 36];...    
    [227 164 33];...
    [197 101 97]; ...
    [209 24 26]];  
mycolorposition=[1 11 21 31 41 51 61 71];
mycolormap_r=interp1(mycolorposition,mycolorpoint(:,1),1:71,'linear','extrap');
mycolormap_g=interp1(mycolorposition,mycolorpoint(:,2),1:71,'linear','extrap');
mycolormap_b=interp1(mycolorposition,mycolorpoint(:,3),1:71,'linear','extrap');

flublue2red=[mycolormap_r',mycolormap_g',mycolormap_b']./255;
flublue2red=round(flublue2red*10^4)/10^4;


  Cmap=flublue2red;
  
    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end

end