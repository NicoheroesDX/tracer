class_name FileUploader;
extends Node;

var handler = JavaScriptBridge.create_callback(handle_file_upload);

func upload_file():
	JavaScriptBridge.eval("""
		var fileUploader = {
			on_upload: null,
			set_handler: (handler) => this.on_upload = handler,
			upload: (data) => this.on_upload(JSON.stringify(data)),
		};
	""", true);
	
	var file_uploader = JavaScriptBridge.get_interface("fileUploader");
	file_uploader.set_handler(handler);
	
	JavaScriptBridge.eval("""
		let input = document.createElement('input');
		input.type = 'file';
		input.accept = '.trsg';
		input.onchange = async () => {
			let file = input.files[0];
			let buf = await file.arrayBuffer();
			let bytes = Array.from(new Uint8Array(buf));
			
			await fileUploader.upload(bytes);
		};
		input.click();
	""");

func handle_file_upload(args: Array):
	print("We start now!");
	
	if args.size() != 1:
		print("ERROR: Something went wrong while uploading the file");
		return;
	
	var uploaded_content: String = args[0];
	uploaded_content = uploaded_content.strip_edges();
	uploaded_content = uploaded_content.substr(1, uploaded_content.length() - 2);
	
	var uploaded_byte_strings = uploaded_content.split(",");
	
	var uploaded_bytes = PackedByteArray();
	
	for byte_string in uploaded_byte_strings:
		byte_string.strip_edges();
		var as_number = int(byte_string);
		uploaded_bytes.append(as_number);
	
	print("My bytes:")
	print(uploaded_bytes.size())
	
	var save_game_directory := DirAccess.open(Global.SAVE_GAME_FOLDER);
	if not save_game_directory.dir_exists(Global.TEMP_FOLDER):
		var err = save_game_directory.make_dir(Global.TEMP_FOLDER);
		if err != OK:
			print("ERROR: Failed to create folder");
			return false;
	
	var temp_file_name = Global.TEMP_FOLDER + "upload";
	var temp_file: FileAccess = FileAccess.open(temp_file_name, FileAccess.WRITE);
	temp_file.store_buffer(uploaded_bytes);
	temp_file.close();
	
	var target_highscore_file: FileAccess = FileAccess.open(Global.SAVE_GAME_FOLDER + Global.TARGET_FILE_NAME, FileAccess.WRITE);
	var target_ghost_file = FileAccess.open(Global.SAVE_GAME_FOLDER + Global.SAVED_TARGET_GHOST_FILE_NAME, FileAccess.WRITE);
	
	var separator_line_detected: bool = false;
	
	temp_file = FileAccess.open(temp_file_name, FileAccess.READ);
	
	print(temp_file.get_length())
	print(temp_file.eof_reached())
	
	while not temp_file.eof_reached():
		var next_line: String = temp_file.get_line();
		if (next_line.begins_with(Global.TRSG_SEPARATOR_LINE)):
			separator_line_detected = true;
			continue;
		if not separator_line_detected:
			target_highscore_file.store_line(next_line);
		else:
			target_ghost_file.store_line(next_line);
	
	temp_file.close();
	target_highscore_file.close();
	target_ghost_file.close();
	print("INFO: Successfully uploaded!");
	Global.change_scene_with_transition("res://src/gui/menu/MainMenu.tscn")
