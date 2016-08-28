function y=data_anal(node_active_result, num_coverage_100per)
    y=zeros(size(node_active_result,1),size(node_active_result,2));
    for i=1:size(node_active_result,1)
        for j=1:size(node_active_result,2)
            temp=node_active_result{i,j};
            count=0;
            for k=1:num_coverage_100per(i,j)
                count=count+length(temp{k});
            end
            y(i,j)=count;
        end
    end

end