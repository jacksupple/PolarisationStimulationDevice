function [current_1, current_2] = DLP_current2LoHiByte(DLP_currentValue)
%%  DLP_current2LoHiByte(DLP_currentValue)
%   Converts a requested LED current value into the low-high byte format
%   for the ti-DLP commandline interface.
%
%
%    Inputs
%      DLP_currentValue    = user-requested DLP current value. Without a
%                            cooling fan, the DLP can tolerate values in 
%                            the range 0-274. Higher values will cause 
%                            damage to the DMD.
%    
%    
%    Outputs
%      current_1           = hexadecimal low byte for the commandline 
%                            interface
%      current_1           = hexadecimal low byte for the commandline 
%                            interface
%   
%   
%    Send bytes to the command line in the order current_1, current_2.

    current = DLP_currentValue;
    
    current_hex = dec2hex([floor(current/2^8), mod(current,2^8)],2);
    tmp_current_1 = current_hex(2,:); % low byte
    tmp_current_2 = current_hex(1,:); % high byte
    % current_check = hex2dec(reshape(current_hex,1,numel(current_hex)));
    current_check = hex2dec([tmp_current_2,tmp_current_1]);
    if current_check > 274
        error(['WARNING REQUESTED CURRENT EXCEEDS SAFE LIMIT. Requested value = ', num2str(current_check)])
    end
    
    current_1 = ['0x',tmp_current_1];
    current_2 = ['0x',tmp_current_2];
    
%     display(['Requested current value   = ', num2str(current)])
%     display(['current1 (low byte)       = ', num2str(current_1)])
%     display(['current2 (high byte)      = ', num2str(current_2)])
%     {current, current_1, current_2, current_check}




