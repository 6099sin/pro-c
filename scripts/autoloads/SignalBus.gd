extends Node

# Autoload: SignalBus

signal score_updated_total(new_score: int)
signal score_updated_alpha(new_score: int)
signal score_updated_beta(new_score: int)
signal time_updated(time_left: float)
signal game_over(final_score: int, grade: String)
signal request_sfx(sfx_name: String)
signal bonus_event(is_active: bool)
