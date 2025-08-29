class_name WebOnly;
extends Node;

const JS_FUNCTION_DOWNLOAD_ZIP_FILE = """
	(function() {
		const bytes = Uint8Array.from(atob('%s'), c => c.charCodeAt(0));
		const blob = new Blob([bytes], {type: 'application/zip'});
		const a = document.createElement('a');
		a.href = URL.createObjectURL(blob);
		a.download = '%s';
		a.click();
		URL.revokeObjectURL(a.href);
	})();
"""

static func download_file(file_name: String, file_content: PackedByteArray):
	var sanitized_file_name = file_name.replace("'", "\\'")
	var base64_file_content = Marshalls.raw_to_base64(file_content).replace("\n", "");
	
	JavaScriptBridge.eval(JS_FUNCTION_DOWNLOAD_ZIP_FILE.format(sanitized_file_name, base64_file_content));
