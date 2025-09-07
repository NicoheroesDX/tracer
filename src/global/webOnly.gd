class_name WebOnly;
extends Node;

static func setup_device_rotation():
	JavaScriptBridge.eval("""
		window.gyro_alpha = 1;
		window.gyro_beta = 2;
		window.gyro_gamma = 3;
		window.addEventListener('deviceorientation', function(e) {
			window.gyro_alpha = e.alpha;
			window.gyro_beta = e.beta;
			window.gyro_gamma = e.gamma;
		});
	""", true);

static func get_device_rotation() -> float:
	if not Global.is_using_gyroscope:
		return 0.0;
	
	var orientation = DisplayServer.screen_get_orientation();
	var alpha_rotation = JavaScriptBridge.eval("window.gyro_alpha", true);
	var beta_rotation = JavaScriptBridge.eval("window.gyro_beta", true);
	
	if alpha_rotation == null or beta_rotation == null:
		return 0.0;
	
	const landscape_orientations = [
		DisplayServer.SCREEN_LANDSCAPE,
		DisplayServer.SCREEN_REVERSE_LANDSCAPE,
		DisplayServer.SCREEN_SENSOR_LANDSCAPE
	]
	
	const portrait_orientations = [
		DisplayServer.SCREEN_PORTRAIT,
		DisplayServer.SCREEN_REVERSE_PORTRAIT,
		DisplayServer.SCREEN_SENSOR_PORTRAIT
	]
	
	if orientation in landscape_orientations:
		return beta_rotation;
	elif orientation in portrait_orientations:
		return beta_rotation;
	else:
		return 0.0;

static func upload_file():
	var uploader = FileUploader.new();
	uploader.upload_file();

static func download_file(file_name: String, file_content: PackedByteArray):
	var downloader = FileDownloader.new();
	downloader.download_file(file_name, file_content);
