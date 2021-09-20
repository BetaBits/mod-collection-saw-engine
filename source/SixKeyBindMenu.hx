package;

/// Code created by Rozebud for FPS Plus (thanks rozebud)
// modified by KadeDev for use in Kade Engine/Tricky

import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;


using StringTools;

class SixKeyBindMenu extends FlxSubState
{

    var keyTextDisplay:FlxText;
    var keyWarning:FlxText;
    var warningTween:FlxTween;
    var keyText:Array<String> = ["LEFT1", "UP", "RIGHT1", "LEFT2", "DOWN", "RIGHT2"];
    var defaultKeys:Array<String> = ["S", "D", "F", "J", "K", "L"];
    var defaultArrowKeys:Array<String> = ["S", "D", "F", "LEFT", "DOWN", "RIGHT"];
	var selectable:Bool = false;	

    var defaultGpKeys:Array<String> = ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "DPAD_RIGHT"];
    var curSelected:Int = 0;

    var keys:Array<String> = [FlxG.save.data.L1Bind,
                              FlxG.save.data.U1Bind,
                              FlxG.save.data.R1Bind,
                              FlxG.save.data.L2Bind,
                              FlxG.save.data.D1Bind,
                              FlxG.save.data.R2Bind];
    var gpKeys:Array<String> = [FlxG.save.data.gpleftBind,
                              FlxG.save.data.gpdownBind,
                              FlxG.save.data.gpupBind,
                              FlxG.save.data.gprightBind];
    var tempKey:String = "";
    var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "SPACE", "TAB"];
	var bg:FlxSprite = new FlxSprite(-89).loadGraphic(Paths.image('KeyBindMenuThins/cBG_Main'));
	var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('KeyBindMenuThins/Cont_side'));
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('KeyBindMenuThins/Cont_Checker'), 0.2, 0.2, true, true);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);

    var infoText:FlxText;

    var state:String = "select";

	override function create()
	{	

        bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);
		bg.alpha = 0;

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55FFBDF8, 0xAAFFFDF3], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0, 0.07);

		add(side);
		side.alpha = 0;

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				selectable = true;
			});


        for (i in 0...keys.length)
        {
            var k = keys[i];
            if (k == null)
                keys[i] = defaultKeys[i];
        }

        for (i in 0...gpKeys.length)
        {
            var k = gpKeys[i];
            if (k == null)
                gpKeys[i] = defaultGpKeys[i];
        }
	
		//FlxG.sound.playMusic('assets/music/configurator' + TitleState.soundExt);

		persistentUpdate = true;

        keyTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 2;
		keyTextDisplay.borderQuality = 3;


        infoText = new FlxText(-10, 580, 1280, 'Current Mode: ${KeyBinds.gamepad ? 'GAMEPAD' : 'KEYBOARD'}. Press TAB to switch\n(${KeyBinds.gamepad ? 'RIGHT Trigger' : 'Escape'} to save, ${KeyBinds.gamepad ? 'LEFT Trigger' : 'Backspace'} to reset, ${KeyBinds.gamepad ? 'why are you using gamepad lol' : 'L'} to set up for Arrow Keys. ${KeyBinds.gamepad ? 'START To change a keybind' : ''})', 72);
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 2;
		infoText.borderQuality = 3;
        infoText.alpha = 0;
        infoText.screenCenter(FlxAxes.X);
        add(infoText);
        add(keyTextDisplay);

        keyTextDisplay.alpha = 0;

        FlxTween.tween(keyTextDisplay, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
        FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
		FlxTween.tween(bg, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});
		FlxTween.tween(side, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});

        OptionsMenu.instance.acceptInput = false;

        textUpdate();

		super.create();
	}

    var frames = 0;

	override function update(elapsed:Float)
	{
        var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

        if (frames <= 10)
            frames++;

        switch(state){

            case "select":
                if (FlxG.keys.justPressed.UP)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeItem(-1);
                }

                if (FlxG.keys.justPressed.DOWN)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeItem(1);
                }

                if (FlxG.keys.justPressed.TAB)
                {
                    KeyBinds.gamepad = !KeyBinds.gamepad;
                    infoText.text = 'Current Mode: ${KeyBinds.gamepad ? 'GAMEPAD' : 'KEYBOARD'}. Press TAB to switch\n(${KeyBinds.gamepad ? 'RIGHT Trigger' : 'Escape'} to save, ${KeyBinds.gamepad ? 'LEFT Trigger' : 'Backspace'} to leave without saving. ${KeyBinds.gamepad ? 'START To change a keybind' : ''})';
                    textUpdate();
                }

                if (FlxG.keys.justPressed.ENTER){
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    state = "input";
                }
                else if(FlxG.keys.justPressed.ESCAPE){
                    quit();
                }
                else if (FlxG.keys.justPressed.BACKSPACE){
                    reset();
                }
                else if (FlxG.keys.justPressed.L){
                    resetArrows();
                }
                if (gamepad != null) // GP Logic
                {
                    if (gamepad.justPressed.DPAD_UP)
                    {
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                        changeItem(-1);
                        textUpdate();
                    }
                    if (gamepad.justPressed.DPAD_DOWN)
                    {
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                        changeItem(1);
                        textUpdate();
                    }

                    if (gamepad.justPressed.START && frames > 10){
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                        state = "input";
                    }
                    else if(gamepad.justPressed.LEFT_TRIGGER){
                        quit();
                    }
                    else if (gamepad.justPressed.RIGHT_TRIGGER){
                        reset();
                    }
                }

            case "input":
                tempKey = keys[curSelected];
                keys[curSelected] = "?";
                if (KeyBinds.gamepad)
                    gpKeys[curSelected] = "?";
                textUpdate();
                state = "waiting";

            case "waiting":
                if (gamepad != null && KeyBinds.gamepad) // GP Logic
                {
                    if(FlxG.keys.justPressed.ESCAPE){ // just in case you get stuck
                        gpKeys[curSelected] = tempKey;
                        state = "select";
                        FlxG.sound.play(Paths.sound('confirmMenu'));
                    }

                    if (gamepad.justPressed.START)
                    {
                        addKeyGamepad(defaultKeys[curSelected]);
                        save();
                        state = "select";
                    }

                    if (gamepad.justPressed.ANY)
                    {
                        trace(gamepad.firstJustPressedID());
                        addKeyGamepad(gamepad.firstJustPressedID());
                        save();
                        state = "select";
                        textUpdate();
                    }

                }
                else
                {
                    if(FlxG.keys.justPressed.ESCAPE){
                        keys[curSelected] = tempKey;
                        state = "select";
                        FlxG.sound.play(Paths.sound('confirmMenu'));
                    }
                    else if(FlxG.keys.justPressed.ENTER){
                        addKey(defaultKeys[curSelected]);
                        save();
                        state = "select";
                    }
                    else if(FlxG.keys.justPressed.ANY){
                        addKey(FlxG.keys.getIsDown()[0].ID.toString());
                        save();
                        state = "select";
                    }
                }


            case "exiting":


            default:
                state = "select";

        }

        if(FlxG.keys.justPressed.ANY)
			textUpdate();

		super.update(elapsed);
		
	}

    function textUpdate(){

        keyTextDisplay.text = "\n\n";

        if (KeyBinds.gamepad)
        {
            for(i in 0...6){

                var textStart = (i == curSelected) ? "> " : "  ";
                trace(gpKeys[i]);
                keyTextDisplay.text += textStart + keyText[i] + ": " + gpKeys[i] + "\n";
                
            }
        }
        else
        {
            for(i in 0...6){

                var textStart = (i == curSelected) ? "> " : "  ";
                keyTextDisplay.text += textStart + keyText[i] + ": " + ((keys[i] != keyText[i]) ? (keys[i] + " / ") : "" ) + keyText[i] + " ARROW\n";

            }
        }

        keyTextDisplay.screenCenter();

    }

    function save(){       
        FlxG.save.data.gpupBind = gpKeys[2];
        FlxG.save.data.gpdownBind = gpKeys[1];
        FlxG.save.data.gpleftBind = gpKeys[0];
        FlxG.save.data.gprightBind = gpKeys[3];

        FlxG.save.data.L1Bind = keys[0];
        FlxG.save.data.U1Bind = keys[1];
        FlxG.save.data.R1Bind = keys[2];
        FlxG.save.data.L2Bind = keys[3];
        FlxG.save.data.D1Bind = keys[4];
        FlxG.save.data.R2Bind = keys[5];

        FlxG.save.flush();

        PlayerSettings.player1.controls.loadKeyBinds();

    }

    function reset(){

        for(i in 0...6){
            keys[i] = defaultKeys[i];
        }
        quit();

    }
    function resetArrows(){

        for(i in 0...6){
            keys[i] = defaultArrowKeys[i];
        }
        quit();

    }

    function quit(){
	
	    save();
		FlxG.switchState(new OptionsMenu());

	    FlxTween.tween(FlxG.camera, {zoom: 0.6, alpha: -0.6}, 0.7, {ease: FlxEase.quartInOut});
		FlxTween.tween(bg, {alpha: 0}, 0.7, {ease: FlxEase.quartInOut});
		FlxTween.tween(checker, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
		FlxTween.tween(gradientBar, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
		FlxTween.tween(side, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
    }


    function addKeyGamepad(r:String){

        var shouldReturn:Bool = true;

        var notAllowed:Array<String> = ["START", "RIGHT_TRIGGER", "LEFT_TRIGGER"];

        for(x in 0...gpKeys.length)
            {
                var oK = gpKeys[x];
                if(oK == r)
                    //gpKeys[x] = null;
                if (notAllowed.contains(oK))
                {
                    gpKeys[x] = null;
                    return;
                }
            }

        if(shouldReturn){
            gpKeys[curSelected] = r;
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
        else{
            gpKeys[curSelected] = tempKey;
            FlxG.sound.play(Paths.sound('scrollMenu'));
            keyWarning.alpha = 1;
            warningTween.cancel();
            warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 2});
        }

	}

	function addKey(r:String){

        var shouldReturn:Bool = true;

        var notAllowed:Array<String> = [];

        for(x in blacklist){notAllowed.push(x);}

        trace(notAllowed);

        for(x in 0...keys.length)
            {
                var oK = keys[x];
                if(oK == r)
                    //keys[x] = null;
                if (notAllowed.contains(oK))
                {
                    keys[x] = null;
                    return;
                }
            }

        if (r.contains("NUMPAD"))
        {
            keys[curSelected] = null;
            return;
        }

        if(shouldReturn){
            keys[curSelected] = r;
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
        else{
            keys[curSelected] = tempKey;
            FlxG.sound.play(Paths.sound('scrollMenu'));
            keyWarning.alpha = 1;
            warningTween.cancel();
            warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 2});
        }

	}

    function changeItem(_amount:Int = 0)
    {
        curSelected += _amount;
                
        if (curSelected > 5)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = 5;
    }
}
