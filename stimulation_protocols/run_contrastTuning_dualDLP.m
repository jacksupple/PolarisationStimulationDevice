function [run_RFMapExp_output] = run_contrastTuning_dualDLP(polMotor,params)
%% 

timestamp       = datestr(now,'HHMMSS');
% data_save_path  = [params.data_save_path,'\map_',num2str(params.RF_map_counter),'_',timestamp];
% mkdir(data_save_path)
videoNameHistory = {};

polariserFitted = 0;

for sp = params.RFMaps(params.RF_map_counter).start_pos:size(params.RFMaps(params.RF_map_counter).map_sequence_ElAz,1)
% % prompt user is ready
prompt      = ['Move to position Elevation = ',num2str(params.RFMaps(params.RF_map_counter).map_sequence_ElAz(sp,1)),' Azimuth = ',num2str(params.RFMaps(params.RF_map_counter).map_sequence_ElAz(sp,2)),' Continue press "y". Quit press "q"'];
user_str = input(prompt,'s');
if strcmp(user_str,'q')
    break
end

%% run stimuli

for pattern_ind = 1:size(params.RFMaps(params.RF_map_counter).stim_pattern,1)
            
        % DLP color
        tmp_color   = params.RFMaps(params.RF_map_counter).stim_pattern{pattern_ind}{1};
        col         = find(strcmp(tmp_color,{'RGB','Red','Green','Blue'}));
        
        % pol fitted
        if strcmp(params.RFMaps(params.RF_map_counter).stim_pattern{pattern_ind}{4},'PF1')
            if pattern_ind == 1 && sp == params.RFMaps(params.RF_map_counter).start_pos
                prompt = ['pls put polariser ON then press enter'];
                beep;
                input(prompt);
            elseif polariserFitted ~= 1
                prompt = ['pls put polariser ON then press enter'];
                beep;
                input(prompt);
            end
            polariserFitted = 1;
        else
            if sp == params.RFMaps(params.RF_map_counter).start_pos
                prompt = ['pls put polariser OFF then press enter'];
                beep;
                input(prompt);
            elseif polariserFitted ~= 0
                prompt = ['pls put polariser OFF then press enter'];
                beep;
                input(prompt);
            end
            polariserFitted = 0;
        end
        
        % pol angle
        pol_angle   = max([str2num(params.RFMaps(params.RF_map_counter).stim_pattern{pattern_ind}{3}),0]);
        polMotor_command = ['<pos,',num2str(pol_angle),',90>'];
        write(polMotor,polMotor_command,"string");
     	pause(2);
        
        % set DLPs
        DLP1_color  = col; % color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
        DLP2_color  = col; % color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
        % find the luminance intensity of the two DLPs
        [DLP1_currentValue, DLP2_currentValue]  = DLPIntensityEq_polNoPol(col, polariserFitted, pol_angle);
        connectDLPs(DLP1_color, DLP1_currentValue, DLP2_color, DLP2_currentValue)

        drive = pwd;
        video_drive     = [drive,'\DualDLP_Stim\',...
                            'RotatingDot_10loops'];
        direction      	= {'clockwise','anticlockwise'};
    
        % pol contrast
        pol_contrast    = params.RFMaps(params.RF_map_counter).stim_pattern{pattern_ind}{2};
        % obj contrast
        if isempty(params.RFMaps(params.RF_map_counter).contrastValues)
            objContrast = str2num(params.RFMaps(params.RF_map_counter).stim_pattern{pattern_ind}{5});
        else
            objContrast = params.RFMaps(params.RF_map_counter).contrastValues;
        end
        
        for Obj_c = 1:length(objContrast)


            for d = 1:length(direction) 

                % patterns
                ObjIntensity_contrast   = objContrast(Obj_c);
                stim_type               = ['[ObjContrast_',num2str(ObjIntensity_contrast),']',...
                                           '[',pol_contrast,']'];
                stim_name               = [stim_type,...                                           
                                           '[',params.RFMaps(params.RF_map_counter).stim_dims{1},']',...
                                           '[',direction{d},']'];

                video_path = fullfile(video_drive,stim_name);
                video_name = fullfile(video_path,[stim_name,'.gif']);
                videoNameHistory = [videoNameHistory; video_name];

                disp(['Running: ',stim_name]);
                StimGL_CallMovies(video_name)

                % The following pauses matlab whilst StimGL is running to 
                % prevent matlab resetting StimGL whilst the plugin is running
                sGL = StimOpenGL; 
                while ~isempty(StimGLRunning(sGL))
                end
                pause(1)
            end

        end
end

end

% save params

run_RFMapExp_output.videoNameHistory    = videoNameHistory;
run_RFMapExp_output.timestamp           = timestamp;


end