extends RefCounted

enum States {
	IDLE,
	ATTACKING,
	FLEEING,
	REPRODUCING,
	SCOUTING,
	GRABBING,
	DYING,
}

class StateMachine:
	func dummy():
		print("DUMMY, state =", state)
	
	var state: States
	var state_funcs: Array[Callable] = []
	
	func _init(init_state: States):
		state = init_state
	
	func SetState(st: States):
		state = st
	
	func SetFunctions(funcs: Dictionary):
		for state_val in States:
			state_funcs.append(funcs[state_val])
	
	func process():
		state_funcs[state].call()
