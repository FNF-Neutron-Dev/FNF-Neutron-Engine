package ui.text;

@:access(flixel.animation.FlxAnimationController)
class AlphabetCharacter extends FlxSprite
{
	public static var letters:Array<String> = [
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
	];
	public static var numbers:Array<String> = [for (i in 0...10) Std.string(i)];
	public static var symbols:Map<String, String> = [
		"." => "period", "'" => "apostraphie", "?" => "question mark", "!" => "exclamation point", "#" => "hashtag", "$" => "dollarsign", "&" => "amp",
		"," => "comma", "“" => "start parentheses", "”" => "end parentheses", "/" => "forward slash", "×" => "multiply x", "*" => "*", "%" => "%", "-" => "-",
		"+" => "+", ":" => ":", ";" => ";", "<" => "<", ">" => ">", ")" => ")", "(" => "(", "=" => "=", "@" => "@", "[" => "[", "]" => "]", "^" => "^",
		"_" => "_", "~" => "~", "|" => "|"
	];

	public var character(default, set):String;
	public var bold(default, set):Bool;
	public var row:Int = 0;

	public function new(?character:String, ?bold:Bool = true, ?copyFrom:AlphabetCharacter)
	{
		super();

		character = character.charAt(0);

		if (copyFrom == null)
			setupCharacter(this);
		else
			copy(copyFrom, this);

		this.bold = bold;
		this.character = character;
	}

	public static function setupCharacter(alphabet:AlphabetCharacter)
	{
		alphabet.frames = Paths.getSparrowAtlas("alphabetOG");
		
		for (letter in letters)
		{
			alphabet.animation.addByPrefix(letter, '$letter lowercase', 24);
			letter = letter.toUpperCase();
			alphabet.animation.addByPrefix(letter, '$letter capital', 24);
			alphabet.animation.addByPrefix('$letter~B', '$letter bold', 24);
		}

		for (number in numbers)
			alphabet.animation.addByPrefix(number, number, 24);

		for (symbol in symbols.keys())
			alphabet.animation.addByPrefix(symbol, symbols.get(symbol), 24);
	}

	public static function copy(from:AlphabetCharacter, to:AlphabetCharacter)
	{
		to.frames = from.frames;
		to.animation.copyFrom(from.animation);
	}

	@:noCompletion
	private function set_character(value:String):String
	{
		if(value == null || value == '') return character = value;
		value = value.charAt(0);

		if (value == ' ')
			trace('uhh how do i add spaces?');
		else if (letters.contains(value.toLowerCase()) && !symbols.exists(value) && !numbers.contains(value))
			animation.play(bold ? '${value.toUpperCase()}~B' : value, true);
		else if ((numbers.contains(value) || symbols.exists(value)) && !letters.contains(value.toLowerCase()))
			animation.play(value, true);
		else
		{
			animation.play("#", true);
			NeutronLogger.warn("Character " + value + " is not implemented into the alphabets.");
		}

		updateHitbox();
		return character = animation.curAnim != null ? animation.curAnim.name.charAt(0) : value;
	}

	@:noCompletion
	private function set_bold(value:Bool):Bool
	{
		if (character == null || character == '')
			return bold = value;

		bold = value;
		// reload the animations
		character = character;
		return bold;
	}
}
