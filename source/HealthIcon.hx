package;

import flixel.FlxSprite;
import flixel.FlxG;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		
		loadGraphic(Paths.image('icons/icon-' + char, 'shared'), true, 150, 150);

		animation.add(char, [0, 1, 2], 0, false, isPlayer);
		
		animation.play(char);

		switch (char)
		{
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit' | 'gf-pixel':
				antialiasing = false;
			default:
				antialiasing = true; //grrrrr this is what makes the rest not look blocky, mannnnn
		}

		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
