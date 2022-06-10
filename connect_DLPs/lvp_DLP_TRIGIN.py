#!/usr/bin/env python

###########################
# Author: JH@KrappLab
# 2018-01-17: V1

###########################

import socket
import time
# import imageio
import sys,os
import threading



class DLP_LightCrafter:
	def __init__(self, IP):
		self.TCP_IP = IP
		self.TCP_PORT = 0x5555
		self.BUFFER_SIZE = 1024
		self.check_IP(self.TCP_IP)

		self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		self.s.connect((self.TCP_IP, self.TCP_PORT))


	def check_IP(self, IP):
		while os.system("ping -n 1 -w 1000 "+IP+" > nul ") != 0 :
			print("WARN: Connection to IP "+IP+" is broken. please check...")
			# exit()
		
		print("INFO: Connection to IP "+IP+" is OK.")	


	def disconnect_DLP(self):
		self.s.close()

	def send(self, msg, echoflag=0):
		checksum = 0
		for i in range(len(msg)):
			checksum += int(msg[i])
		checksum=checksum % 0x100

		tcp_msg = msg + bytes([checksum])

		if echoflag == 1:
			print("SEND:",tcp_msg[0:9],"...",tcp_msg[-5:])

		# s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		# s.connect((self.TCP_IP, self.TCP_PORT))
		self.s.send(tcp_msg)	
		data = self.s.recv(self.BUFFER_SIZE)
		# s.close()

		if echoflag == 1:
			print ("ECHO:", data)
			print ("DONE!")

	def getVersionString(self, load=0x10):
		HEAD = b'\x04'
		COMM = b'\x01'+b'\x00'
		FLAG = b'\x00'
		SIZE = b'\x01'+b'\x00'
		LOAD = bytes([load])
		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)

	def setDisplayMode(self, load=2):# 0 static image 1 internal test pattern 2 HDMI 3 Reserved 4 Pattern Sequence Display 
		HEAD = b'\x02'
		COMM = b'\x01'+b'\x01'
		FLAG = b'\x00'
		SIZE = b'\x01'+b'\x00'
		LOAD = bytes([load])
		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)

	def setVideoMode(self, fps=60, bit=6, color=3): # color 1: RGB, 2:RED, 3:GREEN, 4:BLUE
		HEAD = b'\x02'
		COMM = b'\x02'+b'\x01'
		FLAG = b'\x00'
		SIZE = b'\x03'+b'\x00'
		LOAD = bytes([fps,bit,color])
		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)

	def setTestPattern(self, load=1):
		HEAD = b'\x02'
		COMM = b'\x01'+b'\x03'
		FLAG = b'\x00'
		SIZE = b'\x01'+b'\x00'
		LOAD = bytes([load])
		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)


	def LEDCurrentSetting(self,GreenCurrent1 = 0x12 , GreenCurrent2 = 0x01, BlueCurrent1 = 0x12 , BlueCurrent2 = 0x01 ):
		HEAD = b'\x02'
		COMM = b'\x01'+b'\x04'
		FLAG = b'\x00'
		# SIZE = b'\x04'+b'\x00'
		# BYTES 0-1  Red LED current Range 0-1024 Default 274
		# BYTES 2-3  Green LED current Range 0-1024 Default 274
		# BYTES 4-5  Blue LED current Range 0-1024 Default 274
		LOAD = bytes([0x12, 0x01,  GreenCurrent1 , GreenCurrent2 , BlueCurrent1 , BlueCurrent2]) 
		SIZE = bytes([len(LOAD)%256,len(LOAD)//256])
		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)


	def loadStaticImage(self,img="demo.bmp"):
		print("INFO: Uploading file -",img)
		with open(img, "rb") as imageFile:
			f = imageFile.read()
			b = bytearray(f)

		imlen = len(b)
		# print ("TEST: image length =", imlen)
		index = 0		
		### need to cut the file into pieces ###
		### to do ... ###
		HEAD = b'\x02'
		COMM = b'\x01'+b'\x05'
		FLAG = b'\x01'
		# SIZE = b'\xff'+b'\xff'
		LOAD = b[0:0xffff]
		SIZE = bytes([len(LOAD)%256,len(LOAD)//256])
		# print ("TEST: load length =", len(LOAD))
		# print ("TEST:",len(b[0:0xffff]))
		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)
		index += 0xffff
		# time.sleep(0.01)

		while ((imlen-index)>0xffff):
			# HEAD = b'\x02'
			# COMM = b'\x01'+b'\x05'
			FLAG = b'\x02'
			# SIZE = b'\xff'+b'\xff'
			LOAD = b[index:index+0xffff]
			SIZE = bytes([len(LOAD)%256,len(LOAD)//256])
			# print ("TEST: load length =", len(LOAD))
			MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
			self.send(MESSAGE)
			index += 0xffff
			# time.sleep(0.01)

		# HEAD = b'\x02'
		# COMM = b'\x01'+b'\x05'
		FLAG = b'\x03'
		# SIZE = bytes([(imlen-index)%256,(imlen-index)//256])
		LOAD = b[index:imlen]
		SIZE = bytes([len(LOAD)%256,len(LOAD)//256])
		# print ("TEST: load length =", len(LOAD))
		# print ("TEST:",len(b[index:imlen]))
		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)
		# index += 0x10000

	def setStaticColor(self, red=0,green=0x7f,blue=0):
		# red=0
		# green=0xff
		# blue=0

		HEAD = b'\x02'
		COMM = b'\x01'+b'\x06'
		FLAG = b'\x00'
		# SIZE = b'\x04'+b'\x00'
		LOAD = bytes([blue,green,red,0])
		SIZE = bytes([len(LOAD)%256,len(LOAD)//256])
		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)


	def setFlipRotate(self, flip_x=0,flip_y=1,rotate=0):
		HEAD = b'\x02'
		COMM = b'\x01'+b'\x07'
		FLAG = b'\x00'
		# SIZE = b'\x04'+b'\x00'
		LOAD = bytes([flip_y,flip_x,rotate])
		SIZE = bytes([len(LOAD)%256,len(LOAD)//256])
		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)

	def setVideoInput(self):
		ResolutionX=608
		ResolutionY=684
		LeftCrop=0
		TopCrop=0
		RightCrop=608
		BottomCrop=684

		HEAD = b'\x02'
		COMM = b'\x02'+b'\x00'
		FLAG = b'\x00'
		SIZE = b'\x0c'+b'\x00'
		LOAD = bytes([ResolutionX%256,ResolutionX//256,
						ResolutionY%256,ResolutionY//256,
						LeftCrop%256,LeftCrop//256,
						TopCrop%256,TopCrop//256,
						RightCrop%256,RightCrop//256,
						BottomCrop%256,BottomCrop//256,
						])

		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)


	def setPatternSequence(self, colour = 1):
		trigger_period=8135
		exposure_time=8000

		tp=hex(trigger_period)[2:].zfill(8)
		et=hex(exposure_time)[2:].zfill(8)

		HEAD = b'\x02'
		COMM = b'\x04'+b'\x00'
		FLAG = b'\x00'
		# SIZE = b'\x04'+b'\x00'
		# LOAD = bytes([1,96,0,1, 0,0,0,0, 0,0,0,0, 0xff,15,0,0, 1])
		# BYTES 4-7  Input Trigger Delay in microsecond
		# BYTES 8-11  Trigger period in microsecond 5208= 0x58,0x14,0,0(only for autotrigg)
		# BYTES 12-15  Exposure time in microsecond 4500
		# LOAD = bytes([1,96,0,1, 0,0,0,0, 0,0,0,0, 0x94,0x11,0,0, 1]) # AUTO TRIGGER
		# BYTE 16  LED select : 0-Red 1-Green 2-Blue
		LOAD = bytes([1,96,0,2, 0,0,0,0, 0,0,0,0, 0x94,0x11,0,0, colour]) # external trigger
		SIZE = bytes([len(LOAD)%256,len(LOAD)//256])
		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)


	def loadPattern(self, folder=".\\JHHBAR"):
		HEAD = b'\x02'
		COMM = b'\x04'+b'\x01'

		filelist=os.listdir(folder)
		for i in range(len(filelist)):
			print(filelist[i],end='\r')
			# print([s for s in filelist if str(i) in filelist])
			with open(folder+'\\'+filelist[i], "rb") as imageFile:
				f = imageFile.read()
				b = bytearray(f)

			imlen = len(b)
			index = 0

			FLAG = b'\x01'
			LOAD = bytes([i])+b[0:0xfffe]
			index+=0xfffe
			SIZE = bytes([len(LOAD)%256,len(LOAD)//256])
			MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
			self.send(MESSAGE)

			while((imlen-index)>0xffff):	
				FLAG=b'\x02'
				LOAD = bytes([i])+b[index:index+0xfffe]
				index+=0xfffe
				SIZE = bytes([len(LOAD)%256,len(LOAD)//256])
				MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
				self.send(MESSAGE)

			FLAG = b'\x03'
			LOAD = bytes([i])+b[index:imlen]
			# index+=0xfffe
			SIZE = bytes([len(LOAD)%256,len(LOAD)//256])
			MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
			self.send(MESSAGE)


	def startPattern(self, flag=1):
		HEAD = b'\x02'
		COMM = b'\x04'+b'\x02'
		FLAG = b'\x00'
		LOAD = bytes([flag])
		SIZE = bytes([len(LOAD)%256,len(LOAD)//256])
		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)


	def setTriggerOut(self):
		HEAD = b'\x02'
		COMM = b'\x04'+b'\x04'
		FLAG = b'\x00'
		# SIZE = b'\x04'+b'\x00'
		LOAD = bytes([1,1,0, 0,0,0,0, 0xD0,0x7,0,0]) #2000 usec
		SIZE = bytes([len(LOAD)%256,len(LOAD)//256])
		MESSAGE = HEAD+COMM+FLAG+SIZE+LOAD
		self.send(MESSAGE)

##########################################################################
##########################################################################
##########################################################################

# if __name__ == "__main__":

# 	d1 = DLP_LightCrafter('192.168.1.50')

# 	d1.setDisplayMode(4)
# 	d1.setPatternSequence()
# 	d1.setTriggerOut()

# 	d1.loadPattern(folder=".\\dot_96")




# 	d1.setDisplayMode(4)
# 	d1.startPattern()

# 	time.sleep(10)
# 	d1.setDisplayMode(0)
# 	d1.setStaticColor(green=0x0)

# 	d1.disconnect_DLP()
# 	print("DLP1 SEQUENCE LOADED: End of the session.")
	
# # 	##############################################


