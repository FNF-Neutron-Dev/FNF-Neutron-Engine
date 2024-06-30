package backend.music;

import flixel.FlxBasic;
import flixel.util.FlxSignal.FlxTypedSignal;

/**
 * A class that manages beat events for a FlxSound object.
 * It triggers events at regular intervals based on the beats per minute (BPM) of the music.
 */
class BPMConductor extends FlxBasic
{
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
     * Whether the BPMConductor is running or not.
     */
    public var running:Bool;

    /**
     * The FlxSound instance managed by the BPMConductor.
     */
    @:isVar
    public var music(get, set):FlxSound;

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

    @:noCompletion
    private var beatDuration:Float = 0;

    @:noCompletion
    private var soundInstance:FlxSound;

    @:noCompletion
    private var _running:Bool = false;

    /**
     * Constructor to initialize the BPMConductor with a BPM value.
     * @param bpm The beats per minute (BPM) value.
     */
    public function new(bpm:Int):Void
    {
        super();

        // Initialize some variables
        this.bpm = bpm;
        onBeatHit = new FlxTypedSignal<Int->Void>();
        onStepHit = new FlxTypedSignal<Int->Void>();

        running = FlxG.sound.music != null && FlxG.sound.music.playing; // Prevent the conductor from running if FlxG.sound.music isn't playing
        visible = false; // Prevent useless draw calls

        FlxG.signals.postUpdate.add(_update);
    }

    /**
     * Attaches a FlxSound instance to the BPMConductor to use instead of FlxG.sound.music.
     * @param embeddedSound The embedded sound asset to load.
     * @param loop Whether the sound should loop.
     */
    public function attachSound(embeddedSound:flixel.system.FlxAssets.FlxSoundAsset, ?loop:Bool = true):Void
    {
        // Pause the conductor
        running = false;

        // Create a new FlxSound instance
        soundInstance = new FlxSound();
        soundInstance.loadEmbedded(embeddedSound, loop);
        FlxG.sound.defaultSoundGroup.add(soundInstance);

        // Start the conductor
        running = soundInstance.play().playing;
    }

    override public function update(elapsed:Float)
    {    
        if(running && music.playing)
        {
            curDecBeat = (music.time / 1000) / beatDuration;
            curDecStep = curDecBeat * 4;

            var curBeat = Math.floor(curDecBeat);
            var curStep = Math.floor(curDecStep);

            if(this.curBeat != curBeat)
                onBeatHit.dispatch(this.curBeat = curBeat);

            if(this.curStep != curStep)
                onStepHit.dispatch(this.curStep = curStep);
        }
        
        super.update(elapsed);
    }

    /**
     * Cleans up the BPMConductor, stopping the thread and destroying the signal.
     */
    override public function destroy():Void
    {
        running = active = false;
        // Destroy all the signals
        onBeatHit.removeAll();
        onStepHit.removeAll();
        onBeatHit.destroy();
        onStepHit.destroy();
        FlxG.signals.postUpdate.remove(_update);

        // Destroy the instance sound if exists
        if(soundInstance != null)
        {
            soundInstance.stop();
            soundInstance.destroy();
        }

        super.destroy();
    }

    @:noCompletion
    private function set_bpm(Value:Int):Int
    {
        beatDuration = 60 / Value;
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

    @:noCompletion
    private function _update():Void
    {
        update(FlxG.elapsed);
    }
}
