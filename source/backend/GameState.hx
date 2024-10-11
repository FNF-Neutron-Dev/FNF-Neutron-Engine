package backend;

import backend.input.Controls;
import backend.music.Conductor;
import flixel.FlxState;

class GameState extends FlxState
{
	public var controls(get, never):Controls;
	public var conductor(get, never):Conductor;

	@:noCompletion
	private function get_controls():Controls
	{
		return Controls.instance;
	}

	@:noCompletion
	private function get_conductor():Conductor
	{
		return Conductor.instance;
	}
}
