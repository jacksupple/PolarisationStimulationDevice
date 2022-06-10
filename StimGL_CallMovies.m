function StimGL_CallMovies(video_name)

PluginName                  = 'Movie';
StimGLparams.loops          = 1;            % Number of times to loop the movie
StimGLparams.file           = video_name;   % file name of movie
StimGLparams.fps_mode       = 'triple';     % fps_mode: 'single','dual','triple'
StimGLparams.color_order    = 'brg';        % Default value: !!!!!!! depthQ runs BRG !!!!!!!!!
% StimGLparams.interTrialBg   = '0, 0, 0';
% Turn trackbox off (a trackbox is encoded in the video)
StimGLparams.ftrackbox_x    = '0';          % Bottom-left x-coordinate ftrackbox 
StimGLparams.ftrackbox_y    = '0';          % Bottom-left x-coordinate 
StimGLparams.ftrackbox_w    = '0';          % Width of ftrackbox side
%% Start Stim GL
% cd('C:\stimGL\StimGL_Matlab\');
my_s = StimOpenGL; 
StimGLinfo.ver = DoQueryCmd(my_s,'GETVERSION');
my_s = SetParams(my_s,PluginName,StimGLparams);
Start(my_s,PluginName,1);



end


