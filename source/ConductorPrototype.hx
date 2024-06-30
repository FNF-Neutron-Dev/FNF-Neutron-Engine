package;

import flixel.FlxState;
import backend.music.BPMConductor;
import backend.assets.Paths;

class ConductorPrototype extends FlxState
{
	public var conductor:BPMConductor;
    public var tickSound:FlxSound;

	override public function create():Void
	{
        tickSound = Paths.sound('Tick');
		FlxG.sound.playMusic(Paths.getSound("Game", MUSIC));
		conductor = new BPMConductor(141);
		conductor.onBeatHit.add((beat:Int) -> {
            tickSound.play();
			trace('New beat hit! - $beat');
		});
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if(conductor != null)
		{
			FlxG.watch.addQuick("curBeat: ", conductor.curBeat);
			FlxG.watch.addQuick("curStep: ", conductor.curStep);
			FlxG.watch.addQuick("curDecBeat: ", conductor.curDecBeat);
			FlxG.watch.addQuick("curDecStep: ", conductor.curDecStep);
		}
	}
}
