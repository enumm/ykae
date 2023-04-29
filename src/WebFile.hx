import haxe.io.BytesData;

@:native("webFile")
extern class WebFile {
	static function SelectFile():Void;
	static function AddFileSelectedListener(listener:(content:String) -> Void):Void;
	static function SaveFile(content:String):Void;
}
