package;

import debug.FPSCounter;
import flixel.FlxGame;
import openfl.display.Sprite;
import backend.assets.Paths;
import frontend.system.CrashHandler;

class Main extends Sprite
{
	public static var fpsCounter:FPSCounter;

	public function new():Void
	{
		#if mobile
		#if android
		StorageUtil.doPermissionsShit();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end
		super();
		CrashHandler.init();
		Paths.init();
		addChild(new FlxGame(1280, 720, #if CONDUCTOR_PORTOTYPE ConductorPrototype #else PlayState #end));
		fpsCounter = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsCounter);

		FlxG.signals.gameResized.add(function (w, h) {
			if(fpsCounter != null)
				fpsCounter.positionFPS(10, 3, Math.min(w / FlxG.width, h / FlxG.height));
		});
	}
}
