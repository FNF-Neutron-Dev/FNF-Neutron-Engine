package;

import ui.text.Alphabet.AlphaCharacter;
import states.menus.TitleState;
import flixel.FlxGame;
import openfl.display.Sprite;
import backend.assets.Paths;
import frontend.system.CrashHandler;

class Main extends Sprite
{
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
		AlphaCharacter.loadAlphabetData();

		addChild(new FlxGame(1280, 720, #if CONDUCTOR_PORTOTYPE ConductorPrototype #else TitleState #end));
	}
}
