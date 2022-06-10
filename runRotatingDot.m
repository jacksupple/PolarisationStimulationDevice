function runRotatingDot(stim_contrast, stim_conditions, stim_dims, direction)
%%
video_drive = 'C:\Users\Horsefly\Documents\Jack\polarisation_stimuli\DualDLP_Stim\RotatingDot_6loops';

% stim_contrast       = {'PolON','PolOFF'};
% stim_conditions     = {'PO','IO','IP'};
% direction           = {'clockwise','anticlockwise'};

for sdims = 1:length(stim_dims)
for stctrst = 1:length(stim_contrast) 
    for stcond = 1:length(stim_conditions)
        for d = 1:length(direction)
            
            stim_cont       = stim_contrast{stctrst};
            stim_cond       = stim_conditions{stcond};
            stim_direction  = direction{d};
            
            stim_type       = [stim_cont,'_',stim_cond];
            stim_name       = ['[',stim_type,'][',stim_dims{sdims},'][',stim_direction,']'];
            
            video_path = fullfile(video_drive,stim_type,stim_name);
            video_name = fullfile(video_path,[stim_name,'.gif']);

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
