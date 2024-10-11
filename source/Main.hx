package;

import backend.assets.AssetLibrary;
import backend.assets.Paths;
import flixel.FlxGame;
import frontend.system.CrashHandler;
import frontend.system.FPSCounter;
import openfl.display.Sprite;
import states.menus.TitleState;
import states.test.ConductorPrototype;
import ui.text.Alphabet;

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
		AssetLibrary.init();
		Paths.cacheFallbackAssets();

		addChild(new FlxGame(1280, 720, #if CONDUCTOR_PORTOTYPE ConductorPrototype #else TitleState #end));
		addChild(fpsCounter = new FPSCounter(10, 5, 0xFFFFFF));

		FlxG.signals.preStateCreate.add(state -> @:privateAccess
		{
			for (member in Alphabet.alphabetGroup.members)
				member.destroy();
			Alphabet.alphabetGroup.clear();
		});

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end
	}
}
