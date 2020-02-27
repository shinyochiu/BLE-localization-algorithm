function d=TOF(rssi)
% TF = isoutlier(rssi);

d = 10.^(-(rssi+37)/23.6);
d = [d(1) d(1) d(1) d d(end) d(end) d(end)];
for i=4:size(d,2)-3
    d(i) = median(d(i-3:i+3));
end
d = d(4:end-3);

% h=fspecial('average');
% d=filter2(h,d);
d = [d(1) d(1) d(1) d d(end) d(end) d(end)];
for i=4:size(d,2)-3
    d(i) = mean(d(i-3:i+3));
end
d = d(4:end-3);
end

function data3=split_data(data)
%% ±ä512*1¾ØÕó->160*3->80*3
data11=reshape(data(1:480,:),[48 10 size(data,2)]);
data12=reshape(data11,[16 3 10 size(data,2)]);
data1=data12(1:8,:,:,:);
data2=permute(data1,[1,3,4,2]);
data2=data2(:);
data2=reshape(data2,length(data2)/3,3);
data3=squeeze(data2);
%data3(:,[1 2]) = data3(:,[2 1]);  
end