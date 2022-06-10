%% polarisation stimulus pattern script for DLP
%%%%%%%%%% Dual DLP setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This stimulus is designed for the dual monitor DLP setup. The projectrs
% are fused into video wall mode.
% Video is expanded to full screen, with the video filling the two screens
% which are organised horizontally. Thus each frame needs to be two frames
% wide.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% Patterns %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A pattern is defined as the shortest part of the stimulus where there is
% no change. The DLPs receive input as 60Hz 24-bit. This can be parsed into
% 8-bit RGB, or parsed into arbitrary bit monochromatic anywhere from 1 to
% 24 bit. If there is more than one bit, greyscale luminance can be
% encoded. For our purposes, the stimuli will run at 4 bit depth, to give
% an effective patern frame rate of 60 Hz * (24/4) = 60Hz * 6 = 360 Hz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generate pattern

clear
close all

% ObjIntensity_contrast 	= [-15:15]';
ObjIntensity_contrast 	= [0]';
pol_contrast     	= {'PolON','PolOFF'};
direction           = {'clockwise','anticlockwise'};


%% /////// parameters ////////
for target_diameter = [7.6]
    for o_ctrst = 1:length(ObjIntensity_contrast) 
        for p_ctrst = 1:length(pol_contrast) 
            for d = 1:length(direction)

                obj_cont       = ObjIntensity_contrast(o_ctrst);
                pol_cont       = pol_contrast{p_ctrst};
                stim_direction  = direction{d};

                create_dualDLP_stim_contrastTuning_SOR(obj_cont,pol_cont,...
                                    stim_direction, target_diameter)

            end
        end
    end
end


%%
function create_dualDLP_stim_contrastTuning_SOR(obj_cont,pol_cont,stim_direction, target_diameter)

stim_params.obj_greyvalue = 15 - max([zeros(length(obj_cont),1), obj_cont.*(obj_cont./-obj_cont)],[],2);
stim_params.bkg_greyvalue = 15 - max([zeros(length(obj_cont),1), obj_cont],[],2);

% /////// stimulus stim_params ///////
stim_params.frame_rate              = 60; % frame rate in hz
stim_params.pattern_bitDepth        = 4;
stim_params.patterns_perframe       = 24/stim_params.pattern_bitDepth;
% Projector dimensions
stim_params.screen_x                = 608*2; % pixels
stim_params.screen_y                = 684; % pixels
stim_params.screen_x_cm             = 16; % cm
stim_params.screen_y_cm             = 9; % cm
% Experimental dimensions
stim_params.fly_dist_cm             = 23;
% Stimulus dimensions (From Krapp 1996)
stim_params.cycle_persec            = 2;
stim_params.dot_diameter_deg        = target_diameter; %7.6
stim_params.rotation_diameter_deg	= 10.4;
stim_params.rotation_number        	= 1;
stim_params.shape_type = 'ellipse';

stim_params.stim_type       = ['[ObjContrast_',num2str(obj_cont),']',...
                               '[',pol_cont,']'];
stim_params.stim_name       = [stim_params.stim_type,'[',num2str(stim_params.dot_diameter_deg),'deg_',num2str(stim_params.cycle_persec),'cps_',num2str(stim_params.rotation_diameter_deg),'RD','][',stim_direction,']'];

%% /////// calculate stimulus features from stim_params ///////
stim_params.pattern_rate            = stim_params.frame_rate * stim_params.patterns_perframe;
stim_params.max_greyValue           = 2^stim_params.pattern_bitDepth-1;
stim_params.screen_x_pixcm          = stim_params.screen_x/stim_params.screen_x_cm;
stim_params.screen_y_pixcm          = stim_params.screen_y/stim_params.screen_y_cm;
stim_params.screen_pixcm            = mean([stim_params.screen_x_pixcm,stim_params.screen_y_pixcm]);
stim_params.fly_dist_pix            = stim_params.fly_dist_cm*stim_params.screen_pixcm;
stim_params.dot_diameter_pix        = stim_params.fly_dist_pix * 2*tand(stim_params.dot_diameter_deg/2);
stim_params.rotation_diameter_pix   = stim_params.fly_dist_pix * 2*tand(stim_params.rotation_diameter_deg/2);
stim_params.obj_col                 = true;

%% create pattern
% Centre of rotation is the middle of each projector screen
stim_params.COR_x                   = round(stim_params.screen_x/2); % centre of rotation
stim_params.COR_y                   = round(stim_params.screen_y/2); % centre of rotation

% calcluate pattern translation steps. This is the desired speed based on
% the cycle/s input
stim_params.stim_params.deg_rot_perPattern_tmp	= (360*stim_params.cycle_persec)/stim_params.pattern_rate;

% there is a constraint that the complete stimulus needs to be a whole
% number of frames.
stim_params.num_patterns            = round((360./stim_params.stim_params.deg_rot_perPattern_tmp)/stim_params.patterns_perframe)*stim_params.patterns_perframe;
stim_params.deg_rot_perPattern      = 360 / stim_params.num_patterns;

