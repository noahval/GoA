extends Control

var minimum_display_time = 3.0  # seconds
var elapsed_time = 0.0

func _ready():
	# For web builds, we need to use JavaScript to play HTML5 video
	if OS.has_feature("web"):
		_setup_web_video()
	else:
		# Desktop/mobile builds can use VideoStreamPlayer
		if has_node("VideoStreamPlayer"):
			var video_player = $VideoStreamPlayer
			video_player.play()

func _setup_web_video():
	# Use JavaScript to create and play an HTML5 video element
	if OS.has_feature("web"):
		JavaScriptBridge.eval("""
			var video = document.createElement('video');
			video.src = 'title.webm';
			video.loop = true;
			video.autoplay = true;
			video.muted = false;
			video.style.position = 'absolute';
			video.style.top = '0';
			video.style.left = '0';
			video.style.width = '100%';
			video.style.height = '100%';
			video.style.objectFit = 'contain';
			video.style.zIndex = '1000';
			video.id = 'loading-video';
			document.body.appendChild(video);
			video.play();
		""", true)

func _process(delta):
	elapsed_time += delta
	if elapsed_time >= minimum_display_time:
		# Remove the HTML5 video if on web
		if OS.has_feature("web"):
			JavaScriptBridge.eval("""
				var video = document.getElementById('loading-video');
				if (video) video.remove();
			""", true)
		# Transition to the main scene
		get_tree().change_scene_to_file("res://level1/furnace.tscn")
