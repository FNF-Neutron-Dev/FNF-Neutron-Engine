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
		untyped __global__.__hxcpp_set_critical_error_handler(onCriticalError);
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
							stackLabelArr.push('${file.replace('.hx', '')}.$func() [line $line]');
						case _:
							stackLabelArr.push('${file.replace('.hx', '')} [line $line]');
					}
				case LocalFunction(v):
					stackLabelArr.push('Local Function ${v}');
				case Method(cl, m):
					stackLabelArr.push('${cl} - ${m}');
			}
		}
		stackLabel = stackLabelArr.join('\r\n');

		#if sys
		saveErrorMessage('$m\n$stackLabel');
		#end

		Main.alertDialog('$m\n$stackLabel', 'Error!');
		LimeSystem.exit(1);
	}

	#if cpp
	/**
	 * Handles critical errors in C++.
	 * 
	 * @param message The error message.
	 */
	@:dox(show)
	@:noCompletion
	private static function onCriticalError(message:String):Void
	{
		final log:Array<String> = [];

		if (message != null && message.length > 0)
			log.push(message);

		log.push(haxe.CallStack.toString(haxe.CallStack.exceptionStack(true)));

		#if sys
		saveErrorMessage(log.join('\n'), true);
		#end

		Main.alertDialog(log.join('\n'), 'Critical Error');
		LimeSystem.exit(1);
	}
	#end

	#if sys
	@:dox(hide)
	private static function saveErrorMessage(message:String, ?criticalMessge:Bool = false):Void
	{
		try
		{
			if (!FileSystem.exists('logs'))
				FileSystem.createDirectory('logs');

			File.saveContent('logs/'
				+ '${criticalMessge ? 'Critical Error' : 'Error'} - '
				+ Date.now().toString().replace(' ', '-').replace(':', "'")
				+ '.txt', message);
		}
		catch (e:haxe.Exception)
		{
			NeutronLogger.warn('Couldn\'t save error message. (${e.message})');
		}
	}
	#end
}
