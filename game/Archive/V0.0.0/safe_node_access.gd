class_name SafeNodeAccess
extends RefCounted

## Helper functions for safe node operations throughout the codebase
## Prevents null reference crashes by checking before accessing nodes

# Get node with warning if not found
static func get_or_warn(root: Node, path: String, context: String = "") -> Node:
	if not root:
		DebugLogger.warn("Root node is null for path: " + path, "SafeNodeAccess")
		return null

	if not root.has_node(path):
		var ctx = context if context != "" else "UnknownContext"
		DebugLogger.warn("Node not found: " + path + " in " + ctx, "SafeNodeAccess")
		return null

	return root.get_node_or_null(path)

# Get node or use fallback
static func get_or_fallback(root: Node, path: String, fallback: Node = null) -> Node:
	if not root or not root.has_node(path):
		return fallback

	return root.get_node_or_null(path)

# Safely call method on node if it exists
static func safe_call_method(node: Node, method_name: String, args: Array = []) -> Variant:
	if not node:
		return null

	if not node.has_method(method_name):
		DebugLogger.warn("Method %s not found on node %s" % [method_name, node.name], "SafeNodeAccess")
		return null

	return node.callv(method_name, args)

# Safe label update (won't crash if null)
static func safe_update_label(label: Label, text: String) -> void:
	if label:
		label.text = text
	else:
		DebugLogger.warn("Tried to update null label", "SafeNodeAccess")

# Safe progress bar update (clamped to valid range)
static func safe_update_progress_bar(bar: ProgressBar, value: float) -> void:
	if bar:
		bar.value = clamp(value, bar.min_value, bar.max_value)
	else:
		DebugLogger.warn("Tried to update null progress bar", "SafeNodeAccess")
