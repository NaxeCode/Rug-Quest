package enemy.states;

import enemy.base.BaseEnemy;

class Grounded extends BaseEnemy
{
	public function new(X:Int = 0, Y:Int = 0, Health:Int = 1, DMG:Int = 1)
	{
		super(X, Y, Health, DMG);
	}
}
