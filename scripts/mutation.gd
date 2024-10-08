extends Control

const Mut = preload("res://scenes/mutations/mut.tscn")
const PossibleMut = preload("res://scenes/mutations/possible_mut.tscn")
const attributor = preload("res://scripts/attributor.gd")
const genes = preload("res://scripts/genes.gd")

@export var MutCont: Control

var currActor: BasicActor
var newMutations: Array[TabContainer]
var availGenes: Array

func readyMenuForActor(actor: BasicActor):
	get_tree().paused = true
	show()
	currActor = actor
	actor.modulate.v *= 1.5
	#actor.debug_list_attrs()

func destrMenuForActor(actor: BasicActor):
	hide()
	actor.modulate.v /= 1.5
	currActor = null
	for idx in range(1, MutCont.get_child_count()):
		MutCont.get_child(idx).queue_free()
	get_tree().paused = false
	#actor.debug_list_attrs()

func LoadGenesForActor(actor: BasicActor):
	readyMenuForActor(actor)
	var lvl = get_parent().get_parent().lvl + 1
	availGenes = genes.Genes.values().duplicate().slice((lvl * 4 - 4), (lvl * 4))
	for gene in actor.Genes:
		availGenes.erase(gene)
		var mutInst: TextureButton = Mut.instantiate()
		mutInst.SetGene(genes.ToStr(gene))
		mutInst.SetTextShort()
		mutInst.z_index = gene
		MutCont.add_child(mutInst)
	MutCont.get_child(0).grab_focus()
	
	newMutations = []
	var needGenes = lvl * 2 - len(actor.Genes)
	for idx in needGenes:
		NewMutation(actor.GenesLvl, needGenes - idx + 1)

func getRandomNewGene(from: Array, lvl: int) -> int:
	if from.is_empty():
		return -1
	var choice = from.pick_random()
	from.erase(choice)
	return choice

func NewMutation(lvl: int, z_idx: int):
	var possible: TabContainer = PossibleMut.instantiate()
	var mutInst: TextureButton
	var gene: genes.Genes
	
	if availGenes.is_empty():
		return
	
	# Option 1
	mutInst = Mut.instantiate()
	gene = getRandomNewGene(availGenes, lvl)
	if gene >= 0:
		mutInst.SetGene(genes.ToStr(gene))
		possible.add_child(mutInst)
	
	# Option 2
	mutInst = Mut.instantiate()
	gene = getRandomNewGene(availGenes, lvl)
	if gene >= 0:
		mutInst.SetGene(genes.ToStr(gene))
		possible.add_child(mutInst)
	
	newMutations.append(possible)
	possible.z_index = z_idx
	MutCont.add_child(possible)

func mutation_change_param(mutation_name: String, actor_attributes: attributor.Attributor):
	for mutation_description in genes.Descriptions[mutation_name]: 
		var words = mutation_description.split(" ", false)
		var increase_strength_str = words[0].to_lower() + "_change"
		var increase_type = words[1]
		var attribute_name = words[2].rstrip("\n")
		
		var property = actor_attributes.get_property_by_attribute_name(attribute_name)
		var new_property = property
		var increase_strength = property.get(increase_strength_str)
		
		if (increase_type == 'less'):
			#print(attribute_name, " = ", new_property.value, " - ", increase_strength)
			new_property.value -= increase_strength
		else:
			#print(attribute_name, " = ", new_property.value, " + ", increase_strength)
			new_property.value += increase_strength
		
		new_property.value = clamp(new_property.value, 0.01, 100000)
		actor_attributes.set_property_by_attribute_name(attribute_name, new_property)

func _on_done_pressed():
	for newMut in newMutations:
		var mutName = newMut.get_current_tab_control().name
		#print("Adding ", mutName)
		mutation_change_param(mutName, currActor.attrs)
		currActor.Genes.append(genes.FromStr(mutName))
	destrMenuForActor(currActor)
