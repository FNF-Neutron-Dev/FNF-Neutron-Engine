package backend.input;

import backend.input.Action;
import flixel.input.FlxInput.FlxInputState;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.ds.Map;

@:nullSafety
class ActionInput implements IFlxDestroyable
{
	public static final triggers:Map<String, FlxInputState> = [
		'JUST_RELEASED' => JUST_RELEASED,
		'RELEASED' => RELEASED,
		'PRESSED' => PRESSED,
		'JUST_PRESSED' => JUST_PRESSED
	];

	public var actions(default, null):Map<FlxInputState, Action> = new Map<FlxInputState, Action>();

	public var name(default, null):String;
    
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;
	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;

	public function new(name:String, ?binds:BindsList)
	{
		this.name = name;
		for (trigger in triggers.keys())
		{
			@:nullSafety(Off)
			var action = new Action('${name}_$trigger', triggers.get(trigger));
			if (binds != null)
				action.bindFromBindsList(binds);
			@:nullSafety(Off)
			actions.set(triggers.get(trigger), action);
		}
	}

	public function update():Void
	{
		for (action in actions)
			action.update();
	}

	public function destroy():Void
	{
		for (action in actions)
			action.destroy();
	}

	@:noCompletion
	private function get_pressed():Bool
	{
		var action:Null<Action> = actions.get(PRESSED);
		if (action != null)
			return action.check();
		else
			return false;
	}

	@:noCompletion
	private function get_justPressed():Bool
	{
		var action:Null<Action> = actions.get(JUST_PRESSED);
		if (action != null)
			return action.check();
		else
			return false;
	}

	@:noCompletion
	private function get_justReleased():Bool
	{
		var action:Null<Action> = actions.get(JUST_RELEASED);
		if (action != null)
			return action.check();
		else
			return false;
	}

	@:noCompletion
	private function get_released():Bool
	{
		var action:Null<Action> = actions.get(RELEASED);
		if (action != null)
			return action.check();
		else
			return false;
	}
}
