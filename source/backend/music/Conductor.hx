package backend.music;

import flixel.FlxBasic;
import flixel.util.FlxSignal.FlxTypedSignal;

/**
 * A class that manages beat events for a FlxSound object.
 * It triggers events at regular intervals based on the beats per minute (BPM) of the music.
 */
class Conductor extends FlxBasic
{
	public static var instance:Conductor;

	/**
	 * The beats per minute (BPM) value.
	 */
	public var bpm(default, set):Int;

	/**
	 * The current beat count.
	 */
	public var curBeat(default, null):Int;

	/**
	 * The current beat count in decimals.
	 */
	public var curDecBeat(default, null):Float;

	/**
	 * The current step count.
	 */
	public var curStep(default, null):Int;

	/**
	 * The current step count.
	 */
	public var curDecStep(default, null):Float;

	/**
	 * Signal dispatched when a beat is hit. 
	 * The signal provides the current beat count.
	 */
	public var onBeatHit(default, null):FlxTypedSignal<Int->Void>;

	/**
	 * Signal dispatched when a step is hit. 
	 * The signal provides the current step count.
	 */
	public var onStepHit(default, null):FlxTypedSignal<Int->Void>;

	/**
	 * The `FlxSound` instance that is used in this conductor.
	 * returns FlxG.sound.music if `soundInstance` is null. `soundInstance` if it isn't.
	 */
	@:isVar
	public var music(get, set):FlxSound;

	/**
	 * The duration each beat takes in seconds.
	 */
	public var beatDuration(default, null):Float = 0;

	/**
	 * The duration each beat takes in millie seconds.
	 */
	public var beatDurationMS(default, null):Float = 0;

	/**
	 * Whether the Conductor is or should be running or not.
	 */
	public var running:Bool;

	/**
	 * A `FlxSound` that can be initialized through the `attacheSound` method to use instead of FlxG.sound.music.
	 * Use `music` variable to access it.
	 */
	@:noCompletion @:dox(show)
	private var soundInstance:FlxSound;

	/**
	 * Construct a new instance with a BPM to follow.
	 * NOTE: If you created the conductor and FlxG.sound.music isn't playing then you need to set `running` to true or call `attachSound`.
	 * @param bpm The beats per minute (BPM) value of the song that you're aiming to track.
	 * @param setToInstance Wether the `instance` should be set to `this` conductor.
	 */
	public function new(bpm:Int, ?setToInstance:Bool = false):Void
	{
		super();

		// Initialize some variables
		this.bpm = bpm;

		onBeatHit = new FlxTypedSignal<Int->Void>();
		onStepHit = new FlxTypedSignal<Int->Void>();

		running = FlxG.sound.music != null && FlxG.sound.music.playing; // Prevent the conductor from running if FlxG.sound.music isn't playing
		visible = false; // Prevent useless draw calls

		if (setToInstance)
		{
			instance = this;
			FlxG.signals.preStateSwitch.add(function()
			{
				onBeatHit.removeAll();
				onStepHit.removeAll();
				running = false;
				bpm = 1;
			});
		}
	}

	/**
	 * Attaches a FlxSound instance to the Conductor to use instead of FlxG.sound.music.
	 * @param embeddedSound The embedded sound asset to load.
	 * @param loop Whether the sound should loop.
	 */
	public function attachSound(embeddedSound:flixel.system.FlxAssets.FlxSoundAsset, ?loop:Bool = true):Void
	{
		// Pause the conductor
		running = false;

		// Create a new FlxSound instance
		soundInstance = FlxG.sound.load(embeddedSound, 1.0, loop);

		// Start the conductor
		running = soundInstance.play().playing;
	}

	override public function update(elapsed:Float):Void
	{
		if (running && music.playing)
		{
			// Calculate the decimal beats and steps
			curDecBeat = music.time / beatDurationMS;
			curDecStep = curDecBeat * 4;

			// Floor the decimal beats and steps
			var curBeat = Math.floor(curDecBeat);
			var curStep = Math.floor(curDecStep);

			// Adjust the instance's beats and steps and dispatch the signals
			if (this.curBeat != curBeat)
				onBeatHit.dispatch(this.curBeat = curBeat);

			if (this.curStep != curStep)
				onStepHit.dispatch(this.curStep = curStep);

			#if debug
			FlxG.watch.addQuick("curBeat: ", curBeat);
			FlxG.watch.addQuick("curStep: ", curStep);
			FlxG.watch.addQuick("curDecBeat: ", curDecBeat);
			FlxG.watch.addQuick("curDecStep: ", curDecStep);
			#end
		}

		super.update(elapsed);
	}

	/**
	 * Cleans up the Conductor.
	 */
	override public function destroy():Void
	{
		running = false;
		onBeatHit.destroy();
		onStepHit.destroy();

		if (soundInstance != null)
		{
			soundInstance.stop();
			soundInstance.destroy();
		}

		super.destroy();
	}

	@:noCompletion
	private function set_bpm(Value:Int):Int
	{
		running = false;
		beatDuration = 60 / Value;
		beatDurationMS = beatDuration * 1000;
		return bpm = Value;
	}

	@:noCompletion
	private function get_music():FlxSound
	{
		return soundInstance ?? FlxG.sound.music;
	}

	@:noCompletion
	private function set_music(Value:FlxSound):FlxSound
	{
		if (soundInstance != null)
			soundInstance = Value;
		else
			FlxG.sound.music = Value;

		return music = Value;
	}
}
