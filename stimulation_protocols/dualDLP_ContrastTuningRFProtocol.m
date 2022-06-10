% Protocol script for dual DLP polarisation device. This code plays the
% stimulus video files, coordinates the polariser rotation, and saves a
% history of the stimulus parameters. Run each section of the code using
% ctrl+enter as needed. For tuning curves, change the LED color as
% required. Run each section more than once if needed. 
% Terms:
%   PolON:    bright object on polarised DLP1
%   PolOFF:   bright object on non-polarised DLP2
%   PF1:      polariser fitted true
%   PF0:      polariser fitted false

clear
close all 
clear global
opengl software

% navigate to the dualDLP_PolDevice folder
drive = pwd;

%% Initiate experiment
params = [];

% user input
% params.animal_name         = 'Cvicina.132.male.rec01';  % species.animalnumber.sex.recordingNumber
params.animal_name         = 'Test';          

%%%%%%%%%%%%%%%%% data acquisition parameters %%%%%%%%%%%%%%%%%
params.rec_date            = datestr(now,'yymmdd');
params.filebase            = [params.rec_date,'_',params.animal_name];
params.data_save_path      = fullfile(drive,'data',params.filebase);

params.Fs                  = 30000; % Sampling frequency
params.RF_map_counter      = 1;

mkdir(params.data_save_path)
save([params.data_save_path,'\params.mat'],'params')


%%%%%%%%%%%%%%%%% Initiate DLPs %%%%%%%%%%%%%%%%%%%%%%
% set DLPs
col                 = 4; % color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
pol_angle           = 0;
polariserFitted     = true;
DLP1_color          = col; % color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
DLP2_color          = col; % color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
% find the luminance intensity of the two DLPs
[DLP1_currentValue, DLP2_currentValue]  = DLPIntensityEq_polNoPol(col, polariserFitted, pol_angle);
connectDLPs(DLP1_color, DLP1_currentValue, DLP2_color, DLP2_currentValue)

error('Please make sure StimGL is open on fullscreen for the DLPs')

%% initialise polariser

% connect to polarisation motor
polMotor = serialport("COM3",115200); % connect to polariser motor
pause(3);

error('Please initialise polariser to 0 degrees (horizontal)')

% example controls:
    % polMotor_command = ['<rot,',num2str(225),',90>'];     % rotate 225 degrees at 90 deg/sec
    % polMotor_command = ['<pos,',num2str(0),',90>'];       % rotate to 0 degrees at 90 deg/sec
    % write(polMotor,polMotor_command,"string");            % send the command to the polariser motor arduino

    
%% test for responses

% preferred (elevation,azimuth) position of the cell.
pref_pos = [0 -30];

% movie to play
pol_contrast       = {'PolOFF'};  % bright polarised object: 'PolON'; bright non-polarised object: 'PolOFF'
contrastValues      = 15;         % 15: bright object; -15: dark object
stim_dims           = {'7.6deg_2cps_10.4RD'};
direction           = {'clockwise','anticlockwise'};   

stim_test(pol_contrast, contrastValues, stim_dims, direction)



%% 1. contrast tuning curve
tic
stim_col = 'Blue';
% stim_col = 'Green';

stim_dims               = {'7.6deg_2cps_10.4RD'};
stim_pattern            = {
                           {stim_col,'PolON', '',   'PF0'};
                           };
contrastValues          = [-15:5:-5, -3:3, 5:5:15];
rseed                   = rng(1);
r_ind1                  = randperm(length(contrastValues));
r_ind2                  = randperm(length(contrastValues));
contrastValues          = [contrastValues(r_ind1), fliplr(contrastValues(r_ind2))];

start_pos               = 1;
position_ElAz           = pref_pos;

params.RFMaps(params.RF_map_counter).stim_dims              = stim_dims;
params.RFMaps(params.RF_map_counter).contrastValues         = contrastValues;
params.RFMaps(params.RF_map_counter).stim_pattern           = stim_pattern;
params.RFMaps(params.RF_map_counter).map_sequence_ElAz      = position_ElAz;
params.RFMaps(params.RF_map_counter).start_pos              = start_pos;
params.RFMaps(params.RF_map_counter).run_RFMapExp_output    = run_contrastTuning_dualDLP(polMotor,params);            
save([params.data_save_path,'\params.mat'],'params')
% update map counter
params.RF_map_counter = params.RF_map_counter + 1;

toc
pause(4)

%% 2. pol tuning curve
tic
% stim_col = 'Blue';
stim_col = 'Green';

stim_dims        = {'7.6deg_2cps_10.4RD'};
stim_pattern     = {
                        {stim_col,'PolON', '0',  'PF1'};
                        {stim_col,'PolON', '45', 'PF1'};
                        {stim_col,'PolON', '90', 'PF1'};
                        {stim_col,'PolON', '135','PF1'};
                        {stim_col,'PolON', '180','PF1'};
                        {stim_col,'PolON', '225','PF1'};
                        {stim_col,'PolON', '270','PF1'};
                        {stim_col,'PolON', '315','PF1'};
                        {stim_col,'PolON', '0','PF1'};
                        {stim_col,'PolON', '45', 'PF1'};
                        {stim_col,'PolON', '90', 'PF1'};
                        {stim_col,'PolON', '135','PF1'};
                        {stim_col,'PolON', '180','PF1'};
                        {stim_col,'PolON', '225','PF1'};
                        {stim_col,'PolON', '270','PF1'};
                        {stim_col,'PolON', '315','PF1'};
                        {stim_col,'PolON', '0','PF1'};
                        {stim_col,'PolON', '',   'PF0'};
                    };

