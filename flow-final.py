#!/usr/bin/env python3

import RPi.GPIO as GPIO
import time, sys
import requests

API_ENDPOINT = "https://app.jutonz.com/api/water-logs/f150cb6e-f0e0-4674-a5cc-a22b3fa3df28/entries"
AUTH_TOKEN = "123"

FLOW_SENSOR = 24
IDEAL_PULSES_PER_LITER = 4380
PULSE_ADJUSTOR = -575
PULSES_PER_LITER = IDEAL_PULSES_PER_LITER + PULSE_ADJUSTOR

GPIO.setmode(GPIO.BCM)
GPIO.setup(FLOW_SENSOR, GPIO.IN, pull_up_down = GPIO.PUD_UP)

global totalPulses
totalPulses = 0
global secondsElapsed
secondsElapsed = 0
global secondsWithoutFlow
secondsWithoutFlow = 0

def countPulse(_channel):
    global totalPulses
    totalPulses += 1

def noFlowForTenSeconds(pulsesLastTime, pulsesThisTime):
    global secondsWithoutFlow

    if pulsesLastTime != 0 and pulsesLastTime == pulsesThisTime:
        secondsWithoutFlow += 1
    else:
        secondsWithoutFlow = 0

    return secondsWithoutFlow >= 10

GPIO.add_event_detect(FLOW_SENSOR, GPIO.FALLING, callback=countPulse)

print('0 pulses (0.0 L)')

while True:
    try:
        pulsesLastTime = totalPulses
        time.sleep(1)
        pulsesThisTime = totalPulses


        if noFlowForTenSeconds(pulsesLastTime, pulsesThisTime):
            print('No flow for 10 seconds. Uploading result...')
            liters = totalPulses / PULSES_PER_LITER
            ml = int(liters * 1000)
            body = {'ml': ml}
            headers = {'Authorization': f'Bearer {AUTH_TOKEN}'}
            resp = requests.post(url = API_ENDPOINT, data = body, headers = headers)
            print(resp.text)
            totalPulses = 0

        secondsElapsed += 1
        if pulsesThisTime != 0 and pulsesLastTime != 0:
            liters = totalPulses / PULSES_PER_LITER
            print(f'{totalPulses} pulses ({liters} L)')

    except KeyboardInterrupt:
        print('\ncaught keyboard interrupt!, bye')
        GPIO.cleanup()
        sys.exit()
