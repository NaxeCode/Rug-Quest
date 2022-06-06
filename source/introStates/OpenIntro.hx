package introStates;

import flixel.FlxG;
import flixel.FlxState;

class OpenIntro extends FlxState
{
	override function create()
	{
		// Intro cutscene should be here
		super.create();
		FlxG.switchState(new MenuState());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
