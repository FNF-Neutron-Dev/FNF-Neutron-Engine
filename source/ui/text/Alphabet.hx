package ui.text;

// Alphabet by Cobalt Bar (https://cobaltbar.github.io) used in Horizon Engine (https://github.com/CobaltBar/FNF-Horizon-Engine)
@:publicFields
class Alphabet extends FlxSpriteGroup
{
	var align(default, set):FlxTextAlign;
	var text(default, set):String;
	var bold(default, set):Bool;
	var textScale:Float;

	private var widths:Array<Float> = [];
	private var lines:Array<Array<FlxSprite>> = [];
	private var maxWidth:Float = 0;
	private var maxHeight:Float = 0;
	private var largestCharInLine:Array<Null<Float>> = [];

	private static var alphabetGroup:FlxSpriteGroup = new FlxSpriteGroup();
	private static final letterRegex = ~/^[a-zA-Z]+$/;

	function new(x:Float, y:Float, text:String, bold:Bool = true, align:FlxTextAlign = LEFT, scale:Float = 1)
	{
		super(x, y);

		@:bypassAccessor this.bold = bold;
		textScale = scale;

		this.text = text;
		this.align = align;
	}

	function updateText(val:String):Void
	{
		for (line in lines)
			for (char in line)
				char.kill();

		lines = [];
		widths = [];
		largestCharInLine = [];
		maxWidth = maxHeight = 0;

		for (i => text in val.replace('\r', '').split('\n'))
		{
			var letterTracker:Float = 0;
			lines[i] = [];

			for (ch in text.split(''))
			{
				if (ch == ' ')
				{
					letterTracker += 30 * textScale;
					continue;
				}

				var animName = switch (ch)
				{
					case '?':
						'question';
					case '&':
						'ampersand';
					case '<':
						'less';
					case '"':
						'quote';
					default:
						ch;
				}

				if (bold)
					animName += ' bold';
				else if (letterRegex.match(ch))
					animName += animName.toLowerCase() != animName ? ' uppercase' : ' lowercase';
				else
					animName += ' normal';
				animName = animName.toLowerCase();

				var char = alphabetGroup.recycle(null, function()
				{
					var sprite:FlxSprite = new FlxSprite();
					sprite.frames = Paths.getSparrowAtlas('alphabet');
					return sprite;
				});
				if (char.animation.exists('idle'))
					char.animation.remove('idle');
				char.animation.addByPrefix('idle', animName, 24);
				char.animation.play('idle');
				char.scale.set(textScale, textScale);
				char.updateHitbox();

				char.x = char.y = char.angle = 0;
				char.angle = 1;
				char.clipRect = null;
				char.color = 0xFFFFFFFF;
				char.flipX = char.flipY = false;
				char.setColorTransform();

				if (char.height > maxHeight)
					maxHeight = char.height;

				switch (ch)
				{
					case "'" | '“' | '”' | '*' | '^' | '"':
						char.y -= char.height;
					case '+':
						char.y -= char.height * .25;
					case '-':
						char.y -= char.height;
					case 'y':
						if (!bold)
							char.y -= char.height * .15;
				}

				char.x = letterTracker;
				char.y -= char.height;
				letterTracker += char.width + (2 * textScale);
				add(char);
				lines[i].push(char);
			}

			widths.push(letterTracker);
			if (letterTracker > maxWidth)
				maxWidth = letterTracker;
		}

		for (i => line in lines)
		{
			for (char in line)
			{
				if (largestCharInLine[i] == null || largestCharInLine[i] < char.height)
					largestCharInLine[i] = char.height;

				char.y += maxHeight * (i + 1);
			}
		}

		this.align = align;
	}

	@:noCompletion function set_text(val:String):String
	{
		updateText(val);
		return text = val;
	}

	@:noCompletion function set_bold(val:Bool):Bool
	{
		bold = val;
		updateText(text);
		return val;
	}

	@:noCompletion function set_align(val:FlxTextAlign):FlxTextAlign
	{
		// if (val == CENTER)
		// 	for (i => line in lines)
		// 		for (char in line)
		// 			char.y -= (maxHeight - char.height) * .5;
		// else if (val == RIGHT)
		// 	for (i => line in lines)
		// 		for (char in line)
		// 			char.y -= maxHeight - char.height;

		if (val == CENTER)
			for (i => line in lines)
				for (char in line)
					char.x += (maxWidth - widths[i]) * .5;
		else if (val == RIGHT)
			for (i => line in lines)
				for (char in line)
					char.x += maxWidth - widths[i];
		return align = val;
	}

	override function destroy():Void
	{
		for (line in lines)
			for (char in line)
			{
				char.kill();
				remove(char, true);
			}
		lines = [];
		super.destroy();
	}
	override function setColorTransform(redMultiplier = 1.0, greenMultiplier = 1.0, blueMultiplier = 1.0, alphaMultiplier = 1.0, redOffset = 0.0,
			greenOffset = 0.0, blueOffset = 0.0, alphaOffset = 0.0):Void
	{
		for (member in members)
			member.setColorTransform(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
	}

	override function get_width():Float
	{
		return width = maxWidth;
	}

	override function get_height():Float
	{
		var x:Float = 0;
		for (i in largestCharInLine)
			x += i;
		return height = x;
	}
}
