function stim_test(pol_contrast, contrastValues, stim_dims, direction)

    drive = pwd;
    video_drive     = [drive,'\DualDLP_Stim\',...
                        'RotatingDot_10loops'];

    for pc = 1:length(pol_contrast)
    for c = 1:length(contrastValues)
    for d = 1:length(direction)

        ObjIntensity_contrast   = contrastValues(c);
        stim_type               = ['[ObjContrast_',num2str(ObjIntensity_contrast),']',...
                                   '[',pol_contrast{pc},']'];
        stim_name               = [stim_type,...                                           
                                   '[',stim_dims{1},']',...
                                   '[',direction{d},']'];
        
        video_path = fullfile(video_drive,stim_name);
        video_name = fullfile(video_path,[stim_name,'.gif']);
        
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