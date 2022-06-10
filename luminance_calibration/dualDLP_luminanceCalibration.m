%% luminance calibration for dual DLP device
% polariser on = add the polariser to DLP1
% polariser off = replace DLP1 polariser with ND filter
% You need to have VLC media player installed at C:\Program Files\VideoLAN\VLC\vlc.exe
% Download 64bit VLC player to match operating system
% 1. chage VLC fullscreen setting to default to the DLP display. 
% open VLC>tools>preferences>video>fullscreen video device
% 2. Uncheck Show media title on video start
% open VLC>tools>preferences>subtitles/OSD>Uncheck Show media title on video start

clear global
clear

% navigate to the dualDLP_PolDevice folder
drive = pwd;

%% connect to devices

% COM port connected to polariser motor
polMotor = serialport("COM3",115200);
pause(3);
pol_state = 0;

% COM port connected to calibration photodetector arduino
a = serialport('COM9',1000000);
pause(3)

% save path
basepath = fullfile(drive,'PolarisationStimulationDevice','luminance_calibration');
cd(basepath)
savepath = [basepath,'\PolNoPol\DLPcurrents_',datestr(now,'yymmddHHMM'),'_PolNoPol'];
mkdir(savepath)

count = 1;


%%
for polariserFitted	= [0,1]
    polFitted_state = polariserFitted;
    
    polPromptState = {'OFF','ON'};
    prompt = ['pls put polariser ',polPromptState{polariserFitted+1},', then press enter'];
    input(prompt)
    
