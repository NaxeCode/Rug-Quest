package enemy.enemies;

import enemy.states.Grounded;
import flixel.util.FlxColor;

class Slime extends Grounded
{
	public function new(X:Int = 0, Y:Int = 0, ?Health:Int = 10, ?DMG:Int = 2)
	{
		super(X, Y, Health, DMG);
		makeGraphic(32, 32, FlxColor.RED);
	}
}
