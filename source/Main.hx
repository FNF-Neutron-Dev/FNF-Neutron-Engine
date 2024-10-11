package;

import backend.InitState;
import flixel.FlxGame;
import frontend.system.FPSCounter;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var fpsCounter:FPSCounter;
	public static var instance:Main;

	public function new():Void
	{
		super();

		#if mobile
		// #if android
		// StorageUtil.doPermissionsShit();
		// #end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end
		#if cpp
		cpp.vm.Gc.enable(true);
		#end

		addChild(new FlxGame(1280, 720, InitState));

		instance = this;
	}

	public static function alertDialog(message:String, title:String)
	{
		#if (android && !macro)
		android.Tools.showAlertDialog(title, message, {name: 'OK', func: null});
		#else
		FlxG.stage.window.alert(message, title);
		#end
	}
}
