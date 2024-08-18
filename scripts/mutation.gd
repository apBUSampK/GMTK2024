extends Node2D

const Mut = preload("res://scenes/mutations/mut.tscn")
const PossibleMut = preload("res://scenes/mutations/possible_mut.tscn")
const attributor = preload("res://scripts/attributor.gd")

@onready var MutCont = $Control/Scroll/MutationContainer
@onready var Genes = preload("res://scripts/genes.gd").new()

# TODO: change genes enum to actor's genes
func LoadGenesForActor(actor: Node2D):
	for gene in Genes.Genes:
		var mutInst: TextureButton = Mut.instantiate()
		mutInst.SetGene(gene)
		mutInst.SetTextShort()
		MutCont.add_child(mutInst)

func NewMutation():
	var possible: TabContainer = PossibleMut.instantiate()
	var mutInst: TextureButton = Mut.instantiate()
	var geneName = Genes.ToStr(Genes.Genes.Agile)
	mutInst.SetGene(geneName)
	possible.add_child(mutInst)
	
	mutInst = Mut.instantiate()
	mutInst.SetGene(Genes.ToStr(Genes.Genes.Calm))
	possible.add_child(mutInst)
	
	MutCont.add_child(possible)
	MutCont.get_child(0).get_child(0).grab_focus()

# Called when the node enters the scene tree for the first time.
func _ready():
	NewMutation()
	LoadGenesForActor(null)

func mutation_change_param(mutation_name: String, actor_attributes: attributor.Attributor):
	for mutation_description in Genes.Descriptions[mutation_name]: 
		var words = mutation_description.split(" ", false)
		var increase_type = words[1]
		var attribute_name = words[2]
		var increase_strength_str = words[0].to_lower()
		
		var property = actor_attributes.get_property_by_attribute_name(attribute_name)
		var new_property = property
		var increase_strength = property.get(increase_strength_str)
		
		if (increase_type == 'less'):
			new_property.value -= increase_strength
		else:
			new_property.value += increase_strength
		
		actor_attributes.set_property_by_attribute_name(attribute_name, new_property)
