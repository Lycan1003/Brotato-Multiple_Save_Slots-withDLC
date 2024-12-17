extends Node

const MOD_DIR = "Lasonbrah-betterSaver/"
const MYMODNAME_LOG = "Lasonbrah-betterSaver"

var dir = ""

func _init(_modLoader = ModLoader):
	name = "betterSaver_mod_main"
	ModLoaderLog.info("Init", MYMODNAME_LOG)
	dir = ModLoaderMod.get_unpacked_dir() + MOD_DIR

func _ready():
	ModLoaderLog.info("Done", MYMODNAME_LOG)
	var monitor = load(dir + "betterSaver_main_monitor.gd").new(dir)
	ProgressData.add_child(monitor)
