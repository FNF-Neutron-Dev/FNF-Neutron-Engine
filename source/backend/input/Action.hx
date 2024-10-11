package backend.input;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.IFlxInput;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
import flixel.input.actions.FlxActionInput.FlxInputType;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

@:nullSafety
class Action extends flixel.input.actions.FlxAction
{
	public var trigger(default, null):FlxInputState;

	/**
	 * Create a new digital action
	 * @param	Name	name of the action
	 * @param	Trigger	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 */
	public function new(?Name:String = "", Trigger:FlxInputState)
	{
		super(FlxInputType.DIGITAL, Name);
		trigger = Trigger;
	}

	/**
	 * Adds all the digital inputs within the binds list
	 * @param binds
	 * @param clear if it should clear the current binds
	 */
	public function bindFromBindsList(binds:BindsList, ?clear:Bool = false):Action
	{
		if (clear == true)
			removeAll();
		if (binds.keys != null)
			for (key in binds.keys)
				addKey(key);
		if (binds.gamepadButtons != null)
			for (gamepadButton in binds.gamepadButtons)
				addGamepad(gamepadButton);
		if (binds.inputs != null)
			for (input in binds.inputs)
				addInput(input);
		#if android
		if (binds.androidButtons != null)
			for (androidButton in binds.androidButtons)
				addAndroidKey(androidButton);
		#end

		return this;
	}

	/**
	 * Add a digital input (any kind) that will trigger this action
	 * @param	input
	 * @return	This action
	 */
	public function add(input:FlxActionInputDigital):Action
	{
		addGenericInput(input);
		return this;
	}

	/**
	 * Add a generic IFlxInput action input
	 *
	 * WARNING: IFlxInput objects are often member variables of some other
	 * object that is often destructed at the end of a state. If you don't
	 * destroy() this input (or the action you assign it to), the IFlxInput
	 * reference will persist forever even after its parent object has been
	 * destroyed!
	 *
	 * @param	Input	A generic IFlxInput object (ex: FlxButton.input)
	 * @return	This action
	 */
	public function addInput(Input:IFlxInput):Action
	{
		return add(new FlxActionInputDigitalIFlxInput(Input, trigger));
	}

	/**
	 * Add a gamepad action input for digital (button-like) events
	 * @param	InputID "universal" gamepad input ID (A, X, DPAD_LEFT, etc)
	 * @param	GamepadID specific gamepad ID, or FlxInputDeviceID.ALL / FIRST_ACTIVE
	 * @return	This action
	 */
	public function addGamepad(InputID:FlxGamepadInputID, GamepadID:Int = FlxInputDeviceID.FIRST_ACTIVE):Action
	{
		return add(new FlxActionInputDigitalGamepad(InputID, trigger, GamepadID));
	}

	/**
	 * Add a keyboard action input
	 * @param	Key Key identifier (FlxKey.SPACE, FlxKey.Z, etc)
	 * @return	This action
	 */
	public function addKey(Key:FlxKey):Action
	{
		return add(new FlxActionInputDigitalKeyboard(Key, trigger));
	}

	#if android
	/**
	 * Android buttons action inputs
	 * @param	Key	Android button key, BACK, or MENU probably (might need to set FlxG.android.preventDefaultKeys to disable the default behaviour and allow proper use!)
	 * @return	This action
	 * 
	 * @since 4.10.0
	 */
	public function addAndroidKey(Key:flixel.input.android.FlxAndroidKey):Action
	{
		return add(new FlxActionInputDigitalAndroid(Key, trigger));
	}
	#end
}
