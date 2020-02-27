function BLE_location(obj,map)
fopen(obj);
his=[1 1];
P=eye(4);
try
    while 1
        [Idata,Qdata,rssi]=read_serial(obj);
        for ii=1:size(Idata,2)
            phase = calc_phase(Idata(:,ii),Qdata(:,ii));
            [v_phi(ii,:),phi0(ii,:)]=search_test(phase);
        end
        phasediff=wrapToPi([phi0(:,2)-phi0(:,1) phi0(:,3)-phi0(:,2) phi0(:,1)-phi0(:,3)]);
%         phasediff(:,1)=wrapToPi(phasediff(:,1)-65*pi/180);
%         phasediff(:,2)=wrapToPi(phasediff(:,2)+60*pi/180);
%         phasediff(:,3)=wrapToPi(phasediff(:,3)-10*pi/180);
        angle=AOA(phasediff*180/pi,map);
        dis=TOF(rssi);
        [his,P]=track1(angle*pi/180,dis,his,P);
        track_plot(his(end,:));
    end
catch
    fclose(instrfind);
    print('error');
end

end

function [Idata,Qdata,rssi]=read_serial(obj)
while ~exist('Idata')
    data=fread(obj);
    input=dec2hex(data);
    a=find(input(:,1)=='3'& input(:,2)=='0');
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
 
end

function track_plot(pos)
% pos=[dis.*cos(angle*pi/180);dis.*sin(angle*pi/180)];
pos=pos.';
% axis([-3,3,-3,3]);
% set(gca,'XTick',[-3:0.1:3]);
% set(gca,'YTick',[-3:0.1:3]);
% grid on;
% comet(pos1(1,:),pos1(2,:),0.1);
% hold on;
axis([-2.5,2.5,-2.5,2.5]);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
set(gca,'XTick',(-2.5:0.1:2.5));
set(gca,'YTick',(-2.5:0.1:2.5));
set(gca,'Color',[0 0 0]);
hold on;
plot(pos(1,:),pos(2,:),'yp','MarkerSize',10,'MarkerFaceColor','y');
hold on;
plot(0,0,'^','MarkerFaceColor',[rand rand rand],'MarkerSize',20,'MarkerEdgeColor','k');
grid on;
ax = gca;
ax.GridColor = [1, 1, 1];
pause(0.01);
clf;
end