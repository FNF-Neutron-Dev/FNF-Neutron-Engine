package backend;

import backend.assets.AssetLibrary;
import backend.assets.Paths;
import backend.input.Controls;
import backend.music.Conductor;
import frontend.system.FPSCounter;
import states.menus.TitleState;
import states.test.ConductorPrototype;
import ui.text.Alphabet;

class InitState extends flixel.FlxState
{
	override public function create():Void
	{
		super.create();

		AssetLibrary.init();
		Paths.cacheFallbackAssets();
		FlxG.plugins.addPlugin(new Controls());
		FlxG.plugins.addPlugin(new Conductor(1, true));
		Main.fpsCounter = new FPSCounter(10, 5, 0xFFFFFF);

		FlxG.signals.preStateCreate.add(state -> @:privateAccess
		{
			for (member in Alphabet.alphabetGroup.members)
				member.destroy();
			Alphabet.alphabetGroup.clear();
		});

		FlxG.signals.preStateSwitch.addOnce(() -> Main.instance.addChild(Main.fpsCounter));

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		#if CONDUCTOR_PORTOTYPE
		FlxG.switchState(new ConductorPrototype());
		#else
		FlxG.switchState(new TitleState());
		#end
	}
}
