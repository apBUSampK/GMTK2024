extends RefCounted

enum Genes {
	Calm,
	Agile,
	Insulated,
	Fertile,
	Shocker
}

const MUCH = "Much "
const SLIGHT = "Slightly "
const LESS = "less "
const MORE = "more "

const Descriptions = {
	"Calm":  [MUCH + LESS + "aggression\n", SLIGHT + MORE + "HP\n", SLIGHT + LESS + "guts\n"],
	"Agile": [MUCH + MORE + "speed\n", MUCH + LESS + "guts\n"],
	"Insulated": [MUCH + MORE + "HP\n", SLIGHT + LESS + "speed\n", SLIGHT + LESS + "fertility\n"],
	"Fertile": [MUCH + MORE + "fertility\n", MUCH + LESS + "guts\n", ],
	"Shocker": [SLIGHT + LESS + "HP\n", SLIGHT + MORE + "speed\n"],
}

static func ToStr(gene):
	return Genes.keys()[gene]

static func FromStr(geneName):
	return Genes.keys().find(geneName)
