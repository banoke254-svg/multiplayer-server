extends Node3D

@onready var ui = $CanvasLayer/TutorialUI
@onready var popup = $CanvasLayer/TutorialUI/Popup
@onready var text_label = $CanvasLayer/TutorialUI/Popup/Text
@onready var next_button = $CanvasLayer/TutorialUI/Popup/NextButton
@onready var blur_bg = $CanvasLayer/TutorialUI/BlurBG

var step := 0

var steps = [
    "Welcome to the game!",
    "Drag back on the screen to aim your marble.",
    "Release to shoot.",
    "Aim carefully to hit your target.",
    "Reach the goal to win.",
    "Good luck!"
]

func _ready():
    get_tree().paused = true
    show_step()

    next_button.pressed.connect(_on_next_pressed)

func show_step():
    text_label.text = steps[step]

func _on_next_pressed():
    step += 1

    if step >= steps.size():
        end_tutorial()
    else:
        show_step()

func end_tutorial():
    blur_bg.hide()
    popup.hide()
    get_tree().paused = false