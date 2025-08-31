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
		input.onchange = async () => {
			let file = input.files[0];
			let buf = await file.arrayBuffer();
			let bytes = Array.from(new Uint8Array(buf));
			
			await fileUploader.upload(bytes);
		};
		input.click();
	""");

func handle_file_upload(args: Array):
	print("It was actually called!")
	print(args);
