extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUIEmpty = $HeartUIEmpty
onready var heartUiFull = $HeartUIFull

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUiFull != null:
		heartUiFull.rect_size.x = hearts * 15

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts) # don't know that this is needed?
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = hearts * 15

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	# warning-ignore:return_value_discarded
	PlayerStats.connect("health_change", self, "set_hearts")
	# warning-ignore:return_value_discarded
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
