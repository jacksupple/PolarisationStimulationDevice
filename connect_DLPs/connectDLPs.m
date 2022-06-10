function connectDLPs(DLP1_color, DLP1_currentValue, DLP2_color, DLP2_currentValue)
                    
%       DLP1_color          Coded color value of DLP1 (polarised) takes values 
%                               1: RGB, 2:RED, 3:GREEN, 4:BLUE
%       DLP1_currentValue   The integer value encoding the current of the
%                           ti DLP. Takes values 0-274
%       Same input for DLP2 (unpolarised)

if DLP1_currentValue > 274 || DLP2_currentValue > 274
   error('current value too high') 
end


[DLP1_current_1, DLP1_current_2] = DLP_current2LoHiByte(DLP1_currentValue);

[DLP2_current_1, DLP2_current_2] = DLP_current2LoHiByte(DLP2_currentValue);

disp(['DLP1: ',num2str(DLP1_color),' ',DLP1_current_1, ' ', DLP1_current_2])
disp(['DLP2: ',num2str(DLP2_color),' ',DLP2_current_1, ' ', DLP2_current_2])


% py_drive        = 'C:\Users\Horsefly\Python38\python';
py_drive        = 'C:\Python38\python'; % wherever you installed python. Only needed if 'python' isn't in the windows system path
script_drive    = '.\PolarisationStimulationDevice\connect_DLPs\JS_HDMI_config_changeCol_Int.py';

command_string = [py_drive,' ',script_drive,' ',...
                    num2str(DLP1_color),' ',DLP1_current_1, ' ', DLP1_current_2,' ',...
                    num2str(DLP2_color),' ',DLP2_current_1, ' ', DLP2_current_2];
system(command_string);

                    
end
