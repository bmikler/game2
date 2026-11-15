class_name TuningSet
extends Resource
## A tuning set: look constants that do not depend on the hour (A′ stylisation, penumbra, receivers,
## light shafts, window patches, dust). A Location picks one in its LocationEnvironment. The fields
## arrive with later parts of the engine; for now a set only has a label.

@export var label: String = ""
