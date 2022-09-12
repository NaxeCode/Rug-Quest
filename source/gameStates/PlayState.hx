package gameStates;

import enemy.base.BaseEnemy;
import enemy.enemies.Slime;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.tile.FlxTilemap.FlxTilemap;
import flixel.util.FlxColor;
import player.Bullet;
import player.Player;

using flixel.util.FlxSpriteUtil;

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

	// Cameras
	public static var gameCamera:FlxCamera;

	private var hud:HUD;
	var uiCamera:FlxCamera;

	override public function create()
	{
		super.create();

		setupDebug();
		setupCameras();
		setupHUD();
		setupGibs();
		setupBullets();
		setupWorld();
		addGibs();
		addPlayer();
		addBullets();
	}

	function setupDebug()
	{
		FlxG.log.redirectTraces = true;
	}

	function setupCameras()
	{
		gameCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		uiCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);

		gameCamera.bgColor = 0xFF17142d;
		uiCamera.bgColor = FlxColor.TRANSPARENT;
	}

	function setupHUD()
	{
		hud = new HUD();
		add(hud);
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
	}

	private var enemies:FlxSpriteGroup;

	function createEntities(entityLayer:LdtkProject.Layer_Entities)
	{
		enemies = new FlxSpriteGroup();
		add(enemies);
		var x:Int;
		var y:Int;

		for (char in entityLayer.all_Enemy_1)
		{
			x = char.pixelX;
			y = char.pixelY;

			var enemy = new Slime(x, y, char.f_Health, char.f_Dmg);
			enemies.add(enemy);
		}

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

		enableCameras();
	}

	function enableCameras()
	{
		gameCamera.follow(_player);
		var w:Float = (gameCamera.width / 64);
		var h:Float = (gameCamera.height / 5);
		gameCamera.deadzone = FlxRect.get((gameCamera.width - w) / 2, (gameCamera.height - h) / 2 - h * 0.25, w, h);
		gameCamera.zoom = 2;

		var canvas = new FlxSprite();
		canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(canvas);

		var lineStyle:LineStyle = {color: FlxColor.RED, thickness: 1};
		var drawStyle:DrawStyle = {smoothing: true};

		canvas.drawRect(gameCamera.deadzone.x, gameCamera.deadzone.y, gameCamera.deadzone.width, gameCamera.deadzone.height, FlxColor.TRANSPARENT, lineStyle,
			drawStyle);

		FlxG.cameras.add(gameCamera);
		FlxG.cameras.add(uiCamera, false);

		gameCamera.cameras = [uiCamera];
		gameCamera.camera.setScrollBoundsRect(0, 0, 4896, 1216, true);
		canvas.cameras = [uiCamera];
		hud.cameras = [uiCamera];

		hud.scrollFactor.set(0, 0);

		gameCamera.fade(FlxColor.BLACK, 0.1, true);
	}

	function addBullets()
	{
		add(_bullets);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.overlap(enemies, _player, playerHurt);
		FlxG.collide(collider, _player);
	}

	function playerHurt(enm:BaseEnemy, plr:Player)
	{
		plr.health -= enm.dmg;
		if (plr.facing == FlxObject.LEFT)
		{
			plr.velocity.x += 50;
		}
		else if (plr.facing == FlxObject.RIGHT)
		{
			plr.velocity.x -= 50;
		}
		plr.velocity.y = -200;
	}
}
