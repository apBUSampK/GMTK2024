extends RefCounted

class Attribute:
	var name: String
	var value
	var much_change
	var slightly_change
	
	func _init(name_: String, value_, much_change_=10, slightly_change_=10):
		self.name = name_
		self.value = value_
		self.much_change = much_change_
		self.slightly_change = slightly_change_
	
class Attributor:
	# lifetime (in seconds)
	var lifeTime = Attribute.new("lifetime", 300)
	
	# max hp
	var maxHp = Attribute.new("HP", 400.0)
	
	# damage
	var damage = Attribute.new("damage", 20.0)
	
	# attack speed
	var attackSpeed = Attribute.new("attack_speed", 1.0)
	
	# aggression
	var aggression = Attribute.new("aggression", 0.0)
	
	# curiosity
	var curiosity = Attribute.new("curiosity", 0.1)
	
	# movement speed
	var movementSpeed = Attribute.new("speed", 600.0)
	
	# turning speed in radians
	var turnSpeed = Attribute.new("turning_speed", 3)
	
	# how brave the creature is
	var guts = Attribute.new("guts", 0.0)
	
	# range of view
	var viewRange = Attribute.new("view_range", 400.0)
	
	# field of view in radians
	var fieldOfView = Attribute.new("field_of_view", PI / 3)
	
	# radius in which the creature can sense other creatures even outside fov
	var senseRadius = Attribute.new("sense_radius", 100.0)
	
	# minimum temperature that the creature can survive, in Kelvins
	var minTemp = Attribute.new("minimal_temerature", 273.0)
	
	# maximum temperature that the creature can survive, in Kelvins
	var maxTemp = Attribute.new("maximum_temerature", 333.0)
	
	# minimum food amount for the creature to survive
	var maxFood = Attribute.new("maximum_food", 10.0)
	
	# amount of food that is needed for childbirth
	var birthFood = Attribute.new("birth_food", 8.0)
	
	# food digestion pace
	var hungerRate = Attribute.new("hunger_rate", 1.0)
	
	# fertility (chance for producing offspring if food is sufficient on state update)
	var fertility = Attribute.new("fertility", .7)
	
	# dictonary to keep relationsheep between class propery's name and attribute name 
	var _attribute_name_to_property: Dictionary
	
	func debug_list_props():
		for property in get_property_list():
			var prop = self.get(property['name'])
			if prop:
				if prop is Attribute:
					print("\t", property['name'], ": ", prop.value)
	
	# [DKay]: Unfortunately, this function can't be call from _init method 
	#		  so, we will call it from get/set property by attr function but with caching
	func fill_attr_to_property_dict():
		if not _attribute_name_to_property.is_empty():
			return
		for property in get_property_list():
			#print("Looking for ", property['name'], ", of class |", property['class_name'], 
			#      "| hint ", property['hint'], ", type ", property['type'])
			var prop = self.get(property['name'])
			if prop:
				if prop is Attribute:
					_attribute_name_to_property[prop.name] = property.name
	
	func get_property_by_attribute_name(attribute_name: String):
		fill_attr_to_property_dict()
		
		var property_name = _attribute_name_to_property[attribute_name]
		return self.get(property_name)
	
	func set_property_by_attribute_name(attribute_name: String, property: Attribute):
		fill_attr_to_property_dict()
	
		var property_name = _attribute_name_to_property[attribute_name]
		self.set(property_name, property)
	