% direction
if strcmp(stim_direction,'clockwise')
    stim_params.theta                   = linspace(0,360,stim_params.num_patterns+1);
    stim_params.theta(end)              = [];
elseif strcmp(stim_direction,'anticlockwise')
    stim_params.theta                   = linspace(360,0,stim_params.num_patterns+1);
    stim_params.theta(end)              = [];
end

stim_params.rot_radius              = repmat(stim_params.rotation_diameter_pix/2,1,length(stim_params.theta));
% polar to cartesian
[stim_params.tmp_stim_params.pattern_x,...
    stim_params.tmp_stim_params.pattern_y]      = pol2cart(deg2rad(stim_params.theta),stim_params.rot_radius);

% translate stimulus to center of rotation 
stim_params.tmp_stim_params.pattern_x           = round(stim_params.tmp_stim_params.pattern_x + stim_params.COR_x);
stim_params.tmp_stim_params.pattern_y           = round(stim_params.tmp_stim_params.pattern_y + stim_params.COR_y);
% repeat pattern if specified
stim_params.pattern_x               = repmat(stim_params.tmp_stim_params.pattern_x,1,stim_params.rotation_number);
stim_params.pattern_y               = repmat(stim_params.tmp_stim_params.pattern_y,1,stim_params.rotation_number);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % figure check 
% figure(1)
% plot(stim_params.pattern_x, stim_params.pattern_y)
% axis equal
% axis([1 1216 1 684])
% xlabel('x')
% ylabel('y')
% title('Stim rotation path at native aspect ratio')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stim_params.obj_len_x                 = stim_params.dot_diameter_pix*ones(1,length(stim_params.pattern_x));
stim_params.obj_len_y                 = stim_params.dot_diameter_pix*ones(1,length(stim_params.pattern_x));

stim_params.num_frames          = length(stim_params.pattern_x)/(stim_params.patterns_perframe); %

if mod(stim_params.num_frames,1)
    error(['Not a whole number of frames. Number of frames = ',num2str(stim_params.num_frames)])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%% trackbox paramters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
track_XLen      = 150; % trackbox x length
track_YLen      = 150; % trackbox y length

track1bottom_Xpos     = 1;
track1bottom_Ypos     = 1;


% The trackboxes of each projector will be superimposed on the projection
% of the other. Because the projectors will be inverted, this means one
% projector will be light-on, the other light-off. This is a problem
% because the projector with light on background will mask the trackbox of
% the other projector. To solve this there is a light-off margin created
% along the side of the frames where each projectors trackbox can be seen. 
track_bitDepth          = 24;
track_margin_XLen       = 50+track_XLen; % trackmargin width
track_margin_YLen       = 50+track_YLen;

track_margin_Xpos1      = 1;
track_margin_Ypos1      = 1;

track_margin_col        = false;
stim_params.track_startCol 	= true; % the trackbox start color should be light on

% the trackbox state is used to keep track of the color of the trackbox,
% starts on 1
trackbox_state = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% saving parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
baseDir = '.\DualDLP_Stim\RotatingDot_10loops\';
workingDir = [baseDir,...
                stim_params.stim_name,'\images'];
mkdir(workingDir); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% strategy: create and save each frame
% cd(workingDir)
padding = floor(log10(stim_params.num_frames))+1;
pattern_ind = 0;

