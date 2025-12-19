extends Node

# Autoload: SignalBus

signal score_updated(new_score: int)
signal time_updated(time_left: float)
signal game_over(final_score: int, grade: String)
signal request_sfx(sfx_name: String)
