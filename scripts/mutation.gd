extends Node2D

const Genes = preload("res://scripts/genes.gd")
const Mut = preload("res://scenes/mutations/test_mut.tscn")
@onready var MutCont = $Control/Scroll/MutationContainer

func genNoiseTexture() -> NoiseTexture2D:
	var noise = FastNoiseLite.new()
	noise.frequency = 0.002 * randf_range(0.5, 2.0)
	noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED
	noise.fractal_gain = 1.0
	noise.offset.x = randf_range(0, 1000)
	noise.offset.y = randf_range(0, 1000)
	
	var tex = NoiseTexture2D.new()
	tex.noise = noise
	tex.width = 128
	tex.height = 128
	return tex

# TODO: change genes enum to actor's genes
func LoadMutForActor(actor: Node2D):
	for gene in Genes.Genes:
		var mutInst: TextureButton = Mut.instantiate()
		mutInst.SetGene(gene)
		mutInst.SetTextShort()
		mutInst.texture_normal = genNoiseTexture()
		MutCont.add_child(mutInst)
	MutCont.get_child(0).grab_focus()

# Called when the node enters the scene tree for the first time.
func _ready():
	LoadMutForActor(null)
