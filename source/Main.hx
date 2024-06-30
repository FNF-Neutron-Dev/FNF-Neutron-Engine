package;

import flixel.FlxGame;
import openfl.display.Sprite;
import backend.assets.Paths;
import frontend.system.CrashHandler;

class Main extends Sprite
{
	public function new()
	{
		super();
		Paths.init();
		CrashHandler.init();
		addChild(new FlxGame(1280, 720, #if CONDUCTOR_PORTOTYPE ConductorPrototype #else PlayState #end));
	}
}
