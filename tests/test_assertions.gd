extends Node
## test_assertions.gd
## Assertion framework for headless testing

class_name TestAssertions

static func assert_equal(actual, expected, message: String = ""):
	if actual != expected:
		var error = "Assertion failed: Expected %s but got %s" % [expected, actual]
		if message:
			error += " (%s)" % message
		push_error(error)
		assert(false, error)

static func assert_true(condition: bool, message: String = ""):
	if not condition:
		var error = "Assertion failed: Expected true but got false"
		if message:
			error += " (%s)" % message
		push_error(error)
		assert(false, error)

static func assert_false(condition: bool, message: String = ""):
	if condition:
		var error = "Assertion failed: Expected false but got true"
		if message:
			error += " (%s)" % message
		push_error(error)
		assert(false, error)

static func assert_approx(actual: float, expected: float, epsilon: float = 0.01, message: String = ""):
	if abs(actual - expected) > epsilon:
		var error = "Assertion failed: Expected ~%f but got %f (epsilon: %f)" % [expected, actual, epsilon]
		if message:
			error += " (%s)" % message
		push_error(error)
		assert(false, error)

static func assert_greater(actual, expected, message: String = ""):
	if actual <= expected:
		var error = "Assertion failed: Expected %s > %s" % [actual, expected]
		if message:
			error += " (%s)" % message
		push_error(error)
		assert(false, error)

static func assert_greater_or_equal(actual, expected, message: String = ""):
	if actual < expected:
		var error = "Assertion failed: Expected %s >= %s" % [actual, expected]
		if message:
			error += " (%s)" % message
		push_error(error)
		assert(false, error)

static func assert_less(actual, expected, message: String = ""):
	if actual >= expected:
		var error = "Assertion failed: Expected %s < %s" % [actual, expected]
		if message:
			error += " (%s)" % message
		push_error(error)
		assert(false, error)

static func assert_less_or_equal(actual, expected, message: String = ""):
	if actual > expected:
		var error = "Assertion failed: Expected %s <= %s" % [actual, expected]
		if message:
			error += " (%s)" % message
		push_error(error)
		assert(false, error)

static func assert_not_null(value, message: String = ""):
	if value == null:
		var error = "Assertion failed: Expected non-null value"
		if message:
			error += " (%s)" % message
		push_error(error)
		assert(false, error)

static func assert_null(value, message: String = ""):
	if value != null:
		var error = "Assertion failed: Expected null but got %s" % value
		if message:
			error += " (%s)" % message
		push_error(error)
		assert(false, error)
