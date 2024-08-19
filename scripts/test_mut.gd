extends TextureButton

const genes = preload("res://scripts/genes.gd")

var thisGene

func SetGene(gene):
	thisGene = gene
	name = gene
	SetTextShort()

func SetTextShort():
	$Text.text = thisGene

func SetTextFull():
	var text = thisGene + "\n"
	for attr in genes.Descriptions[thisGene]:
		text += attr
	$Text.text = text

func GetText() -> String:
	return $Text.text

func _on_focus_entered():
	call_deferred("SetTextFull")

func _on_focus_exited():
	call_deferred("SetTextShort")
