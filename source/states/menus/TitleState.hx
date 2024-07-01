package states.menus;

import ui.text.Alphabet;
import backend.music.BPMConductor;

class TitleState extends FlxState
{
    var alphabet:Alphabet;

    override public function create()
    {
        FlxG.sound.playMusic(Paths.getSound('freakyMenu', MUSIC), 0);
        FlxG.sound.music.fadeIn(1.2, 0, 0.7);
        var conductor:BPMConductor = new BPMConductor(102);
        alphabet = new Alphabet(0, 0, "Hello World!");
        alphabet.screenCenter();
        add(alphabet);

        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);    
    }
}