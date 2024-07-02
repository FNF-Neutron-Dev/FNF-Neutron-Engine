package states.menus;

import flixel.FlxState;

class MainMenuState extends FlxState
{
	override public function create():Void
        {
            super.create();
            // YEPIII memory cleaning works just fine :3
            // it dropped from around 200mb to 15mb
            // btw the reason why title state uses upto 200mb is because psych's alphabet is so shit that whenver i set the text it takes up memory :/
            // and i set the flixel version to 5.5.0 in hmm because psych's alphabet also has a fuck with animations so it blows up my flixel console log with warnings
            // so ye i WILL change the alphabet to fix these issues
            Paths.clearMemory();
            var cat:FlxSprite = new FlxSprite().loadGraphic(Paths.graphic("War-Cat.jpg"));
            cat.setGraphicSize(FlxG.width / 2, FlxG.height / 2);
            cat.updateHitbox();
            cat.screenCenter();
            add(cat);
        }
    
        override public function update(elapsed:Float):Void
        {
            super.update(elapsed);
        }
}