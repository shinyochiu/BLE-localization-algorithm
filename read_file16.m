function [Idata,Qdata,rssi]=read_file16(file)
input = textscan(file,'%s','whitespace',' '); 
fclose( file );
d2= hex2dec(input{1});
input=dec2hex(d2);
% for ii=1:size(input{1,1})
%    kk(ii,1)= input{1,1}{ii}(1);
%    kk(ii,2)= input{1,1}{ii}(2); 
% end
a=find(input(:,1)=='3'& input(:,2)=='0');
% a = find(input(:,1)=='3' & input(:,2)=='0');
b = [];
for n=1:size(a,1)-4
    if a(n+1)==a(n)+1 && a(n+2)==a(n)+2 && a(n+3)==a(n)+3 && a(n+4)~=a(n)+4
        b(n:n+3) = a(n:n+3);
    end
end
b = b(b~=0);
for n=1:4:size(b,2)-8
    if b(n+4) - b(n) ~= 2068
        b(n:n+3) = 0;
    end
end
% b = b(b~=0 & b<=18612);

for n=1:4:size(b,2)-4
    % convert hex 2 dec, ex: if input = 0E FF , what we want is 'FF0E'
    Qdata(:,(n-1)/4+1) = hex2dec([input(4+1+b(n):4:1+b(n)+2048,:) input(4+b(n):4:b(n)+2048,:)]);
    q = find(Qdata(:,(n-1)/4+1) > 4095);
    Qdata(q,(n-1)/4+1) = Qdata(q,(n-1)/4+1) -16^4;
    Idata(:,(n-1)/4+1) = hex2dec([input(4+3+b(n):4:3+b(n)+2048,:) input(4+2+b(n):4:2+b(n)+2048,:)]);
    i = find(Idata(:,(n-1)/4+1) > 4095);
    Idata(i,(n-1)/4+1) = Idata(i,(n-1)/4+1) -16^4;
    rssi(:,(n-1)/4+1) = hex2dec(input(b(n)+2060,:))-255;
end
 
end