contrastValues          = [15 0];
start_pos               = 1;
position_ElAz           = pref_pos;

params.RFMaps(params.RF_map_counter).stim_dims              = stim_dims;
params.RFMaps(params.RF_map_counter).contrastValues         = contrastValues;
params.RFMaps(params.RF_map_counter).stim_pattern           = stim_pattern;
params.RFMaps(params.RF_map_counter).map_sequence_ElAz      = position_ElAz;
params.RFMaps(params.RF_map_counter).start_pos              = start_pos;
params.RFMaps(params.RF_map_counter).run_RFMapExp_output    = run_contrastTuning_dualDLP(polMotor,params);            
save([params.data_save_path,'\params.mat'],'params')
% update map counter
params.RF_map_counter = params.RF_map_counter + 1;

toc
pause(4)


%% 3. polarised RF
tic
% stim_col = 'Blue';
stim_col = 'Green';

stim_dims        = {'7.6deg_2cps_10.4RD'};
stim_pattern     = {
                        {stim_col,'PolOFF', '',  'PF1','15'};
                        {stim_col,'PolON', '0',  'PF1','0'};
                        {stim_col,'PolON', '45', 'PF1','0'};
                        {stim_col,'PolON', '90', 'PF1','0'};
                        {stim_col,'PolON', '135','PF1','0'};
%                         {stim_col,'PolON', '0',  'PF1','15'};
%                         {stim_col,'PolON', '45', 'PF1','15'};
%                         {stim_col,'PolON', '90', 'PF1','15'};
%                         {stim_col,'PolON', '135','PF1','15'};
                    };
contrastValues    = [];

% % load map of (elevation,azimuth) positions to sample. Choose full,
% % ipsilateral, or contralateral, depending on the location of the RF
% % relative to the recording electrode
% load('.\PolarisationStimulationDevice\stim_locations\RFMAPLayout_v4_full.mat','map_sequence_ElAz')
% load('.\PolarisationStimulationDevice\stim_locations\RFMAPLayout_v4_ipsi.mat','map_sequence_ElAz')
load('.\PolarisationStimulationDevice\stim_locations\RFMAPLayout_v4_contra.mat','map_sequence_ElAz')
% % plot to check locations
% figure; hold on; grid on; axis equal
% plot(map_sequence_ElAz(:,2),map_sequence_ElAz(:,1), 'ok', 'MarkerSize', 5,'MarkerFaceColor',[1 1 1])
% axis([-180 180 -90 90]); xlabel('Azimuth (degrees)'); ylabel('Elevation (degrees)')
% set(gca,'XTick',[-180:15:180],'YTick',[-90:15:90])
start_pos       = 1;
position_ElAz   = map_sequence_ElAz;

params.RFMaps(params.RF_map_counter).stim_dims              = stim_dims;
params.RFMaps(params.RF_map_counter).contrastValues         = contrastValues;
params.RFMaps(params.RF_map_counter).stim_pattern           = stim_pattern;
params.RFMaps(params.RF_map_counter).map_sequence_ElAz      = position_ElAz;
params.RFMaps(params.RF_map_counter).start_pos              = start_pos;
params.RFMaps(params.RF_map_counter).run_RFMapExp_output    = run_contrastTuning_dualDLP(polMotor,params);            
save([params.data_save_path,'\params.mat'],'params')
% update map counter
params.RF_map_counter = params.RF_map_counter + 1;

toc
pause(4)


%% 4. non-polarised neutral density (ND) filter control RF
tic
% stim_col = 'Blue';
stim_col = 'Green';

stim_dims        = {'7.6deg_2cps_10.4RD'};
stim_pattern     = {
                        {stim_col,'PolOFF', '',  'PF0','15'};
                        {stim_col,'PolON', '',   'PF0','0'};
                    };
contrastValues   = [];

% % load map of (elevation,azimuth) positions to sample. Choose full,
% % ipsilateral, or contralateral, depending on the location of the RF
% % relative to the recording electrode
% load('.\PolarisationStimulationDevice\stim_locations\RFMAPLayout_v4_full.mat','map_sequence_ElAz')
% load('.\PolarisationStimulationDevice\stim_locations\RFMAPLayout_v4_ipsi.mat','map_sequence_ElAz')
load('.\PolarisationStimulationDevice\stim_locations\RFMAPLayout_v4_contra.mat','map_sequence_ElAz')
% % plot to check locations
% figure; hold on; grid on; axis equal
% plot(map_sequence_ElAz(:,2),map_sequence_ElAz(:,1), 'ok', 'MarkerSize', 5,'MarkerFaceColor',[1 1 1])
% axis([-180 180 -90 90]); xlabel('Azimuth (degrees)'); ylabel('Elevation (degrees)')
% set(gca,'XTick',[-180:15:180],'YTick',[-90:15:90])
start_pos       = 1;
position_ElAz   = map_sequence_ElAz;

params.RFMaps(params.RF_map_counter).stim_dims              = stim_dims;
params.RFMaps(params.RF_map_counter).contrastValues         = contrastValues;
params.RFMaps(params.RF_map_counter).stim_pattern           = stim_pattern;
params.RFMaps(params.RF_map_counter).map_sequence_ElAz      = position_ElAz;
params.RFMaps(params.RF_map_counter).start_pos              = start_pos;
params.RFMaps(params.RF_map_counter).run_RFMapExp_output    = run_contrastTuning_dualDLP(polMotor,params);            
save([params.data_save_path,'\params.mat'],'params')
% update map counter
params.RF_map_counter = params.RF_map_counter + 1;

toc
pause(4)