for i = 1:stim_params.num_frames % for each frame (we are saving images on a frame by frame basis)
    %% generate the pattern
    % initialise the frames
    frame1 = uint8(zeros(stim_params.screen_y, stim_params.screen_x,3));
    frame2 = uint8(zeros(stim_params.screen_y, stim_params.screen_x,3));
    
    % brg order
    for sf = [3 1 2] % for each uint8 subframe (we are staying within factors of uint8 for pattern)
    
        % initialise a matrix to hold the patterns within the uint8 subframe
        p_frames_screen1 = uint8(zeros(stim_params.screen_y, stim_params.screen_x, stim_params.patterns_perframe/3));
        p_frames_screen2 = uint8(zeros(stim_params.screen_y, stim_params.screen_x, stim_params.patterns_perframe/3));       
        
        for p = 1:stim_params.patterns_perframe/3 % for each pattern within the uint8 subframe
            % iterate through patterns (we want this to keep increasing until no more patterns)
            pattern_ind             = pattern_ind + 1;
            
            % specify the grey value. The first pattern will be 4 bits (e.g. 1 1 1 1 = 15). The
            % second pattern will be in 8 bit format, with the first 4 bits
            % empty (e.g. 0 0 0 0 1 1 1 1 = 240)
            
            if strcmp(pol_cont,'PolON')
                frame1_objectcol    = bi2de([zeros((p-1),4),de2bi(stim_params.obj_greyvalue,4)]);
                frame1_bgcol        = bi2de([zeros((p-1),4),de2bi(0,4)]);
                frame2_objectcol    = bi2de([zeros((p-1),4),de2bi(0,4)]);
                frame2_bgcol        = bi2de([zeros((p-1),4),de2bi(stim_params.bkg_greyvalue,4)]);
            elseif strcmp(pol_cont,'PolOFF')
                frame1_objectcol    = bi2de([zeros((p-1),4),de2bi(0,4)]);
                frame1_bgcol        = bi2de([zeros((p-1),4),de2bi(stim_params.bkg_greyvalue,4)]);
                frame2_objectcol    = bi2de([zeros((p-1),4),de2bi(stim_params.obj_greyvalue,4)]);
                frame2_bgcol        = bi2de([zeros((p-1),4),de2bi(0,4)]);
            end

            % specify the x and y indices of the target (x,y position plus area of the target)
            x_pos = stim_params.pattern_x(pattern_ind);
            y_pos = stim_params.pattern_y(pattern_ind);
            x_len = stim_params.obj_len_x(pattern_ind);
            y_len = stim_params.obj_len_y(pattern_ind);

            [target_y_ind, target_x_ind] = target_index(x_pos, y_pos, x_len, y_len, stim_params.shape_type);
            
            % Screen 1
            p_frames_screen1(:,:,p) = frame1_bgcol;
            for ti = 1:numel(target_y_ind)
                p_frames_screen1(target_y_ind(ti),target_x_ind(ti),p) = frame1_objectcol;
            end

            % Screen 2
            p_frames_screen2(:,:,p) = frame2_bgcol;
            for ti = 1:numel(target_y_ind)
                p_frames_screen2(target_y_ind(ti),target_x_ind(ti),p) = frame2_objectcol;
            end

            clearvars Y_tmpInd X_tmpInd tmp_pattern_greyValue
        end
        
        % Input the subframe into the frame variables. This sums the
        % p_frame variables to get one number that represents all the 
        % patterns within the subframe. This should be uint8, but specify
        % uint8 again to be sure
        
        frame1(:,:,sf) = uint8(sum(p_frames_screen1,3));
%         unique(frame1) % check
%         class(frame1)
        frame2(:,:,sf) = uint8(sum(p_frames_screen2,3));
%         unique(frame2) % check
%         class(frame1)

        clearvars p_frames_screen1 p_frames_screen2 
    
    end
    
    %% Here is the trackbox assignment. This is currently placed within the
    % frame loop. But this can be modified to go into the pattern loop.

    % Create the trackbox background margin AFTER pattern assignment.
    % Because the trackboxes might be in different positions for each dlp,
    % but both need to be blank, the zero assignment is repeated for each
    % dlp per trackbox
	% First trackbox
    frame1(track_margin_Ypos1:track_margin_YLen, track_margin_Xpos1 + [0:track_margin_XLen-1],:) = uint8(track_margin_col);
	frame2(track_margin_Ypos1:track_margin_YLen, track_margin_Xpos1 + [0:track_margin_XLen-1],:) = uint8(track_margin_col);

    % assign the trackbox
    % this takes the trackbox flick on and off CURRENTLY PER FRAME (i),
    % based on the trackbox start color
    frame1(track1bottom_Ypos+[0:track_YLen-1], track1bottom_Xpos+[0:track_XLen-1],:) = 255*logical(mod(stim_params.track_startCol + (i-1),2));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% concatenate the frames sid by side
    tmp1 = imresize(frame1,[stim_params.screen_y, stim_params.screen_x/2],'method','nearest');
    tmp2 = imresize(frame2,[stim_params.screen_y, stim_params.screen_x/2],'method','nearest');

    tmp_frame = [tmp1, tmp2];

    % save the image
    ext = '.bmp';
    filename = [stim_params.stim_name,'_Frame',...
                   sprintf(['%0',num2str(padding),'d'],i), ext];

	fullname = fullfile(workingDir,filename);
    imwrite(flipud(tmp_frame),fullname)
    
end

stim_params.loops = 10;
imageNames = dir(fullfile(workingDir,'*.bmp'));
imageNames = {imageNames.name}';

%% write stimGL movie
outputfilename = fullfile(baseDir,stim_params.stim_name,[stim_params.stim_name,'.gif']);

subframe_padding = 10*3; % 5 frames
padding_img = uint8(zeros(stim_params.screen_y, 2*(stim_params.screen_x/2)));

imwrite(padding_img, outputfilename,'gif', 'Loopcount',0); 
for fp = 2:subframe_padding
	imwrite(padding_img, outputfilename,'gif','WriteMode','append'); 
end

for ii = 1:stim_params.loops
    for i = 1:length(imageNames)
       img = imread(fullfile(workingDir,imageNames{i}));
       for subf = [3,1,2]
          imwrite(img(:,:,subf), outputfilename,'gif','WriteMode','append'); 
       end
    end
end

for fp = 1:subframe_padding
	imwrite(padding_img, outputfilename,'gif','WriteMode','append'); 
end


%% save stimuli parameters
filename = fullfile(baseDir,stim_params.stim_name,'stim_params.mat');
save(filename,'stim_params')

%% delete image folders

filename = fullfile(workingDir,'*.bmp');
delete(filename)
pause(1)
rmdir(workingDir,'s')


end

