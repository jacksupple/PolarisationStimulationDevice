function [DLP1_current_value, DLP2_current_value] = DLPIntensityEq_polNoPol(col, polariserFitted, pol_angle)

%       Outputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       DLP1_currentValue   The integer value encoding the current of the
%                           ti DLP. Takes values 0-274
%       Same for DLP2 (unpolarised)

    cali_name = 'DLPcurrents_2110031600_PolNoPol';

    load(fullfile('.\PolarisationStimulationDevice\luminance_calibration\PolNoPol\',...
          cali_name,...
          'calibrated_PolNoPol_DLPcurrents_luminanceMeasurements.mat'),'cali_data')

    cali_dataTable                          = array2table(cali_data.values);
    cali_dataTable.Properties.VariableNames = cali_data.fields;

    DLP1_ind     	= cali_dataTable.DLP                == 1;
    col_ind         = cali_dataTable.col                == col;
    polFitted_ind   = cali_dataTable.polariserFitted    == polariserFitted;
    pol_angle_ind   = cali_dataTable.pol_angle          == pol_angle;

    DLP1_current_value = cali_dataTable.currentVal(DLP1_ind & col_ind & polFitted_ind & pol_angle_ind);
    
    
    % value for DLP2 (unpolarised) is the same regardless of pol angle or
    % polFitted state
    DLP2_ind            = cali_dataTable.DLP == 2;
    DLP2_current_value  = cali_dataTable.currentVal(DLP2_ind & col_ind);

end









