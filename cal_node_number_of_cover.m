result=zeros(30,9);
for i=1:9
    for j=1:30
        count=0;
        trmp={};
        temp=node_active_result{j,i};
        for k=1:num_coverage_100per(j,i)
            count=count+length(temp{k});
        end
        result(j,i)=count;
    end
end