for r = 1       % repetitions
for c = [3 4]   %LED color 1: RGB, 2:RED, 3:GREEN, 4:BLUE

    % connect to DLPs
    col = c;                % color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
    DLP1_color  = col;      % color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
    DLP2_color  = col;      % color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
    % initial luminance intensity of the two DLPs
    DLP1_currentValue = 274; 
    DLP2_currentValue = 274;
    connectDLPs(DLP1_color, DLP1_currentValue, DLP2_color, DLP2_currentValue)

    greyscale       = [15];     % max image bitdepth greyscale between 0-15
    DLPcurrent      = [265];    % DLP current to be measured at. Less than 274 to allow room for in/decrease for all DLPs
    sec = 10;                   % duration to sample luminance with photodiode

    % when the polariser is on, we want to measure the pol DLP1. When
    % ND filter is fitted instead of polariser, we measure both DLPs
    if polariserFitted
        DLPs        = [1];      % DLP1 is polarised, DLP2 is unpolarised
        DLP_stim = {'PolON'};
    else
        DLPs        = [1,2];    % DLP1 is polarised, DLP is unpolarised
        DLP_stim = {'PolON','PolOFF'};
    end

    for d = 1:length(DLPs) % for each DLP
        for g = 1:length(greyscale) % for each greyscale tested (here only 15)

            % display bright image on the designated DLP
            movie_drive = [basepath,'\images\',DLP_stim{DLPs(d)}];
            movie_name  = [DLP_stim{DLPs(d)},'_greyValue_',num2str(greyscale(g)),'.bmp'];
            movie       = ['"',movie_drive,'\',movie_name,'"'];

            % open VLC and display image
            system(['"C:\Program Files\VideoLAN\VLC\vlc.exe" ',...
                    movie,...
                    ' --qt-fullscreen-screennumber=1',...
                    ' --fullscreen',...
                    ' &'])

            % designate the polarisation angles to test
            if DLPs(d) == 1 && logical(polariserFitted)
                pol_angle = [0:5:360];
                pol_angle = [pol_angle(1:end-1),fliplr(pol_angle),pol_angle(2:end)]; % repeat each pol angle to average temperature dependent luminance drift
            else
                pol_angle = zeros(1,10);
            end
            
            % for each pol angle
            for p = 1:length(pol_angle)

                % turn polarisation motor to correct angle
                polMotor_command = ['<pos,',num2str(pol_angle(p)),',90>'];
                write(polMotor,polMotor_command,"string");
                pause(1.5);
                polState = pol_angle(p);

                for current_ind = 1:length(DLPcurrent)

                    % set DLPs
                    if DLPs(d)==1
                        DLP1_currentValue = DLPcurrent(current_ind);
                        DLP2_currentValue = 1;
                    elseif DLPs(d)==2
                        DLP1_currentValue = 1;
                        DLP2_currentValue = DLPcurrent(current_ind);
                    end
                    connectDLPs(DLP1_color, DLP1_currentValue, DLP2_color, DLP2_currentValue)
                    pause(2)

                    % measure intensity
                    disp(['Measuring d: ',num2str(DLPs(d)),', current value: ',num2str(DLPcurrent(current_ind)),', grey: ',num2str(greyscale(g))])
                    mean_lux              = getPhotodiodeMeanLux_photoModule(a,sec);                    

                    data.fields           = {'col',...
                                            'DLP',...
                                            'polariserFitted',...
                                            'pol_angle',...
                                            'mean_lux',...
                                            'greyvalue',...
                                            'currentVal'};

                    data.values(count,:)  = [col,...
                                            DLPs(d),...
                                            polariserFitted,...
                                            pol_angle(p),...
                                            mean_lux,...
                                            greyscale(g),...
                                            DLPcurrent(current_ind)];

                    count = count + 1;

                end
            end

            system(['taskkill /IM vlc.exe']) % close VLC
            pause(1)
        end
    end

filename = ['PolNoPol_DLPcurrents_luminanceMeasurements.mat'];
save(fullfile(savepath,filename),'data')

end
end

end

%% plot data
dataTable = array2table(data.values);
dataTable.Properties.VariableNames = data.fields;

DLP1ind     = dataTable.DLP==1;
DLP2ind     = dataTable.DLP==2;

Green_ind   = dataTable.col==3;
Blue_ind    = dataTable.col==4;

pol_ind     = dataTable.polariserFitted==1;
noPol_ind   = dataTable.polariserFitted==0;

currentMAx_ind = dataTable.currentVal == DLPcurrent;

cols = [0 1 0;0 0 1];

figure(1); hold on; box on
subplot(1,2,1); hold on; box on
plot(dataTable.pol_angle(DLP1ind&Green_ind&pol_ind&currentMAx_ind),dataTable.mean_lux(DLP1ind&Green_ind&pol_ind&currentMAx_ind),...
    '-','color',cols(1,:))
plot(dataTable.pol_angle(DLP1ind&Blue_ind&pol_ind&currentMAx_ind),dataTable.mean_lux(DLP1ind&Blue_ind&pol_ind&currentMAx_ind),...
    '-','color',cols(2,:))

line([0 360],[1 1].*mean(dataTable.mean_lux(DLP1ind&Green_ind&noPol_ind&currentMAx_ind)),'color',cols(1,:))
line([0 360],[1 1].*mean(dataTable.mean_lux(DLP1ind&Blue_ind&noPol_ind&currentMAx_ind)),'color',cols(2,:))
line([0 360],[1 1].*mean(dataTable.mean_lux(DLP2ind&Green_ind&noPol_ind&currentMAx_ind)),'linestyle','--','color',cols(1,:))
line([0 360],[1 1].*mean(dataTable.mean_lux(DLP2ind&Blue_ind&noPol_ind&currentMAx_ind)),'linestyle','--','color',cols(2,:))

xlabel('Polariser angle (degrees)')
ylabel('mean photodiode val')

%% luminance calibration (automated gradient descent to calibration target)
calibration_target = min(dataTable.mean_lux);

count = 1;

for polariserFitted	= [1,0]
    
    if polFitted_state ~= polariserFitted
        polPromptState = {'OFF','ON'};
        prompt = ['pls put polariser ',polPromptState{polariserFitted+1},', then press enter'];
        input(prompt)
    end
    polFitted_state = polariserFitted;

for c = [3 4]  %LED color 1: RGB, 2:RED, 3:GREEN, 4:BLUE

    % connect to DLPs
    col = c; % color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
    DLP1_color  = col; % color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
    DLP2_color  = col; % color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
    % initial luminance intensity of the two DLPs
    DLP1_currentValue = 274; 
    DLP2_currentValue = 274;
    connectDLPs(DLP1_color, DLP1_currentValue, DLP2_color, DLP2_currentValue)

    greyscale           = [15];
    initial_current     = 274;
    sec                 = 10;   % duration to sample luminance with photodiode

    if polariserFitted
        DLPs        = [1]; % DLP1 is polarised, DLP is unpolarised
        DLP_stim = {'PolON'};
    else
        DLPs        = [1,2]; % DLP1 is polarised, DLP is unpolarised
        DLP_stim = {'PolON','PolOFF'};
    end

    for d = 1:length(DLPs)
        for g = 1:length(greyscale)

            % display bright image on the designated DLP
            movie_drive = [basepath,'\images\',DLP_stim{DLPs(d)}];
            movie_name  = [DLP_stim{DLPs(d)},'_greyValue_',num2str(greyscale(g)),'.bmp'];
            movie       = ['"',movie_drive,'\',movie_name,'"'];

            % open VLC and display image
            system(['"C:\Program Files\VideoLAN\VLC\vlc.exe" ',...
                    movie,...
                    ' --qt-fullscreen-screennumber=1',...
                    ' --fullscreen',...
                    ' &'])

            % determine polariser angles (only 45 degree increments)
            if DLPs(d) == 1 && logical(polariserFitted)
                pol_angle = [0:45:360];
                pol_angle(end) = [];
            else
                pol_angle = 0;
            end

            % for each polariser angle
            for p = 1:length(pol_angle)
                % adjust polariser motor
                polMotor_command = ['<pos,',num2str(pol_angle(p)),',90>'];
                write(polMotor,polMotor_command,"string");
                pause(1);
                polState = pol_angle(p);

                % gradient descent to reach calibration_target
                test_current        = initial_current;
                alpha               = 0.4;
                J_current_history   = [0 0 0];
                num_iters           = 20;

                % initial reading
                mean_lux            = getPhotodiodeMeanLux_photoModule(a,sec);
                
                for iter = 1:num_iters
                    % adjust test current within 0-274 range
                    test_current = test_current*(1 - alpha*(mean_lux - calibration_target));
                    test_current = round(test_current);
                    if test_current > 274
                        test_current = 274;
                    elseif test_current < 0
                        test_current = 0;    
                    end
                    
                    % set DLPs
                    if DLPs(d)==1
                        DLP1_currentValue = test_current;
                        DLP2_currentValue = 1;
                    elseif DLPs(d)==2
                        DLP1_currentValue = 1;
                        DLP2_currentValue = test_current;
                    end
                    connectDLPs(DLP1_color, DLP1_currentValue, DLP2_color, DLP2_currentValue)
                    pause(2)

                    % measure intensity
                    disp(['Measuring d: ',num2str(DLPs(d)),', current value: ',num2str(DLPcurrent(current_ind)),', grey: ',num2str(greyscale(g))])
                    mean_lux              = getPhotodiodeMeanLux_photoModule(a,sec);
                    
                    % cost function
                    J = (1/2) * (mean_lux - calibration_target).^2; 
                    J_current_history(iter,1) = J;
                    J_current_history(iter,2) = test_current;
                    J_current_history(iter,3) = mean_lux;
    
                end

                cali_data.fields           = {'col',...
                                            'DLP',...
                                            'polariserFitted',...
                                            'pol_angle',...
                                            'mean_lux',...
                                            'greyvalue',...
                                            'currentVal'};
                cali_data.values(count,:)  = [col,...
                                            DLPs(d),...
                                            polariserFitted,...
                                            pol_angle(p),...
                                            mean_lux,...
                                            greyscale(g),...
                                            test_current];
                                        
                cali_data.J_current_history{count,1} = J_current_history;
                
                count = count + 1;                
                
            end
            
            system(['taskkill /IM vlc.exe'])
            pause(1)
        end
    end

filename = ['calibrated_PolNoPol_DLPcurrents_luminanceMeasurements.mat'];
save(fullfile(savepath,filename),'cali_data')

end


end



%% plot data
cali_dataTable = array2table(cali_data.values);
cali_dataTable.Properties.VariableNames = cali_data.fields;

DLP1ind     = cali_dataTable.DLP==1;
DLP2ind     = cali_dataTable.DLP==2;

Green_ind   = cali_dataTable.col==3;
Blue_ind    = cali_dataTable.col==4;

pol_ind     = cali_dataTable.polariserFitted==1;
noPol_ind   = cali_dataTable.polariserFitted==0;

cols = [0 1 0;0 0 1];

figure(1); hold on; box on

subplot(1,2,1);
ylims(1,:) = get(gca,'ylim');

subplot(1,2,2); hold on; box on
plot(cali_dataTable.pol_angle(DLP1ind&Green_ind&pol_ind),cali_dataTable.mean_lux(DLP1ind&Green_ind&pol_ind),...
    '-','color',cols(1,:))
plot(cali_dataTable.pol_angle(DLP1ind&Blue_ind&pol_ind),cali_dataTable.mean_lux(DLP1ind&Blue_ind&pol_ind),...
    '-','color',cols(2,:))

line([0 360],[1 1].*mean(cali_dataTable.mean_lux(DLP1ind&Green_ind&noPol_ind)),'color',cols(1,:))
line([0 360],[1 1].*mean(cali_dataTable.mean_lux(DLP1ind&Blue_ind&noPol_ind)),'color',cols(2,:))
line([0 360],[1 1].*mean(cali_dataTable.mean_lux(DLP2ind&Green_ind&noPol_ind)),'linestyle','--','color',cols(1,:))
line([0 360],[1 1].*mean(cali_dataTable.mean_lux(DLP2ind&Blue_ind&noPol_ind)),'linestyle','--','color',cols(2,:))

xlabel('Polariser angle (degrees)')
ylabel('mean photodiode val')

ylims(2,:) = get(gca,'ylim');
subplot(1,2,2);
ylim([min(ylims(:,1)),max(ylims(:,2))])
subplot(1,2,2);
ylim([min(ylims(:,1)),max(ylims(:,2))])


% plot current history
figure(2); hold on; box on
for sp = 1:length(cali_data.J_current_history)
    subplot(1,2,1); hold on; box on
    plot(cali_data.J_current_history{sp,1}(:,3));
    xlabel('iteration')
    ylabel('Intensity')
   
    subplot(1,2,2); hold on; box on
    plot(cali_data.J_current_history{sp,1}(:,2));
    xlabel('iteration')
    ylabel('current')
    
end




