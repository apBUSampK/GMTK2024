extends TextureButton

const Genes = preload("res://scripts/genes.gd")
#const TextStyle = preload("res://scenes/mutations/style.tres")
#const TextStyleDarker = preload("res://scenes/mutations/style_darker.tres")

var thisGene

func SetGene(gene):
	thisGene = gene
	name = gene
	SetTextShort()

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
	call_deferred("SetTextFull")
	#$Text.add_theme_stylebox_override("normal", TextStyle)

func _on_focus_exited():
	call_deferred("SetTextShort")
	#$Text.add_theme_stylebox_override("normal", TextStyleDarker)
