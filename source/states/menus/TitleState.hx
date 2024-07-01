package states.menus;

import ui.text.Alphabet;
import backend.music.BPMConductor;

class TitleState extends FlxState
{
	public static var initialized:Bool = false;
    var introText:Array<Array<String>> = [];
    var alphabet:Alphabet;
	var ngSpr:FlxSprite;
    var danceLeft:Bool = true;

    var funkinLogo:FlxSprite;
    var gfDance:FlxSprite;

    override public function create()
    {

        gfDance = new FlxSprite(512, 40);
        gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
        add(gfDance);

        funkinLogo = new FlxSprite(-150, -100);
		funkinLogo.frames = Paths.getSparrowAtlas('logoBumpin');
		funkinLogo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		funkinLogo.animation.play('bump');
        add(funkinLogo);

        if(!initialized)
        {
            for(arr in Paths.getContent('introText', 'txt', DATA).split('\n'))
                introText.push(arr.split('--'));

            alphabet = new Alphabet(0, 0, "");
            add(alphabet);
        }

        if(FlxG.sound.music == null || !FlxG.sound.music.playing)
        {
            FlxG.sound.playMusic(Paths.getSound('freakyMenu', MUSIC), 0);
            FlxG.sound.music.fadeIn(1.2, 0, 0.7);
        }
        var conductor:BPMConductor = new BPMConductor(102);
        conductor.onBeatHit.add(function(beat:Int){
            if (gfDance.animation.curAnim != null && gfDance.animation.curAnim.name == 'danceLeft')
                gfDance.animation.play('danceRight');
            else
                gfDance.animation.play('danceLeft');

            funkinLogo.animation.play('bump', true);
            danceLeft = !danceLeft;
        });

        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);    
    }
}