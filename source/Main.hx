package;

import backend.assets.Paths;
import flixel.FlxGame;
import frontend.system.CrashHandler;
import frontend.system.FPSCounter;
import openfl.display.Sprite;
import states.menus.TitleState;
import states.test.ConductorPrototype;
import ui.text.Alphabet.AlphaCharacter;

class Main extends Sprite
{
	public static var fpsCounter:FPSCounter;

	public function new():Void
	{
		super();

		#if mobile
		// #if android
		// StorageUtil.doPermissionsShit();
		// #end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end
		CrashHandler.init();
		#if cpp
		cpp.vm.Gc.enable(true);
		#end
		Paths.setFallbackCache();
		AlphaCharacter.loadAlphabetData();


		addChild(new FlxGame(1280, 720, #if CONDUCTOR_PORTOTYPE ConductorPrototype #else TitleState #end));
		addChild(fpsCounter = new FPSCounter(10, 5, 0xFFFFFF));

		FlxG.signals.gameResized.add(function(width:Int, height:Int)
		{
			if (fpsCounter != null)
				fpsCounter.positionFPS(10, 5, Math.min(width / FlxG.width, height / FlxG.height));
		});
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end
	}
}
