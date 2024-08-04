package frontend.system;

import lime.utils.Log as LimeLogger;

class Log
{
	/**
	 * Logs a warning message.
	 * @param content The content of the warning message.
	 */
	public static function warn(content:String):Void
	{
		trace('[WARNING] $content');
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
		trace('[ERROR] $content');
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
		trace('[NOTE] $content');
		#if debug
		FlxG.log.notice(content);
		#end
	}
}
