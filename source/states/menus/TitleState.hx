package states.menus;

import backend.GameState;
import ui.text.Alphabet;

class TitleState extends GameState
{
	public static var initialized:Bool = false;

	var transitioning:Bool = false;
	var introText:Array<Array<String>> = [];
	var curText:Array<String> = [];
	var curTextID:Int = 0;
	var funkinLogo:FlxSprite;
	var gfDance:FlxSprite;
	var titleText:FlxSprite;
	var newgrounds:FlxSprite;
	var alphabet:Alphabet;

	override public function create()
	{
		conductor.bpm = 102;

		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.getSound('freakyMenu', backend.assets.AssetLibrary.MUSIC), 0);
			FlxG.sound.music.pause();
		}

		gfDance = new FlxSprite(512, 40);
		gfDance.frames = Paths.getSparrowAtlas('titlescreen/gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		add(gfDance);

		funkinLogo = new FlxSprite(-150, -100);
		funkinLogo.frames = Paths.getSparrowAtlas('titlescreen/logoBumpin');
		funkinLogo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		funkinLogo.animation.play('bump');
		add(funkinLogo);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titlescreen/titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		if (initialized)
		{
			skipIntro();
		}
		else
		{
			titleText.visible = funkinLogo.visible = gfDance.visible = false;

			for (arr in Paths.getContent('introText', 'txt', backend.assets.AssetLibrary.DATA).split('\n'))
				introText.push(arr.split('--'));

			alphabet = new Alphabet(0, 0, "", true, CENTER);
			add(alphabet);

			newgrounds = new FlxSprite().loadGraphic(Paths.graphic('titlescreen/newgrounds_logo_animated'), true, 600);
			newgrounds.animation.add('newgrounds', [0, 1], 4);
			newgrounds.animation.play('newgrounds');
			newgrounds.setGraphicSize(Std.int(newgrounds.width * 0.38));
			newgrounds.updateHitbox();
			newgrounds.screenCenter();
			newgrounds.y += 190;
			newgrounds.visible = false;
			add(newgrounds);
		}

		conductor.onBeatHit.add(function(curBeat:Int)
		{
			if (gfDance != null)
			{
				if (gfDance.animation.curAnim != null && gfDance.animation.curAnim.name == 'danceLeft')
					gfDance.animation.play('danceRight');
				else
					gfDance.animation.play('danceLeft');
			}

			if (funkinLogo != null)
				funkinLogo.animation.play('bump', true);

			if (!initialized)
			{
				switch (curBeat)
				{
					case 1:
						setAlphabetNextText(["Neutron Engine By", "Karim Akra", "Lily"]);
					case 3:
						proggressAlphabetText(true);
					case 4:
						alphabet.visible = false;
					case 5:
						setAlphabetNextText(["Not associated", 'with', "Newgrounds"]);
						alphabet.y -= 120;
					case 7:
						proggressAlphabetText();
						newgrounds.visible = true;
					case 8:
						alphabet.visible = newgrounds.visible = false;
					case 9:
						setAlphabetNextText(FlxG.random.getObject(introText));
					case 11:
						proggressAlphabetText();
					case 12:
						alphabet.visible = false;
					case 13:
						setAlphabetNextText(["Friday", "Night", "Funkin"]);
					case 6 | 14 | 15:
						proggressAlphabetText();
					case 16:
						skipIntro();
				}
			}
		});

		FlxG.sound.music.resume();
		FlxG.sound.music.fadeIn(4, 0, 0.7);
		conductor.running = true;

		super.create();
	}

	var timer:FlxTimer = null;

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var pressedEnter:Bool = controls.ACCEPT.justPressed || (FlxG.touches.getFirst() != null && FlxG.touches.getFirst().justPressed);

		if (pressedEnter)
		{
			if (!initialized)
			{
				skipIntro();
				return;
			}
			else
			{
				if (!transitioning)
				{
					@:privateAccess
					{
						FlxG.camera._fxFlashAlpha = 0.0;
						FlxG.camera.updateFlashSpritePosition();
					}
					FlxG.camera.flash(FlxColor.WHITE, 1);
					Paths.sound('confirmMenu', 0.7, false, true).play();
					titleText.animation.play('press');
					timer = new FlxTimer().start(2, (tmr) -> FlxG.switchState(new MainMenuState()));
					transitioning = true;
					return;
				}

				if (transitioning)
				{
					@:privateAccess
					{
						FlxG.camera._fxFlashAlpha = 0.0;
						FlxG.camera.updateFlashSpritePosition();
					}
					timer.cancel();
					timer.onComplete(timer);
				}
			}
		}
	}

	private function skipIntro():Void
	{
		FlxG.camera.flash(FlxColor.WHITE, 4);

		if (alphabet != null)
			alphabet.destroy();

		if (newgrounds != null)
			newgrounds.destroy();

		initialized = titleText.visible = gfDance.visible = funkinLogo.visible = true;
	}

	private function setAlphabetNextText(text:Array<String>):Void
	{
		curText = text;
		curTextID = 0;
		alphabet.visible = false;
		alphabet.text = curText.join('\n');
		alphabet.screenCenter();
		alphabet.text = curText[curTextID];
		alphabet.visible = true;
		curTextID++;
	}

	private function proggressAlphabetText(forceFinish:Bool = false):Void
	{
		if (forceFinish)
		{
			alphabet.text = curText.join("\n");
			return;
		}

		if (alphabet.text.split('\n') == curText)
			return;

		alphabet.text += '\n' + curText[curTextID];
		curTextID++;
	}
}
