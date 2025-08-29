class_name WebOnly;
extends Node;

const JS_FUNCTION_DOWNLOAD_ZIP_FILE = """
	(function() {
		const base64 = '$base64_content';
		const binary_string = atob(base64);
		const len = binary_string.length;
		const bytes = new Uint8Array(len);
		for (let i = 0; i < len; i++) {
			bytes[i] = binary_string.charCodeAt(i);
		}
		const blob = new Blob([bytes], {type: 'application/zip'});
		const a = document.createElement('a');
		a.href = URL.createObjectURL(blob);
		a.download = '$santized_file_name';
		a.click();
		URL.revokeObjectURL(a.href);
	})();
"""

static func download_file(file_name: String, file_content: PackedByteArray):
	# Must match '$base64_content' in JS_FUNCTION_DOWNLOAD_ZIP_FILE
	var base64_content = Marshalls.raw_to_base64(file_content);
	
	# Must match '$santized_file_name' in JS_FUNCTION_DOWNLOAD_ZIP_FILE
	var santized_file_name = file_name.replace("'", "\\'");
	
	JavaScriptBridge.eval(JS_FUNCTION_DOWNLOAD_ZIP_FILE);
