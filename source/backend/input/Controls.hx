package backend.input;

import backend.input.ActionInput;
import flixel.FlxBasic;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;

class Controls extends FlxBasic
{
	public static var instance:Null<Controls> = null;

	public var inputs:Array<ActionInput> = [];

	public var UI_LEFT:ActionInput;
	public var UI_DOWN:ActionInput;
	public var UI_UP:ActionInput;
	public var UI_RIGHT:ActionInput;

	public var ACCEPT:ActionInput;
	public var BACK:ActionInput;

	public function new()
	{
		super();
		visible = false;

		inputs.push(UI_LEFT = new ActionInput("UI_LEFT", {keys: [FlxKey.A, FlxKey.LEFT]}));
		inputs.push(UI_DOWN = new ActionInput("UI_DOWN", {keys: [FlxKey.S, FlxKey.DOWN]}));
		inputs.push(UI_UP = new ActionInput("UI_UP", {keys: [FlxKey.W, FlxKey.UP]}));
		inputs.push(UI_RIGHT = new ActionInput("UI_RIGHT", {keys: [FlxKey.D, FlxKey.RIGHT]}));

		inputs.push(ACCEPT = new ActionInput("ACCEPT", {keys: [FlxKey.ENTER], gamepadButtons: [FlxGamepadInputID.A], mouseButtons: [FlxMouseButtonID.LEFT]}));
		inputs.push(BACK = new ActionInput("BACK",
			{keys: [FlxKey.ESCAPE, FlxKey.BACKSPACE], gamepadButtons: [FlxGamepadInputID.B], mouseButtons: [FlxMouseButtonID.RIGHT]}));

		instance = this;
	}

	override public function update(elapsed:Float):Void
	{
		for (input in inputs)
			input.update();

		for (input in inputs)
		{
			FlxG.watch.addQuick('${input.name} pressed: ', input.pressed);
		}

		super.update(elapsed);
	}

	override public function destroy():Void
	{
		for (input in inputs)
			input.destroy();

		super.destroy();
	}
}
