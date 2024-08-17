extends RefCounted

enum States {
	IDLE,
	ATTACKING,
	FLEEING,
	REPRODUCING,
	SCOUTING,
	GRABBING,
	DYING,
	INVALID_STATE
}

class StateMachine:
	func dummy():
		print(state)
	
	var state: States
	var state_funcs: Array[Callable] = []
	
	func _init(init_state: States):
		state = init_state
		
		var funcs = {}
		for state in States:
			funcs[state] = dummy
		
		set_functions(funcs)
	
	func set_functions(funcs: Dictionary):
		for state_val in States:
			state_funcs.append(funcs[state_val])
	
	func process():
		state_funcs[state].call()
