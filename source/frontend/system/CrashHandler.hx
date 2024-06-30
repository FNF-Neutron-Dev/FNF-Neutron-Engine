package frontend.system;

import haxe.CallStack;
import lime.system.System as LimeSystem;
import lime.utils.Log as LimeLogger;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if android
import android.widget.Toast;
#end

using StringTools;

class CrashHandler
{

	/**
	 * Uncaught error handler, original made by: Sqirra-RNG and YoshiCrafter29
	 */
    @:allow(Main)
	private static function init():Void
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
	}

	private static function onError(error:UncaughtErrorEvent):Void
	{
		final log:Array<String> = [error.error];

		for (item in CallStack.exceptionStack(true))
		{
			switch (item)
			{
				case CFunction:
					log.push('C Function');
				case Module(m):
					log.push('Module [$m]');
				case FilePos(s, file, line, column):
					log.push('$file [line: $line - column: $column]');
				case Method(classname, method):
					log.push('$classname [method $method]');
				case LocalFunction(name):
					log.push('Local Function [$name]');
			}
		}

		final msg:String = log.join('\n');

		#if sys
		try
		{
			if (!FileSystem.exists('logs'))
				FileSystem.createDirectory('logs');

			File.saveContent('logs/' + Date.now().toString().replace(' ', '-').replace(':', "'") + '.txt', msg + '\n');
		}
		catch (e:Dynamic)
		{
			#if android
			Toast.makeText("Error!\nFailed to save the crash dump!\n" + e, Toast.LENGTH_LONG);
			#else
			LimeLogger.println("Error!\nFailed to save the crash dump!:\n" + e);
			#end
		}
		#end

		showPopUp(msg, "Call Stack Error!");

		#if js
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		js.Browser.window.location.reload(true);
		#else
		LimeSystem.exit(1);
		#end
	}

	/**
	 * This is mostly a fork of https://github.com/openfl/hxp/blob/master/src/hxp/System.hx#L595
	 */
	#if sys
	public static function mkDirs(directory:String):Void
	{
		var total:String = '';
		if (directory.substr(0, 1) == '/')
			total = '/';

		var parts:Array<String> = directory.split('/');
		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part != '')
			{
				if (total != '' && total != '/')
					total += '/';

				total += part;

				if (!FileSystem.exists(total))
					FileSystem.createDirectory(total);
			}
		}
	}

	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json', fileData:String = 'you forgot to add something in your code lol'):Void
	{
		try
		{
			if (!FileSystem.exists('saves'))
				FileSystem.createDirectory('saves');

			File.saveContent('saves/' + fileName + fileExtension, fileData);
			showPopUp(fileName + " file has been saved", "Success!");
		}
		catch (e:Dynamic)
		{
			#if android
			Toast.makeText("Error!\nFailed to save the file:\n" + e, Toast.LENGTH_LONG);
			#else
			LimeLogger.println("Error!\nFailed to save the file because:\n" + e);
			#end
		}
	}
	#end

	public static function showPopUp(message:String, title:String):Void
	{
		#if (windows || android || js || wasm || linux)
		Lib.application.window.alert(message, title);
		#else
		LimeLogger.println('$title - $message');
		#end
	}
}
