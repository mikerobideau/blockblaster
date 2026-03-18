extends RefCounted
class_name Database

const FormationDatabase = preload("res://global/database/entity/formation_database.gd")
const TargetDatbase = preload("res://global/database/entity/target_database.gd")

static var formation: FormationDatabase = FormationDatabase.new()
static var target: TargetDatabase = TargetDatabase.new()

static var _initialized: bool = false

static func initialize():
	if _initialized: return
	formation.load_all()
	target.load_all()
