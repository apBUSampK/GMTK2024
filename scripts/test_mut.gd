extends TextureButton

const Genes = preload("res://scripts/genes.gd")

var thisGene

func SetGene(gene):
	thisGene = gene

func SetTextShort():
	$Text.text = thisGene

func SetTextFull():
	var text = thisGene + "\n"
	for attr in Genes.Descriptions[thisGene]:
		text += attr
	$Text.text = text

func GetText() -> String:
	return $Text.text

func _on_focus_entered():
	SetTextFull()
	self_modulate.v = 0.3

func _on_focus_exited():
	SetTextShort()
	self_modulate.v = 1.0
