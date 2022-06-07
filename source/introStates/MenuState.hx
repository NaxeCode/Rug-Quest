package introStates;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import gameStates.PlayState;

class MenuState extends FlxState
{
	override function create()
	{
		var t = new FlxText(0, 0);
		t.text = "Rug Quest - Press Enter";
		t.setFormat(null, 35);
		t.screenCenter();
		add(t);
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER)
			FlxG.switchState(new PlayState());
		super.update(elapsed);
	}
}
