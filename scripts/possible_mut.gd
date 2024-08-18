extends TabContainer

func _on_tab_selected(tab):
	get_child(tab).grab_focus()
	
