extends TextureButton

const Genes = preload("res://scripts/genes.gd")

var thisGene

func SetGene(gene):
	thisGene = gene

func SetTextShort():
	$Text.text = thisGene

func SetTextFull():
	$Text.text = thisGene + "\n" + Genes.Descriptions[thisGene]

func GetText() -> String:
	return $Text.text

func _on_focus_entered():
	SetTextFull()

func _on_focus_exited():
	SetTextShort()
