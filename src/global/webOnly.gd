class_name WebOnly;
extends Node;

const JS_FUNCTION_DOWNLOAD_ZIP_FILE = """
	window.godotFunctionDownloadZipFile = function(fileName, bytes) {
		const blob = new Blob([bytes], { type: 'application/zip' });
		const a = document.createElement('a');
		a.href = URL.createObjectURL(blob);
		a.download = fileName;
		a.click();
		URL.revokeObjectURL(a.href);
	};
"""

static func initialize_java_script_functions():
	JavaScriptBridge.eval(JS_FUNCTION_DOWNLOAD_ZIP_FILE);

static func download_file(file_name: String, file_content: PackedByteArray):
	JavaScriptBridge.call("godotFunctionDownloadZipFile", file_name, file_content);
