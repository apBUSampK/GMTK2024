extends RefCounted

enum Genes {
	# LEVEL 1 Genes
	Calm,
	Agile,
	Fertile,
	Aggressive,
	
	# LEVEL 2 Genes
	Cautious,
	Reckless,
	ThickSkinned,
	ThinSkinned,
	
	# LEVEL 3 Genes
	Spiky,
	Hasty,
	Shelled,
	LongLife,
	
	# LEVEL 4 Genes
	Straightforward,
	Radar,
	Swift,
	Healthy,
	
	# LEVEL 5 Genes
	Tank,
	Killer,
	Sly
}

const MUCH = "Much "
const SLIGHT = "Slightly "
const LESS = "less "
const MORE = "more "

const Descriptions = {
	"Calm":  [MUCH + LESS + "aggression\n", SLIGHT + MORE + "HP\n", SLIGHT + LESS + "guts\n"],
	"Agile": [MUCH + MORE + "speed\n", MUCH + LESS + "guts\n"],
	"Fertile": [MUCH + MORE + "fertility\n", MUCH + LESS + "guts\n", ],
	"Aggressive": [MUCH + MORE + "aggression\n", SLIGHT + MORE + "HP\n", SLIGHT + LESS + "field_of_view\n"]
}

static func ToStr(gene):
	return Genes.keys()[gene]

static func FromStr(geneName):
	return Genes.keys().find(geneName)
