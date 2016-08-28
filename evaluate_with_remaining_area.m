function y=evaluate_with_remaining_area(x,remaining_area)
% x���F�~���ƦC�զX���p���@ (�t�Ҧ��`�I)
    global target_covered_for_each_node target_x
    result_map=zeros(length(target_x(:,1)),length(target_x(1,:))); %%
    a=length(x);
    for i=1:a
        result_map=or(result_map,target_covered_for_each_node(:,:,x(i)));
    end
    result_map=and(result_map,remaining_area);
    p1=length(find(result_map==1));
    p2=length(x); %%�n�Q������`�I�ƥ�
%     fprintf(' p1=%d ',p1);
%     fprintf(' p2=%d ',p2);
    if p1==0 || p2==0
       y=0; 
    else
       y=p1+1/(p2+1); %%�@�ӫ��СA�Ψӵ��� �C�@�س�����py=p1/p2
    end
%     fprintf(' y=%d',y);
end