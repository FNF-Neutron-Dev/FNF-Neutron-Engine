package frontend.system;

import lime.utils.Log as LimeLogger;

class Log
{
	/**
	 * Print a message to the console.
	 * @param message 
	 */
	public static function print(message:String):Void
	{
		#if js
		if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(message);
		#elseif lua
		untyped __define_feature__("use._hx_print", _hx_print(message));
		#elseif sys
		Sys.println(message);
		#else
		throw new haxe.exceptions.NotImplementedException()
		#end
	}

	/**
	 * Logs a warning message.
	 * @param content The content of the warning message.
	 */
	public static function warn(content:String):Void
	{
		print('[WARNING] $content');
		#if debug
		FlxG.log.warn(content);
		#end
	}

	/**
	 * Logs a error message.
	 * @param content The content of the error.
	 */
	public static function error(content:String):Void
	{
		print('[ERROR] $content');
		#if debug
		FlxG.log.error(content);
		#end
	}

	/**
	 * Logs a note.
	 * @param content The content of the note.
	 */
	public static function note(content:String):Void
	{
		print('[NOTE] $content');
		#if debug
		FlxG.log.notice(content);
		#end
	}
}
