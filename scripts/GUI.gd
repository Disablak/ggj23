extends Control


@onready var label_water: Label = $LabelWater

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.on_updated_water.connect(_on_updated_water)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_updated_water(value: int):
	label_water.text = "WATER: {0}".format([value])
