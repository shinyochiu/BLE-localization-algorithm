function [Idata,Qdata,rssi]=read_file(file)
d1 = textscan(file,'%s','whitespace','[]'); 
fclose( file ); 

for n=1:size(d1{1},1)/2
    rawdata{n}{1} = textscan(d1{1}{n*2-1},'%s%s','delimiter',',','whitespace','()');
    rawRSSI{n}{1} = textscan(d1{1}{n*2}(6:8),'%s');
    for m=1:512
        try
            Idata(m,n) = str2double(rawdata{n}{1}{1}{m});
            Qdata(m,n) = str2double(rawdata{n}{1}{2}{m}(1:end-1));
        end
    end
    rssi(n) = str2double(rawRSSI{n}{1}{1});
end
end