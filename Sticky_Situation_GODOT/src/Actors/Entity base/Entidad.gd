class_name Entity
extends KinematicBody2D

# Constantes
var maxHP = 100 setget _set_maxHP
var maxMP = 100 setget _set_maxMP

# Vars
var HP: float = 100 setget _set_HP
var MP: float = 100 setget _set_MP

# Sets MAXS
# Setea el maximo de cada cantidad
func _set_maxMP(maxValue):
	maxMP = maxValue
func _set_maxHP(maxValue):
	maxHP = maxValue

# Sets Value
# Setea la cantidad actual del valor entre 0 y su maximo
func _set_HP(value):
	HP = clamp(value, 0, maxHP)
	$CanvasLayer/UI/HP/HPBar.value = HP
	return true if HP <= 0 else false
func _set_MP(value):
	MP = clamp(value, 0, maxMP)
	$CanvasLayer/UI/MP/MPBar.value = MP
	return true if MP <= 0 else false

# Modificadores absolutos
# Modifica una cantidad fija a la cantidad actual
func hit_HP(quantity):
	var state
	state = self._set_HP(HP + quantity)
	return state
func hit_MP(quantity):
	var state
	state = self._set_MP(MP + quantity)
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

# Modificadores porcentuales actuales
# Modifica una cantidad porcentual de su actual a la actual 
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
