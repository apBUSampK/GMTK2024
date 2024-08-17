extends RefCounted

class Attributor:
	# lifetime (in seconds)
	var lTime: int = 300
	# max hp
	var mhp: float = 400.0
	# damage
	var dmg: float = 20
	# attack speed
	var aspd: float = 1
	# aggressiveness
	var agro: float = 0.0
	# curiosity
	var curious: float = .1
	# movement speed
	var speed: float = 1.0
	# turning speed in radians
	var phiSpeed: float = 2.0
	# how brave the creature is
	var guts: float = 0.0
	# range of view
	var vRange: float = 30
	# field of view in radians
	var fov: float = PI/2
	# radius in which the creature can sense other creatures even outside fov
	var senseRadius: float = 1.0
	# minimum temperature that the creature can survive, in Kelvins
	var minTemp: float = 273.0
	# maximum temperature that the creature can survive, in Kelvins
	var maxTemp: float = 333.0
	# minimum food amount for the creature to survive
	var maxFood: float = 10.0
	# amount of food that is needed for childbirth
	var birthFood: float = 8.0
	# food digestion pace
	var hungerRate: float = 1.0
	# fertility (chance for producing offspring if food is sufficient on state update)
	var fertility: float = .7
