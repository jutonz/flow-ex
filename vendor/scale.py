import time
import sys
import RPi.GPIO as GPIO
from hx711 import HX711
from erlport.erlterms import Atom
from erlport.erlang import cast

class Scale:
    def __init__(self):
        self.scale = HX711(5, 6)
        self.scale.set_reading_format("MSB", "MSB")
        self.scale.set_reference_unit(428)
        self.scale.reset()
        self.scale.tare()

    def get_measurement(self):
        weight = self.scale.get_weight(5)
        self.scale.power_down()
        self.scale.power_up()
        return weight

class Scale2:
    def get_measurement(self):
        return 123

scale = None

def setup():
    global scale
    scale = Scale()

def teardown():
    GPIO.cleanup()

def get_measurement():
    return scale.get_measurement()
