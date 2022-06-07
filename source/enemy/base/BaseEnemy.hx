package enemy.base;

import flixel.FlxSprite;

class BaseEnemy extends FlxSprite
{
	public var dmg:Int = 1;

	public function new(X:Int = 0, Y:Int = 0, Health:Int = 1, DMG:Int = 1)
	{
		health = Health;
		dmg = DMG;
		super(X, Y);
	}
}
