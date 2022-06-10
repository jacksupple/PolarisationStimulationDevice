# RUN record
# LVP@KrappLab
# 2018-04-12: DAQ setup
# 
#
#=============================================
# from LVP_JH_DLP_class import *
from lvp_DLP_TRIGIN import *
import time
import sys

DLP1_colour      = int(sys.argv[1])
DLP1_current_1   = int(sys.argv[2][2:],16)
DLP1_current_2   = int(sys.argv[3][2:],16)

DLP2_colour      = int(sys.argv[4])
DLP2_current_1   = int(sys.argv[5][2:],16)
DLP2_current_2   = int(sys.argv[6][2:],16)

d1 = DLP_LightCrafter('192.168.1.101')

d1.setDisplayMode(2) # 0 static image 1 internal test pattern 2 HDMI 3 Reserved 4 Pattern Sequence Display 

if DLP1_colour == 3:
    d1.LEDCurrentSetting( GreenCurrent1 = DLP1_current_1 , GreenCurrent2 = DLP1_current_2 ) # GREEN 274
    d1.setVideoMode(fps=60, bit=4, color=DLP1_colour) # color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
elif DLP1_colour == 4:
    d1.LEDCurrentSetting( BlueCurrent1 = DLP1_current_1 , BlueCurrent2 = DLP1_current_2 ) # GREEN 274
    d1.setVideoMode(fps=60, bit=4, color=DLP1_colour) # color 1: RGB, 2:RED, 3:GREEN, 4:BLUE

d1.setFlipRotate(flip_x=1,flip_y=0)
d1.setVideoInput()

d1.disconnect_DLP()
print("DLP101 : HDMI ready.")

#=============================================

d2 = DLP_LightCrafter('192.168.1.50')

d2.setDisplayMode(2) # 0 static image 1 internal test pattern 2 HDMI 3 Reserved 4 Pattern Sequence Display 

if DLP2_colour == 3:
    d2.LEDCurrentSetting( GreenCurrent1 = DLP2_current_1 , GreenCurrent2 = DLP2_current_2 ) # GREEN 274
    d2.setVideoMode(fps=60, bit=4, color=DLP2_colour) # color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
elif DLP2_colour == 4:
    d2.LEDCurrentSetting( BlueCurrent1 = DLP2_current_1 , BlueCurrent2 = DLP2_current_2 ) # GREEN 274
    d2.setVideoMode(fps=60, bit=4, color=DLP2_colour) # color 1: RGB, 2:RED, 3:GREEN, 4:BLUE

d2.setFlipRotate(flip_x=0,flip_y=1)
d2.setVideoInput()

d2.disconnect_DLP()
print("DLP50 : HDMI ready.")
