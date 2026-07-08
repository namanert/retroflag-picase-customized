import RPi.GPIO as GPIO
import os
import time
from threading import Thread

#initialize pins
powerPin = 3 #pin 5
ledPin = 14 #TXD
resetPin = 2 #pin 13
powerenPin = 4 #pin 5

#initialize GPIO settings
def init():
	GPIO.setmode(GPIO.BCM)
	GPIO.setup(powerPin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
	GPIO.setup(resetPin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
	GPIO.setup(ledPin, GPIO.OUT)
	GPIO.output(ledPin, GPIO.HIGH)
	GPIO.setup(powerenPin, GPIO.OUT)
	GPIO.output(powerenPin, GPIO.HIGH)
	GPIO.setwarnings(False)

#waits for user to hold button up to 1 second before issuing poweroff command
def poweroff():
	while True:
		#self.assertEqual(GPIO.input(powerPin), GPIO.LOW)
		GPIO.wait_for_edge(powerPin, GPIO.FALLING)
		time.sleep(5)
		os.system("shutdown -r now")

#blinks the LED to signal button being pushed
def ledBlink():
	while True:
		GPIO.output(ledPin, GPIO.HIGH)
		#self.assertEqual(GPIO.input(powerPin), GPIO.LOW)
		GPIO.wait_for_edge(powerPin, GPIO.FALLING)
		start = time.time()
		while GPIO.input(powerPin) == GPIO.LOW:
			GPIO.output(ledPin, GPIO.LOW)
			time.sleep(0.2)
			GPIO.output(ledPin, GPIO.HIGH)
			time.sleep(0.2)

#resets the pi
def reset():
	while True:
		#self.assertEqual(GPIO.input(resetPin), GPIO.LOW)
		GPIO.wait_for_edge(resetPin, GPIO.FALLING)
		time.sleep(5)
		os.system("shutdown -r now")


if __name__ == "__main__":
	#initialize GPIO settings
	init()
	#run each function on its own thread; lgpio's edge-detection handle is
	#tied to a single process, so forked subprocesses (multiprocessing)
	#collide when claiming GPIO events on Trixie's python3-rpi-lgpio backend
	powerThread = Thread(target = poweroff, daemon = True)
	powerThread.start()
	ledThread = Thread(target = ledBlink, daemon = True)
	ledThread.start()
	resetThread = Thread(target = reset, daemon = True)
	resetThread.start()

	powerThread.join()
	ledThread.join()
	resetThread.join()

	GPIO.cleanup()
