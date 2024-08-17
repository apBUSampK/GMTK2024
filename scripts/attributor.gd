extends RefCounted

class Attributor:
	# aggressiveness
	var agro: float = 0.0
	# movement speed
	var speed: float = 1.0
	# how brave the creature is
	var guts: float = 0.0
	# field of view in radians
	var fov: float = PI/2
	# radius in which the creature can sense other creatures even outside fov
	var senseRadius: float = 1.0
	# minimum temperature that the creature can survive, in Kelvins
	var minTemp: float = 273.0
	# maximum temperature that the creature can survive, in Kelvins
	var maxTemp: float = 333.0
	# minimum food amount for the creature to survive
	var minFood: float = 2.0
	# maximum food amount that the creature can hold inside
	var maxFood: float = 10.0
	# amount of food that is needed for childbirth
	var birthFood: float = 8.0
	# food digestion pace
	var hungerRate: float = 1.0
