function [target_y_ind, target_x_ind] = target_index(x_pos, y_pos, x_len, y_len, shape_type)

% x_pos = coordinate of the centre of the object in x axis
% y_pos = coordinate of the centre of the object in y axis
% x_len = total width of the object along x axis (for square this is side length, for ellipse this is diameter)
% y_len = total width of the object along y axis (for square this is side length, for ellipse this is diameter)
% shape type  = square or ellipse

if x_len ==0 || y_len ==0
    xx = [];
    yy = [];
else

    y_halflen_low   = -abs(ceil([-(y_len-1)/2]));
    y_halflen_hi    = abs(ceil([(y_len-1)/2]));
    x_halflen_low   = -abs(ceil([-(x_len-1)/2]));
    x_halflen_hi    = abs(ceil([(x_len-1)/2]));

    Y_tmpInd                = y_pos + [y_halflen_low:y_halflen_hi];
    X_tmpInd                = x_pos + [x_halflen_low:x_halflen_hi];

    [xx,yy] = meshgrid(X_tmpInd,Y_tmpInd);
end


if strcmp(shape_type,'ellipse')
    
    % define the target area
    y0 = yy(ceil(size(xx,1)./2),1);
    x0 = xx(1,ceil(size(xx,2)./2));
    r = floor(size(xx,1)./2);
    % find points that are within the target area
    circle_ind = (xx - x0).^2 + (yy - y0).^2 <= r.^2 ;
    % remove those points from the meshgrid
    xx_tmp = xx(circle_ind);
    yy_tmp = yy(circle_ind);
    
    target_y_ind = yy_tmp;
    target_x_ind = xx_tmp;
    
elseif strcmp(shape_type,'square')
    
    target_y_ind = reshape(yy,1,numel(yy));
    target_x_ind = reshape(xx,1,numel(xx));
    
end










end