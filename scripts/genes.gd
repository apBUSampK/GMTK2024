extends RefCounted

enum Genes {
	Calm,
	Agile,
	Insulated,
	Fertile,
	Shocker
}

const Descriptions = {
	"Calm": ["Much less aggressive\n", "Slightly more HP\n", "Slight less guts\n"],
	"Agile": ["Much more speed\n", "Much less guts\n"],
	"Insulated": ["Much more HP\n", "Slightly less speed\n", "Slightly less fertility\n"],
	"Fertile": ["Much more fetility\n", "Much less guts\n", ],
	"Shocker": ["Slight less HP\n", "Slight more speed\n"],
}

func ToStr(gene):
	return Genes.keys()[gene]
