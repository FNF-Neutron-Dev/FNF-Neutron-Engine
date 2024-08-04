package frontend.system;

import openfl.errors.Error;
import openfl.events.ErrorEvent;
import openfl.events.UncaughtErrorEvent;

/**
 * Crash Handler class.
 * Handles uncaught errors and crashes in the application by logging and displaying them.
 * 
 * @author YoshiCrafter29, Ne_Eo and MAJigsaw77
 */
class CrashHandler
{
	/**
	 * Initialize the Crash Handler.
	 * Sets up the uncaught error event listener and critical error handler.
	 */
	public static function init():Void
	{
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onError);
		#end
	}

	/**
	 * Handles uncaught errors in the application.
	 * Prevents the default behavior and logs the error message and stack trace.
	 * 
	 * @param e The uncaught error event.
	 */
	@:dox(show)
	private static function onUncaughtError(e:UncaughtErrorEvent):Void
	{
		e.preventDefault();
		e.stopPropagation();
		e.stopImmediatePropagation();

		var m:String = e.error;
		if (Std.isOfType(e.error, Error))
		{
			var err = cast(e.error, Error);
			m = '${err.message}';
		}
		else if (Std.isOfType(e.error, ErrorEvent))
		{
			var err = cast(e.error, ErrorEvent);
			m = '${err.text}';
		}
		var stack = haxe.CallStack.exceptionStack();
		var stackLabelArr:Array<String> = [];
		var stackLabel:String = "";
		for (e in stack)
		{
			switch (e)
			{
				case CFunction:
					stackLabelArr.push("Non-Haxe (C) Function");
				case Module(c):
					stackLabelArr.push('Module ${c}');
				case FilePos(parent, file, line, col):
					switch (parent)
					{
						case Method(cla, func):
							stackLabelArr.push('${file.replace('.hx', '')}.$func() [line $line - column $col]');
						case _:
							stackLabelArr.push('${file.replace('.hx', '')} [line $line - column $col]');
					}
				case LocalFunction(v):
					stackLabelArr.push('Local Function ${v}');
				case Method(cl, m):
					stackLabelArr.push('${cl} - ${m}');
			}
		}
		stackLabel = stackLabelArr.join('\r\n');
		#if sys
		try
		{
			if (!FileSystem.exists('logs'))
				FileSystem.createDirectory('logs');

			File.saveContent('logs/' + 'Crash - ' + Date.now().toString().replace(' ', '-').replace(':', "'") + '.txt', '$m\n$stackLabel');
		}
		catch (e:haxe.Exception)
			trace('Couldn\'t save error message. (${e.message})');
		#end

		#if (android && !macro)
		android.Tools.showAlertDialog("Error!", '$m\n$stackLabel', {name: 'ok', func: null});
		#else
		FlxG.stage.window.alert('$m\n$stackLabel', "Error!");
		#end

		LimeSystem.exit(1);
	}

	/**
	 * Handles critical errors in C++.
	 * 
	 * @param message The error message.
	 */
	#if cpp
	@:dox(show)
	private static function onError(message:Dynamic):Void
	{
		throw Std.string(message);
	}
	#end
}
