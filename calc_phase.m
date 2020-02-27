function phase=calc_phase(Idata,Qdata)
iq=split_data(Idata+1j*Qdata);
phase=arctan(real(iq),imag(iq));

end
function angle=arctan(I,Q)
%% arctan function
%input: IQdata
%output: phase
[row,col]=size(I);
for i=1:row
    for j=1:col
        if I(i,j)>0
            if Q(i,j)>0
                angle(i,j)=atan(Q(i,j)/I(i,j));
            else
                angle(i,j)=atan(Q(i,j)/I(i,j))+2*pi;
            end
        elseif I(i,j)<0
            angle(i,j)=atan(Q(i,j)/I(i,j))+pi;
        elseif I(i,j)==0
            if Q(i,j)>0
                angle(i,j)=pi/2;
            else
                angle(i,j)=-pi/2;
            end
        end
    end
end
%angle=angle.*(180/pi);
end

function data3=split_data(data)
%% transform 512*1matrix to->160*3->80*3
%input: 512*1 matrix
%output: 80*3 matrix
data11=reshape(data(1:480,:),[48 10 size(data,2)]);
data12=reshape(data11,[16 3 10 size(data,2)]);
data1=data12(1:8,:,:,:);
data2=permute(data1,[1,3,4,2]);
data2=data2(:);
data2=reshape(data2,length(data2)/3,3);
data3=squeeze(data2);
%data3(:,[1 2]) = data3(:,[2 1]);  
end