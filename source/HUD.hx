package;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;

class HUD extends FlxSpriteGroup
{
	private var healthDisplay:FlxText;

	private var levelDisplay:FlxText;

	private var expBar:FlxBar;
	private var exp:Int;
	private var maxExp:Int;

	private var mpBar:FlxBar;

	public static var mp:Int;

	public static var maxMp:Int = 5;

	private var hp:Int;

	public static var maxHp:Int = 25;

	private var level:Int;

	public function new()
	{
		super();

		scrollFactor.x = 0;

		scrollFactor.y = 0;

		healthDisplay = new FlxText(2, 2);
		healthDisplay.size = 15;

		hp = 5;

		maxHp = 10;

		add(healthDisplay);

		levelDisplay = new FlxText(2, 23);
		levelDisplay.size = 15;

		level = 1;

		add(levelDisplay);

		maxExp = 10;
		exp = 3;
		expBar = new FlxBar(4, 17 + 30, LEFT_TO_RIGHT, 200, 8);
		expBar.createFilledBar(0xFF63460C, 0xFFE6AA2F);
		add(expBar);

		mp = maxMp;
		mpBar = new FlxBar(4, 17 + 45, LEFT_TO_RIGHT, 200, 8);
		mpBar.createFilledBar(0xFF63460C, 0xFF75e6da);
		add(mpBar);

		// Starts the MP tick up function
		new FlxTimer().start(1, recoverMP, 0);
	}

	function recoverMP(timer:FlxTimer)
	{
		if (mp < maxMp)
			mp += 1;
	}

	override public function update(elapsed:Float)
	{
		healthDisplay.text = "Health: " + hp + "/" + maxHp;

		levelDisplay.text = "Level: " + level;

		expBar.value = exp;
		expBar.setRange(0, maxExp);

		mpBar.value = mp;
		mpBar.setRange(0, maxMp);

		super.update(elapsed);
	}

	public function addHealth(num:Int):Void
	{
		hp += num;

		if (hp > maxHp)
		{
			hp = maxHp;
		}
	}
}
