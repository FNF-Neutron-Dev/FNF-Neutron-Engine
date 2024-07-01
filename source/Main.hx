package;

import states.menus.TitleState;
import openfl.display.Sprite;
import backend.assets.Paths;
import frontend.system.CrashHandler;
import frontend.system.FPSCounter;
import ui.text.Alphabet.AlphaCharacter;
import flixel.FlxGame;

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
		AlphaCharacter.loadAlphabetData();

		addChild(new FlxGame(1280, 720, #if CONDUCTOR_PORTOTYPE ConductorPrototype #else TitleState #end));
		addChild(fpsCounter = new FPSCounter(10, 5, 0xFFFFFF));

		FlxG.signals.gameResized.add(function (w, h) {
			if(fpsCounter != null)
				fpsCounter.positionFPS(10, 5, Math.min(w / FlxG.width, h / FlxG.height));
		});
	}
}
