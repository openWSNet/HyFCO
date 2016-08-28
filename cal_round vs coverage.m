x=[];
y=[];
current_round=round{3,2,8,10};
coverage_rec=coverage_round{3,2,8,10};
for i=1:length(current_round)
        y=[y coverage_rec{i}(1:current_round(i))]
end
figure
subplot(2,1,1);plot(y);
subplot(2,1,2);plot(coverage_record{3,2,8,10});

