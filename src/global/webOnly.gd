class_name WebOnly;
extends Node;

const JS_FUNCTION_DOWNLOAD_ZIP_FILE = """
	const bytes = new Uint8Array([%s]);
	const blob = new Blob([bytes], {type: 'application/zip'});
	const a = document.createElement('a');
	a.href = URL.createObjectURL(blob);
	a.download = '%s';
	a.click();
	URL.revokeObjectURL(a.href);
"""

static func download_file(file_name: String, file_content: PackedByteArray):
	var sanitized_file_name = file_name.replace("'", "\\'")
	var u_int_8_array_string = "";
	
	for i in file_content.size():
		u_int_8_array_string += str(file_content[i]);
		if (i < file_content.size() - 1):
			u_int_8_array_string += ",";
	
	JavaScriptBridge.eval(JS_FUNCTION_DOWNLOAD_ZIP_FILE.format([u_int_8_array_string, sanitized_file_name]));
