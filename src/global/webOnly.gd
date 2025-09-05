class_name WebOnly;
extends Node;

static func setup_device_rotation():
	JavaScriptBridge.eval("""
		window.game_steering = 0;
		window.addEventListener('deviceorientation', function(e) {
			window.game_steering = e.gamma;
		});
	""", true);

static func get_device_rotation() -> float:
	var device_rotation = 0.0;
	var result_rotation = JavaScriptBridge.eval("window.game_steering;", true);
	if (result_rotation != null):
		device_rotation = result_rotation;
	
	return device_rotation;

static func upload_file():
	var uploader = FileUploader.new();
	uploader.upload_file();

static func download_file(file_name: String, file_content: PackedByteArray):
	var downloader = FileDownloader.new();
	downloader.download_file(file_name, file_content);
