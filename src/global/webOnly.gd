class_name WebOnly;
extends Node;

static func setup_device_rotation():
	JavaScriptBridge.eval("""
		window.gyro_alpha = 0;
		window.gyro_beta = 0;
		window.gyro_gamma = 0;
		window.addEventListener('deviceorientation', function(e) {
			window.game_steering = e.alpha;
			window.game_steering = e.beta;
			window.game_steering = e.gamma;
		});
	""", true);

static func get_device_rotation_text() -> String:
	var alpha_rotation = 0.0;
	var result_rotation = JavaScriptBridge.eval("window.gyro_alpha;", true);
	if (result_rotation != null):
		alpha_rotation = result_rotation;
		
	var beta_rotation = 0.0;
	result_rotation = JavaScriptBridge.eval("window.gyro_beta;", true);
	if (result_rotation != null):
		beta_rotation = result_rotation;
		
	var gamma_rotation = 0.0;
	result_rotation = JavaScriptBridge.eval("window.gyro_gamma;", true);
	if (result_rotation != null):
		gamma_rotation = result_rotation;
	
	return "A:" + str(alpha_rotation) + "     B:" + str(beta_rotation) + "     Y:" + str(gamma_rotation)

static func upload_file():
	var uploader = FileUploader.new();
	uploader.upload_file();

static func download_file(file_name: String, file_content: PackedByteArray):
	var downloader = FileDownloader.new();
	downloader.download_file(file_name, file_content);
