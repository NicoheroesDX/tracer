class_name WebOnly;
extends Node;

static func download_file(file_name: String, file_content: PackedByteArray):
	var sanitized_file_name = file_name.replace("'", "\\'")
	var u_int_8_array_string = "";
	
	for i in file_content.size():
		u_int_8_array_string += str(file_content[i]);
		if (i < file_content.size() - 1):
			u_int_8_array_string += ",";
	
	JavaScriptBridge.eval("""
		const bytes = new Uint8Array([""" + u_int_8_array_string + """]);
		const blob = new Blob([bytes], {type: 'application/zip'});
		const a = document.createElement('a');
		a.href = URL.createObjectURL(blob);
		a.download = """ + sanitized_file_name + """;
		a.click();
		URL.revokeObjectURL(a.href);
	""");
