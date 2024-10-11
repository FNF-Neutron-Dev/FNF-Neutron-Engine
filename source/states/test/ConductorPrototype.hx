package states.test;

import backend.assets.AssetLibrary;
import backend.assets.Paths;
import backend.music.Conductor;
import flixel.FlxState;
import ui.text.Alphabet;

class ConductorPrototype extends FlxState
{
	public var conductor:Conductor;
	public var tickSound:FlxSound;
	public var alphabet:Alphabet;

	override public function create():Void
	{
		tickSound = Paths.sound('Tick');
		FlxG.sound.playMusic(Paths.getSound("Game", backend.assets.AssetLibrary.MUSIC));
		conductor = new Conductor(141);
		conductor.onBeatHit.add((beat:Int) ->
		{
			tickSound.play();
			trace('New beat hit! - $beat');
		});
		conductor.running = true;
		add(conductor);

		bgColor = FlxColor.GRAY;

		alphabet = new Alphabet(0, 0, 'Hello World!\nHello Lily!', false, CENTER);
		add(alphabet);
		alphabet.screenCenter();
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
