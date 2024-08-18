extends RefCounted

class Attribute:
	var name: String
	var value
	var much_change
	var slight_change
	
	func _init(name_: String, value_, much_change_=10, slight_change_=10):
		self.name = name_
		self.value = value_
		self.much_change = much_change_
		self.slight_change = slight_change_
	
class Attributor:
	# lifetime (in seconds)
	var lifeTime = Attribute.new("lifetime", 300)
	
	# max hp
	var maxHp = Attribute.new("HP", 400.0)
	
	# damage
	var damage = Attribute.new("damage", 20.0)
	
	# attack speed
	var attackSpeed = Attribute.new("attack speped", 1.0)
	
	# aggresivity
	var aggresivity = Attribute.new("aggresivity", 0.0)
	
	# curiosity
	var curiosity = Attribute.new("curiosity", 0.1)
	
	# movement speed
	var movementSpeed = Attribute.new("speed", 6.0)
	
	# turning speed in radians
	var turnSpeed = Attribute.new("turning speed", 0.1)
	
	# how brave the creature is
	var guts = Attribute.new("guts", 0.0)
	
	# range of view
	var viewRange = Attribute.new("view range", 300.0)
	
	# field of view in radians
	var fieldOfView = Attribute.new("field of view", PI / 2)
	
	# radius in which the creature can sense other creatures even outside fov
	var senseRadius = Attribute.new("sense radius", 1.0)
	
	# minimum temperature that the creature can survive, in Kelvins
	var minTemp = Attribute.new("minimal temerature", 273.0)
	
	# maximum temperature that the creature can survive, in Kelvins
	var maxTemp = Attribute.new("maximum temerature", 333.0)
	
	# minimum food amount for the creature to survive
	var maxFood = Attribute.new("maximum food", 10.0)
	
	# amount of food that is needed for childbirth
	var birthFood = Attribute.new("birth food", 8.0)
	
	# food digestion pace
	var hungerRate = Attribute.new("hunger rate", 1.0)
	
	# fertility (chance for producing offspring if food is sufficient on state update)
	var fertility = Attribute.new("fertility", .7)
	
	# dictonary to keep relationsheep between class propery's name and attribute name 
	var _attribute_name_to_property: Dictionary
	
	func _init():
		for property in get_property_list():
			pass
			#_attribute_name_to_property[(self.get(property['name'])).name] = property.name
	
	func get_property_by_attribute_name(attribute_name: String):
		var property_name = _attribute_name_to_property[attribute_name]
		return self.get(property_name)
	
	func set_property_by_attribute_name(attribute_name: String, property: Attribute):
		var property_name = _attribute_name_to_property[attribute_name]
		self.set(property_name, property)
	
