class_name ExpressionUtilityDecorator
extends UtilityDecorator

@export_multiline var expression: String = "considerations[0].value"

var _exp: Expression
func _ready() -> void:
	super()

	_exp = Expression.new()
	_exp.parse(expression, ["considerations"])

func calculate_utility() -> void:
	utility = _exp.execute([considerations])
