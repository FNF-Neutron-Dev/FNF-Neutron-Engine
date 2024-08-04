package frontend.system;

import flixel.FlxG;
import lime.system.System as LimeSystem;
import openfl.system.System as OpenFlSystem;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * The FPS class provides an easy-to-use monitor to display the current frame rate of an OpenFL project.
 * Mostly a fork of psych engine's FPSCounter.
 */
#if cpp
#if windows
@:cppFileCode('#include <windows.h>')
#elseif (ios || mac)
@:cppFileCode('#include <mach-o/arch.h>')
#elseif (linux || android || wasm)
@:headerInclude('sys/utsname.h')
#end
#end
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;

	@:noCompletion private var times:Array<Float>;

	public var os:String = '';

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		if (LimeSystem.platformName == LimeSystem.platformVersion || LimeSystem.platformVersion == null)
			os = 'OS: ${LimeSystem.platformName}' #if cpp + ' ${getArch()}' #end;
		else
			os = 'OS: ${LimeSystem.platformName}' #if cpp + ' ${getArch()}' #end + ' - ${LimeSystem.platformVersion}';

		positionFPS(x, y);

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		width = FlxG.width / 4;
		height = FlxG.height / 4;
		multiline = true;
		text = "FPS: -1\nMemory: 1TB\nOS: Toaster";

		times = [];
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		// prevents the overlay from updating every frame, why would you need to anyways
		if (deltaTimeout > 1000)
		{
			deltaTimeout = 0.0;
			return;
		}

		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
		updateText();
		deltaTimeout += deltaTime;
	}

	public dynamic function updateText():Void
	{
		text = 'FPS: $currentFPS\nMemory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}\n$os';

		if (currentFPS < FlxG.drawFramerate / 1.5)
			textColor = 0xFFFFEA00;
		else if (currentFPS < FlxG.drawFramerate / 2)
			textColor = 0xFFFF0000;
		else
			textColor = 0xFFFFFFFF;
	}

	inline function get_memoryMegas():Float
	{
		#if cpp
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
		#else
		return cast(OpenFlSystem.totalMemory, UInt);
		#end
	}

	public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1)
	{
		scaleX = scaleY = #if mobile (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
		x = FlxG.game.x + X;
		y = FlxG.game.y + Y;
	}

	#if cpp
	#if windows
	@:functionCode('
		SYSTEM_INFO osInfo;

		GetSystemInfo(&osInfo);

		switch(osInfo.wProcessorArchitecture)
		{
			case 0:
				return ::String("x86");
			case 5:
				return ::String("ARM");
			case 6:
				return ::String("IA-64");
			case 9:
				return ::String("x86_64");
			case 12:
				return ::String("ARM64");
			default:
				return ::String("Unknown");
		}
	')
	#elseif (ios || mac)
	@:functionCode('
		const NXArchInfo *archInfo = NXGetLocalArchInfo();
    	return ::String(archInfo == NULL ? "Unknown" : archInfo->name);
	')
	#elseif (linux || android || wasm) // idk if this work on wasm
	@:functionCode('
		struct utsname osInfo{};
		uname(&osInfo);
		return ::String(osInfo.machine);
	')
	#end
	@:noCompletion
	private function getArch():String
	{
		return null;
	}
	#end
}
