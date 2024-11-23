package backend.input;

import flixel.input.IFlxInput;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
#if android
import flixel.input.android.FlxAndroidKey;
#end

typedef BindsList =
{
	@:optional var keys:Array<FlxKey>;
	@:optional var gamepadButtons:Array<FlxGamepadInputID>;
	@:optional var inputs:Array<IFlxInput>;
	#if android
	@:optional var androidButtons:Array<FlxAndroidKey>;
	#end
}
