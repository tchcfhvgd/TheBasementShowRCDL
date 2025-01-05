package options;

#if DISCORD_ALLOWED
import Discord.DiscordClient;
#end
import openfl.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import openfl.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Graphics', 'Visuals and UI', 'Gameplay', 'Mobile Options'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
		if (label != "Adjust Delay and Combo"){
			persistentUpdate = false;
			removeTouchPad();
		}
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Mobile Options':
				openSubState(new mobile.options.MobileOptionsSubState());
		}
	}

	override function create() {
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var tipText:FlxText = new FlxText(150, FlxG.height - 24, 0, 'Press C to Go Mobile Controls Menu', 16);
		tipText.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 1.25;
		tipText.scrollFactor.set();
		tipText.antialiasing = ClientPrefs.globalAntialiasing;
		add(tipText);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(20, 0, options[i], true);
			optionText.screenCenter(Y);
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionText.x -=300;
			grpOptions.add(optionText);
		}

		changeSelection();
		ClientPrefs.saveSettings();

		addTouchPad("UP_DOWN", "A_B_C");

		super.create();
		
		for (item in grpOptions.members) {
		FlxTween.tween(item, {x: item.x + 340}, 0.6, {
								ease: FlxEase.backInOut,
								onComplete: function(twn:FlxTween)
								{
									FlxTween.tween(item, {x: item.x - 40}, 0.6, {
								ease: FlxEase.backInOut});
								}
				   });
		}
	}

	override function closeSubState() {
		super.closeSubState();
		persistentUpdate = true;
		removeTouchPad();
		addTouchPad("UP_DOWN", "A_B_C");
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}

		if (touchPad != null && touchPad.buttonC.justPressed) {
			touchPad.active = touchPad.visible = persistentUpdate = false;
			openSubState(new mobile.MobileControlSelectSubState());
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.color = 0xFFFFFF;
			if (item.targetY == 0) {
				item.alpha = 0.6;
				item.color = 0xAA5F19;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
