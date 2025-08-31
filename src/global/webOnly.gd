class_name WebOnly;
extends Node;

static func upload_file():
	var result = JavaScriptBridge.eval("""
		(function(){
			let input = document.createElement('input');
			input.type = 'file';
			input.onchange = async () => {
				let file = input.files[0];
				let buf = await file.arrayBuffer();
				let bytes = Array.from(new Uint8Array(buf));
				
				return "testA";
			};
			input.click();
			return "testB";
		})()
	""");
	
	print(result);

static func download_file(file_name: String, file_content: PackedByteArray):
	var sanitized_file_name = file_name.replace("'", "\\'")
	var file_content_as_string = concat_to_string(file_content);
	
	JavaScriptBridge.eval("""
		const bytes = new Uint8Array([""" + file_content_as_string + """]);
		const blob = new Blob([bytes], {type: 'application/zip'});
		const a = document.createElement('a');
		a.href = URL.createObjectURL(blob);
		a.download = '""" + sanitized_file_name + """';
		a.click();
		URL.revokeObjectURL(a.href);
	""");

static func concat_to_string(byte_array: PackedByteArray):
	var result = "";
	
	for i in byte_array.size():
		result += str(byte_array[i]);
		if (i < byte_array.size() - 1):
			result += ",";
	
	return result;
