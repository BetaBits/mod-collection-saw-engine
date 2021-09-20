package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class ThigsState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{						
		var txt:FlxText = new FlxText(0, 360, FlxG.width,
			"This Engine Was Created By\nM.A. Jigsaw\n"
			+ "\nCredits To:\nKade Dev - The Base\nVerwex - The Appearance Of The Menus\nKlavier Gayming - Video Extension\n"
			+ "\nFunk all the way.\nPress ENTER to proceed",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
		
		super.create();
	}

	override function update(elapsed:Float)
	{		
		if (controls.ACCEPT)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}