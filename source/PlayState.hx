package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;

class PlayState extends FlxState
{
	// == Entities ==
	public var _player:FlxSprite;

	var _bullets:FlxTypedGroup<Bullet>;
	var _littleGibs:FlxEmitter;

	// == Level related variables ==
	var collider:FlxSpriteGroup;
	var foreground:FlxSpriteGroup;
	var tiles:FlxSpriteGroup;
	var background:FlxSpriteGroup;

	override public function create()
	{
		super.create();

		setupGibs();
		setupBullets();
		setupWorld();
		addGibs();
		addPlayer();
		addBullets();
	}

	function setupGibs()
	{
		// Here we are creating a pool of 100 little metal bits that can be exploded.
		// We will recycle the crap out of these!
		_littleGibs = new FlxEmitter();
		_littleGibs.velocity.set(-150, -200, 150, 0);
		_littleGibs.angularVelocity.set(-720);
		_littleGibs.acceleration.set(0, 350);
		_littleGibs.elasticity.set(0.5);
		_littleGibs.loadParticles(AssetPaths.gibs__png, 100, 10, true);
	}

	function setupBullets()
	{
		_bullets = new FlxTypedGroup<Bullet>(20);
	}

	function setupWorld()
	{
		// Create project instance
		var project = new LdtkProject();
		var level = project.all_levels.Level_0;

		// Create a FlxGroup for all level layers
		collider = new FlxSpriteGroup(); // Added later

		background = new FlxSpriteGroup();
		add(background); // Added first

		tiles = new FlxSpriteGroup();
		add(tiles); // Added in the middle

		foreground = new FlxSpriteGroup();
		add(foreground); // Added last

		// Iterate all world levels
		// Place it using level world coordinates (in pixels)
		collider.setPosition(level.worldX, level.worldY);
		tiles.setPosition(level.worldX, level.worldY);
		background.setPosition(level.worldX, level.worldY);
		foreground.setPosition(level.worldX, level.worldY);

		// Attach level background image, if any
		if (level.hasBgImage())
			background.add(level.getBgSprite());

		createEntities(level.l_Entities);

		// Render layer "Collisions"
		level.l_Collision.render(collider);

		// Render layer "Foreground"
		level.l_Foreground.render(foreground);

		// Render layer "Custom_Tiles"
		level.l_Tiles.render(tiles);

		// Render layer "Background"
		level.l_Background.render(background);

		/* for (level in project.all_levels.Level_0.)
			{
				
		}*/

		for (tile in collider)
			tile.immovable = true;
		add(collider);

		// trace(level);
		FlxG.camera.setScrollBoundsRect(0, 0, 4896, 1216, true);
	}

	function createEntities(entityLayer:LdtkProject.Layer_Entities)
	{
		var x:Int;
		var y:Int;

		// x = entityLayer.all_Noah[0].pixelX;
		// y = entityLayer.all_Noah[0].pixelY;

		// npcs = new FlxTypedGroup<NPC>();

		// noah = new NPC(x, y);
		// noah.text = entityLayer.all_Noah[0].f_string;
		// noah.loadGraphic(AssetPaths.Noah__png, false, 32, 64);
		// trace(noah.width);
		// trace(noah.height);
		// noah.setFacingFlip(FlxObject.LEFT, true, false);
		// noah.setFacingFlip(FlxObject.RIGHT, false, false);

		// npcs.add(noah);
		// add(noah);

		// noah.facing = FlxObject.LEFT;

		x = entityLayer.all_Player[0].pixelX;
		y = entityLayer.all_Player[0].pixelY;

		_player = new Player(x, y, _bullets, _littleGibs);
	}

	function addGibs()
	{
		add(_littleGibs);
	}

	var world_X:Float = 0;
	var world_Y:Float = 0;
	var world_WIDTH:Float = 1216;
	var world_HEIGHT:Float = 4896;

	function addPlayer()
	{
		// Then we add the player and set up the scrolling camera,
		// which will automatically set the boundaries of the world.
		add(_player);

		FlxG.camera.follow(_player, PLATFORMER);
	}

	function addBullets()
	{
		add(_bullets);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.collide(collider, _player);
	}
}
