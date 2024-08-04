package ui.text;

class NewAlphabet extends FlxTypedSpriteGroup<AlphabetCharacter>
{
	public static var CHARS_SEP:Float = 5.0;
	public static var ROWS_SPACING:Float = 15.0;

	public var text(default, set):String;
	public var bold(default, set):Bool;
	public var largestLettersInRows:Array<AlphabetCharacter> = [];

	public function new(x:Float, y:Float, text:String, bold:Bool = true)
	{
		super(x, y);

		this.bold = bold;
		this.text = text;
	}

	@:noCompletion
	private function set_text(value:String):String
	{
		if (value == '')
		{
			forEachAlive((char) -> char.kill());
			return text = value;
		}

		for (i in 0...members.length + 1)
		{
			if (i >= value.replace(' ', '').length && members[i] != null)
				members[i].kill();
		}

		var index:Int = -1;
		var spacesToAdd:Int = 0;
		var curRow:Int = 0;
		var prevcurRow:Int = 0;
		forEachAlive((char) -> char.setPosition(0, 0));
		largestLettersInRows = [];
		for (character in value.split(''))
		{
			if (character == " " || character == "\n" || character == "\\n")
			{
				if (character == " ")
					spacesToAdd++;
				else
					curRow++;
				continue;
			}

			index++;

			var aCharacter:AlphabetCharacter = members[index];
			var hasToAddSpace:Bool = spacesToAdd > 0;
			var isNewRow:Bool = curRow > 0 && curRow != prevcurRow;
			if (aCharacter != null && !aCharacter.exists)
				aCharacter = null;
			if (aCharacter == null)
			{
				aCharacter = recycle(createCharacter.bind(members[0]));
				if (!members.contains(aCharacter))
					add(aCharacter);
			}

			aCharacter.character = character;
			aCharacter.bold = bold;
			aCharacter.row = curRow;

			if (largestLettersInRows[curRow] == null || largestLettersInRows[curRow].height < aCharacter.height)
				largestLettersInRows[curRow] = aCharacter;

			var prevChar:AlphabetCharacter = members[index - 1];
			var charX:Float = (prevChar == null || isNewRow) ? x : prevChar.x + prevChar.width;
			var charY:Float = (largestLettersInRows[curRow] == null || largestLettersInRows[curRow] == aCharacter) ? y
				+ (height - aCharacter.height) : largestLettersInRows[curRow].y
					+ largestLettersInRows[curRow].height
						- aCharacter.height;

			aCharacter.x = hasToAddSpace ? charX + (28 * spacesToAdd) : prevChar == null ? charX : charX + CHARS_SEP;
			aCharacter.y = isNewRow ? charY + (height / curRow) : charY;

			if (hasToAddSpace && character != " ")
				spacesToAdd--;
			prevcurRow = curRow;
		}
		return text = value;
	}

	@:noCompletion
	private function set_bold(value:Bool):Bool
	{
		trace('changed bold');
		bold = value;
		forEachAlive((character:AlphabetCharacter) -> character.bold = bold);
		if (text != null)
			text = text;
		return bold;
	}

	@:noCompletion
	private function createCharacter(?source:AlphabetCharacter):AlphabetCharacter
	{
		var character:AlphabetCharacter = new AlphabetCharacter(null, bold, source);
		add(character);

		return character;
	}
}