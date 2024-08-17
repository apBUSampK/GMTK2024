extends Node2D

const Mut = preload("res://scenes/mutations/mut.tscn")
const PossibleMut = preload("res://scenes/mutations/possible_mut.tscn")

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
