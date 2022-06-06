package introStates;

import flixel.FlxG;
import flixel.FlxState;
import gameStates.PlayState;

class MenuState extends FlxState
{
	override function create()
	{
		FlxG.switchState(new PlayState());
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
