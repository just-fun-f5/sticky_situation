extends Control

# Constantes
var maxHP = 100 setget _set_maxHP
var maxMP = 100 setget _set_maxMP
onready var MP_Bar = $UI/MP/MPBar
onready var HP_Bar = $UI/HP/HPBar

# Vars
var HP: float = 100 setget _set_HP
var MP: float = 100 setget _set_MP

func visible(status):
	$UI.visible = status

func _ready():
	self.hit_HP(50)

func _always_on(value):
	MP_Bar.visible = value
	HP_Bar.visible = value

# Sets MAXS
# Setea el maximo de cada cantidad

func _set_maxMP(maxValue):
	maxMP = maxValue
	MP_Bar.max_value = maxMP
func _set_maxHP(maxValue):
	maxHP = maxValue
	HP_Bar.max_value = maxHP

# Sets Value
# Setea la cantidad actual del valor entre 0 y su maximo
func _set_HP(value):
	HP = clamp(value, 0, maxHP)
	HP_Bar.value = HP
	return HP <= 0 
func _set_MP(value):
	MP = clamp(value, 0, maxMP)
	MP_Bar.value = MP
	return MP <= 0

# Modificadores absolutos
# Modifica una cantidad fija a la cantidad actual
func hit_HP(quantity):
	var state
	state = _set_HP(HP - quantity)
	return state
func hit_MP(quantity):
	var state
	state = _set_MP(MP - quantity)
	return state

# Modificadores porcentuales absolutos
# Modifica una cantidad porcentual de su maximo a la actual 
func rela_HP(quantity):
	if quantity != 0:
		var state
		# Cantidad actual + signo * max(Porcentaje max, 1) => El minimo que modifica es 1!
		var mod = maxHP + sign(quantity) * max(maxHP*abs(quantity)*0.01, 1)
		state = self._set_HP(mod) 
		return state
	else:
		print("ERR: quantity = 0")
		return null
func rela_MP(quantity):
	if quantity != 0:
		var state
		# Cantidad actual + signo * max(Porcentaje max, 1) => El minimo que modifica es 1!
		var mod = maxMP + sign(quantity) * max(maxMP*abs(quantity)*0.01, 1)
		state = self._set_MP(mod) 
		return state
	else:
		print("ERR: quantity = 0")
		return null

# Modificadores porcentuales relativos
# Modifica una cantidad porcentual de su relativo a la actual 
func rel_HP(quantity):
	if quantity != 0:
		var state
		# Cantidad actual + signo * max(Porcentaje actual, 1) => El minimo que modifica es 1!
		var mod = HP + sign(quantity) * max(HP*abs(quantity)*0.01, 1)
		state = self._set_HP(mod) 
		return state
	else:
		print("ERR: quantity = 0")
		return null
func rel_MP(quantity):
	if quantity != 0:
		var state
		# Cantidad actual + signo * max(Porcentaje actual, 1) => El minimo que modifica es 1!
		var mod = MP + sign(quantity) * max(MP*abs(quantity)*0.01, 1)
		state = self._set_MP(mod) 
		return state
	else:
		print("ERR: quantity = 0")
		return null
