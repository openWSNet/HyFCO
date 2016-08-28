function y=cal_init_cov(grid_field)
    y=length(find(grid_field~=0))/(size(grid_field,1)*size(grid_field,2)); % 非0的點所占的百分比
end