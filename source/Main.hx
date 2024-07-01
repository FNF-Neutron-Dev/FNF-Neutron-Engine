package;

import flixel.FlxGame;
import openfl.display.Sprite;
import backend.assets.Paths;
import frontend.system.CrashHandler;
import debug.FPSCounter;

class Main extends Sprite
{
	public static var fpsCounter:FPSCounter;

	public function new():Void
	{
		super();
		#if mobile
		#if android
		StorageUtil.doPermissionsShit();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end
		CrashHandler.init();
		Paths.init();
		addChild(new FlxGame(1280, 720, #if CONDUCTOR_PORTOTYPE ConductorPrototype #else PlayState #end));
	}
}
