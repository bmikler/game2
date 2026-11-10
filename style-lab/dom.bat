@echo off
rem PROTOTYP: Poligon Dom w brylach (parter i pietro). Wejscie z ulicy: ulica.bat. F1: szerokosc i glebia wnetrza, sciany z ramkami/bez, okna dolne i boczne (S0/S1/K), drzwi, widok, poludnie, lampy.
start "" "C:\Users\bartl\Desktop\repo\game1\tools\godot\Godot_v4.7.2-stable_win64.exe" --path "%~dp0." -- --scene=res://poligony/dom_parter.tscn --spawn=z_ulicy
