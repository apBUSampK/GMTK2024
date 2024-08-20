extends RefCounted

enum Genes {
	# LEVEL 1 Genes
	Calm,
	Aggressive,
	ThickSkinned,
	ThinSkinned,
	
	# LEVEL 2 Genes
	Cautious,
	Reckless,
	Agile,
	Fertile,
	
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
	Sly,
	Hunter
}

const MUCH = "Much "
const SLIGHT = "Slightly "
const LESS = "less "
const MORE = "more "

const Descriptions = {
	"Calm":  [MUCH + LESS + "aggression\n", SLIGHT + MORE + "HP\n", SLIGHT + LESS + "guts\n"],
	"Agile": [MUCH + MORE + "speed\n", MUCH + LESS + "guts\n", SLIGHT + MORE + "curiosity\n"],
	"Fertile": [MUCH + MORE + "fertility\n", MUCH + LESS + "guts\n", ],
	"Aggressive": [MUCH + MORE + "aggression\n", SLIGHT + MORE + "HP\n", SLIGHT + LESS + "field_of_view\n"],
	"Cautious": [SLIGHT + LESS + "aggression\n", MUCH + MORE + "view_range\n", SLIGHT + MORE + "field_of_view\n"],
	"Reckless": [MUCH + MORE + "guts\n", MUCH + MORE + "curiosity\n"],
	"ThickSkinned": [MUCH + MORE + "maximum_temerature\n", SLIGHT + MORE + "minimal_temerature\n", SLIGHT + MORE + "HP\n"],
	"ThinSkinned": [MUCH + LESS + "minimal_temerature\n", SLIGHT + LESS + "maximum_temerature\n", SLIGHT + MORE + "speed\n"],
	"Spiky": [SLIGHT + MORE + "damage\n", SLIGHT + MORE + "view_range\n", SLIGHT + MORE + "guts\n"],
	"Hasty": [MUCH + MORE + "speed\n", MUCH + MORE + "curiosity\n"],
	"Shelled": [MUCH + LESS + "speed\n", MUCH + MORE + "guts\n", SLIGHT + LESS + "field_of_view\n"],
	"LongLife": [MUCH + MORE + "lifetime\n", MUCH + LESS + "fertile\n"],
	"Straightforward": [MUCH + MORE + "guts\n", MUCH + MORE + "curiosity\n", SLIGHT + MORE + "speed\n"],
	"Radar": [MUCH + MORE + "sense_radius\n", MUCH + MORE + "view_range\n"],
	"Swift": [MUCH + MORE + "speed\n", MUCH + MORE + "speed\n", MUCH + MORE + "curiosity\n"],
	"Healthy": [MUCH + MORE + "HP\n", MUCH + MORE + "guts\n"],
	"Tank": [MUCH + MORE + "HP\n", MUCH + MORE + "HP\n", MUCH + LESS + "speed\n"],
	"Killer": [MUCH + MORE + "damage\n", MUCH + MORE + "guts\n", MUCH + LESS + "speed\n"],
	"Sly": [MUCH + LESS + "guts\n", MUCH + MORE + "speed\n", MUCH + MORE + "fertility\n"],
	"Hunter": [MUCH + MORE + "HP\n", MUCH + MORE + "speed\n", SLIGHT + LESS + "fertility\n"]
}

static func ToStr(gene):
	return Genes.keys()[gene]

static func FromStr(geneName):
	return Genes.keys().find(geneName)
