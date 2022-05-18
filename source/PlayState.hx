package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

class PlayState extends FlxState
{
	// == Entities ==
	public var player:FlxSprite;

	// == Level related variables ==
	var container:FlxSpriteGroup;
	var collider:FlxSpriteGroup;
	var background:FlxSpriteGroup;

	override public function create()
	{
		super.create();

		setupWorld();
	}

	function setupWorld()
	{
		// Create project instance
		var project = new LdtkProject();

		// Iterate all world levels
		for (level in project.levels)
		{
			// Create a FlxGroup for all level layers
			container = new flixel.group.FlxSpriteGroup();

			// Place it using level world coordinates (in pixels)
			container.x = level.worldX;
			container.y = level.worldY;

			// Attach level background image, if any
			if (level.hasBgImage())
				container.add(level.getBgSprite());

			// Render layer "Background"
			// level.l_Cavern_background.render(container);

			createEntities(level.l_Entities);

			// Render layer "Collisions"
			level.l_Tiles.render(container); // l_Collisions.render(container);

			// Render layer "Custom_Tiles"
			// level.l_Custom_tiles.render(container);
		}

		for (tile in container)
		{
			tile.immovable = true;
		}

		add(container);
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

		player = new Player(x, y);
		add(player);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.collide(container, player);
	}
}
