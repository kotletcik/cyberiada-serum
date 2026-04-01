#Chcemy kolizję i ten obiekt nie będzie się prouszał, więc dzieciczymy po StaticBody3D
extends StaticBody3D

var audio: AudioStreamPlayer3D;
var mp3: Resource;

#bierzemy instancję node AudioStreamPlayer3D ze sceny, ten skrypt jest przyczepiony do Sound Test w Sanuuu's Scene
func _ready() -> void:
	audio = get_node("AudioTest");

# funkcja która jest wywoływana w naszym skrypcie player_interactions. 
# GDScript jest interpretowany więc można wywołać funkcję has_method("player_interact") i ją wywołać poprostu.
# Wyjaśniam ci tym poporstu jak to działa, ty możesz dopisac player_interact do każdego obiektu z kolizją i gracz ją wywoła przy interakcji
func player_interact() -> void:
	audio.play();
