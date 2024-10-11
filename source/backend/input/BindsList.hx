package backend.input;

import flixel.input.IFlxInput;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
#if android
import flixel.input.android.FlxAndroidKey;
#end

typedef BindsList =
{
	@:optional var keys:Array<FlxKey>;
	@:optional var gamepadButtons:Array<FlxGamepadInputID>;
	@:optional var inputs:Array<IFlxInput>;
	@:optional var mouseButtons:Array<FlxMouseButtonID>;
	#if android
	@:optional var androidButtons:Array<FlxKey>;
	#end
}
