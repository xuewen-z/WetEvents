function Cmap=green2red(WithNaN)

    Cmap=[colormap(summer);flipud(colormap(autumn))];
    Cmap(:,3)=linspace(0.4,0, size(Cmap,3))';

    if nargin<1
      WithNaN=0;
    end
    
    if WithNaN ~= 0
        Cmap=[1,1,1;Cmap];
    end

end