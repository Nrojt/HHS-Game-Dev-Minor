extends Node

# Input remapping, signal would not work here, sine signal order is not guaranteed, which can cause multiple input buttons to be pressed at the same time or other bugs
var is_remapping: bool = false
var input_type: CreatedEnums.InputType
var action_to_remap: String = ""
