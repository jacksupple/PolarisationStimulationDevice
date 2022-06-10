function mean_lux = getPhotodiodeMeanLux_photoModule(a,sec)

%   a       = arduino session
%   sec     = number of seconds to average data
% 	a = serialport('COM9',115200);
    pause(3)
    flush(a); pause(1); readline(a); 

    lux = [];
    tic
    while toc <= sec % 4 second reading time
%         % Read current voltage value
%         v = readVoltage(a,'A0');
%         v = 5-v;
%         lux = [lux; v];
        % Read current voltage value
        tmp         = readline(a);     
        tmp_split   = strsplit(tmp,{',','\r'});
        filtVal     = str2num(tmp_split{1});
        v           = 5*filtVal/1023;
        lux         = [lux; v];
    end
    mean_lux = mean(lux);



end






