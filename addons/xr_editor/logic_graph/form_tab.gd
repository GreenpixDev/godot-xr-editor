@tool
@abstract
class_name XREBlueprintFormTab
extends XREPanelTab
## A window of the logic graph that is one of the panels' windows (D-044):
## [XREPanels] opens it where [XREBlueprints] asks, and it closes, pins to a
## hand and moves as the tabs' windows do. It isn't in the launcher. Its form
## is the graph service's: the tab borrows it while the window is open and
## gives it back when the window is freed, so that what is typed in it
## outlives the window.

var _service: XREBlueprints


## Takes the form of [param service] into the tab.
func setup(service: XREBlueprints) -> void:
	_service = service
	if _service == null:
		return
	var form := _form()
	if not is_instance_valid(form) or form.get_parent() == self:
		return
	if form.get_parent() != null:
		form.get_parent().remove_child(form)
	add_child(form)


## The service's form the tab shows.
@abstract func _form() -> Control


func _refresh() -> void:
	pass


func _notification(what: int) -> void:
	# Before the window's nodes are freed: the form outlives its window.
	if what != NOTIFICATION_PREDELETE or not is_instance_valid(_service):
		return
	var form := _form()
	if is_instance_valid(form) and form.get_parent() == self:
		remove_child(form)
		_service.take_back(form)
