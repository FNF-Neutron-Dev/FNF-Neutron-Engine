package states.menus;

import flixel.FlxState;

class MainMenuState extends FlxState
{
	override public function create():Void
	{
		super.create();
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