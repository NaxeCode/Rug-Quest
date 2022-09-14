package player;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionManager;
import flixel.system.FlxAssets;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import gameStates.HUD;
import gameStates.Reg;
import utils.Flx8Direction;
#if VIRTUAL_PAD
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxDestroyUtil;
#end

class Player extends FlxSprite
{
	#if VIRTUAL_PAD
	public static var virtualPad:FlxVirtualPad;
	#end

	static var actions:FlxActionManager;
	static var FIRE_RATE:Float = 1 / 10; // 10 shots per second

	public var isReadyToJump:Bool = true;
	public var flickering:Bool = false;

	var _shootTimer = new FlxTimer();
	var _shootAnimTimer = new FlxTimer();
	var _jumpPower:Int = 250;
	var _aim = Flx8Direction.RIGHT;
	var _gibs:FlxEmitter;
	var _bullets:FlxTypedGroup<Bullet>;

	var _up:FlxActionDigital;
	var _down:FlxActionDigital;
	var _left:FlxActionDigital;
	var _right:FlxActionDigital;
	var _shoot:FlxActionDigital;

	public var _jump:FlxActionDigital;

	/**
	 * This is the player object class.  Most of the comments I would put in here
	 * would be near duplicates of the Enemy class, so if you're confused at all
	 * I'd recommend checking that out for some ideas!
	 */
	public function new(x:Int, y:Int, bullets:FlxTypedGroup<Bullet>, gibs:FlxEmitter)
	{
		super(x, y);

		loadGraphic(AssetPaths.scalene_CLEAN_fixed__png, true, 80, 50);

		setFacingFlip(LEFT, true, false);
		setFacingFlip(RIGHT, false, false);

		// Bounding box tweaks
		// centerOffsets(true);
		width = 16;
		height = 16;
		offset.set(35, 30);

		// Basic player physics
		var runSpeed:Int = 80;
		drag.x = runSpeed * 8;
		acceleration.y = 420;
		maxVelocity.set(runSpeed * 3, _jumpPower * 2);

		// Animations
		var fps = 8;
		animation.add(Animation.IDLE, [0], fps);
		animation.add(Animation.WALK, [1, 2, 3, 4], fps);
		// 0.375
		animation.add(Animation.JUMP_AIR, [5], fps);
		animation.add(Animation.JUMP_IDLE, [6], fps);

		animation.add(Animation.SHOOT, [7, 8, 9], fps);
		animation.add(Animation.SHOOT_UP, [10, 11], fps);
		animation.add(Animation.SHOOT_DOWN, [12, 13], fps);
		animation.add(Animation.SHOOT_DIAG_UP, [14, 15], fps);
		animation.add(Animation.SHOOT_DIAG_DOWN, [16, 17], fps);

		animation.add(Animation.JUMP_RECOIL, [18], fps);
		animation.add(Animation.HURT, [19], fps);
		animation.add(Animation.DEATH, [20], fps);

		// Bullet stuff
		_bullets = bullets;
		_gibs = gibs;

		_up = new FlxActionDigital().addGamepad(DPAD_UP, PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_UP, PRESSED)
			.addKey(UP, PRESSED)
			.addKey(W, PRESSED);

		_down = new FlxActionDigital().addGamepad(DPAD_DOWN, PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_DOWN, PRESSED)
			.addKey(DOWN, PRESSED)
			.addKey(S, PRESSED);

		_left = new FlxActionDigital().addGamepad(DPAD_LEFT, PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_LEFT, PRESSED)
			.addKey(LEFT, PRESSED)
			.addKey(A, PRESSED);

		_right = new FlxActionDigital().addGamepad(DPAD_RIGHT, PRESSED)
			.addGamepad(LEFT_STICK_DIGITAL_RIGHT, PRESSED)
			.addKey(RIGHT, PRESSED)
			.addKey(D, PRESSED);

		_jump = new FlxActionDigital().addGamepad(A, JUST_PRESSED).addKey(X, JUST_PRESSED);

		_shoot = new FlxActionDigital().addGamepad(X, JUST_PRESSED).addKey(C, JUST_PRESSED);

		#if VIRTUAL_PAD
		virtualPad = new FlxVirtualPad(FULL, A_B);
		virtualPad.alpha = 0.5;

		_up.addInput(virtualPad.buttonUp, PRESSED);
		_down.addInput(virtualPad.buttonDown, PRESSED);
		_left.addInput(virtualPad.buttonLeft, PRESSED);
		_right.addInput(virtualPad.buttonRight, PRESSED);
		_jump.addInput(virtualPad.buttonA, JUST_PRESSED);
		_shoot.addInput(virtualPad.buttonB, PRESSED);
		#end

		if (actions == null)
			actions = FlxG.inputs.add(new FlxActionManager());
		actions.addActions([_up, _down, _left, _right, _jump, _shoot]);
	}

	override public function update(elapsed:Float):Void
	{
		acceleration.x = 0;
		updateInput();
		updateMP();
		updateAnimations();
		super.update(elapsed);
	}

	function updateInput()
	{
		if (_left.triggered)
			moveLeft();
		else if (_right.triggered)
			moveRight();

		if (_up.triggered)
			moveUp();
		else if (_down.triggered)
			moveDown();

		if (_jump.triggered)
			jump();
		if (_shoot.triggered)
			shoot();
	}

	function updateMP()
	{
		if (this.justTouched(FLOOR) && HUD.mp < HUD.maxMp)
		{
			HUD.mp = HUD.maxMp;
		}
	}

	function updateAnimations():Void
	{
		trace(_shootAnimTimer.active);
		var direction_x:Int; // negative = left, positive = right
		if (velocity.x > 0)
			direction_x = 1;
		else if (velocity.x < 0)
			direction_x = -1;
		else
			direction_x = 0;

		var direction_y:Int; // negative = up, positive = down
		if (velocity.y > 0)
			direction_y = 1;
		else if (velocity.y < 0)
			direction_y = -1;
		else
			direction_y = 0;

		if (isTouching(FlxObject.FLOOR))
		{
			if (direction_x == 0)
			{
				if (_shootAnimTimer.active)
				{
					if (_aim == UP)
					{
						animation.play(Animation.SHOOT_UP);
					}
					else if (_aim == DOWN)
					{
						animation.play(Animation.SHOOT_DOWN);
					}
				}
				else
				{
					animation.play(Animation.IDLE);
				}
			}
			else
			{
				if (_shootAnimTimer.active)
				{
					if (_aim == UPLEFT || _aim == UPRIGHT)
					{
						animation.play(Animation.SHOOT_DIAG_UP);
					}
					else if (_aim == DOWNLEFT || _aim == DOWNRIGHT)
					{
						animation.play(Animation.SHOOT_DIAG_DOWN);
					}
				}
				else
				{
					animation.play(Animation.WALK);
				}
			}
		}
		else
		{
			if (velocity.y < -100)
			{
				animation.play(Animation.JUMP_AIR);
			}
			if (velocity.y > -100 && velocity.y < 100)
			{
				animation.play(Animation.JUMP_IDLE);
			}
			else if (velocity.y > 100)
			{
				animation.play(Animation.JUMP_AIR);
			}
		}
	}

	override public function hurt(damage:Float):Void
	{
		damage = 0;

		if (flickering)
			return;

		// FlxG.sound.play(FlxAssets.getSound("assets/sounds/hurt"));

		flicker(1.3);

		if (Reg.score > 1000)
			Reg.score -= 1000;

		if (velocity.x > 0)
			velocity.x = -maxVelocity.x;
		else
			velocity.x = maxVelocity.x;

		super.hurt(damage);
	}

	function flicker(Duration:Float):Void
	{
		FlxSpriteUtil.flicker(this, Duration, 0.02, true, true, function(_)
		{
			flickering = false;
		});
		flickering = true;
	}

	override public function kill():Void
	{
		if (!alive)
			return;

		solid = false;
		// FlxG.sound.play(FlxAssets.getSound("assets/sounds/asplode"));
		// FlxG.sound.play(FlxAssets.getSound("assets/sounds/menu_hit_2"));

		super.kill();

		exists = true;
		active = false;
		visible = false;
		moves = false;
		velocity.set();
		acceleration.set();
		FlxG.camera.shake(0.005, 0.35);
		FlxG.camera.flash(0xffd8eba2, 0.35);

		if (_gibs != null)
		{
			_gibs.focusOn(this);
			_gibs.start(true, 0, 50);
		}

		new FlxTimer().start(2, function(_)
		{
			FlxG.resetState();
		});
	}

	function moveLeft():Void
	{
		facing = 0x0001;
		_aim = LEFT;
		acceleration.x -= drag.x;
	}

	function moveRight():Void
	{
		facing = 0x0010;
		_aim = RIGHT;
		acceleration.x += drag.x;
	}

	function moveUp():Void
	{
		if (_left.triggered)
			_aim = UPLEFT;
		else if (_right.triggered)
			_aim = UPRIGHT;
		else
			_aim = UP;
	}

	function moveDown():Void
	{
		if (_left.triggered)
			_aim = DOWNLEFT;
		else if (_right.triggered)
			_aim = DOWNRIGHT;
		else
			_aim = DOWN;
	}

	function jump():Void
	{
		if (isReadyToJump && (velocity.y == 0))
		{
			velocity.y = -_jumpPower;
			// FlxG.sound.play(FlxAssets.getSound("assets/sounds/jump"));
		}
	}

	function shoot():Void
	{
		if (!_shootAnimTimer.active)
			_shootAnimTimer.start(1);
		if (_shootTimer.active)
			return;
		_shootTimer.start(FIRE_RATE);

		if (flickering)
		{
			// FlxG.sound.play(FlxAssets.getSound("assets/sounds/jam"));
		}
		else if (HUD.mp > 0)
		{
			if (facing == LEFT)
			{
				getMidpoint(_point);
				if (_aim == UPLEFT)
				{
					_point.set(_point.x - 20, _point.y - 20);
				}
				else
				{
					_point.set(_point.x - 20, _point.y);
				}
			}
			else if (facing == RIGHT)
			{
				getMidpoint(_point);
				if (_aim == UPRIGHT)
				{
					_point.set(_point.x + 20, _point.y - 20);
				}
				else
				{
					_point.set(_point.x + 20, _point.y);
				}
			}

			_bullets.recycle(Bullet.new).shoot(_point, _aim);
			HUD.mp -= 1;

			switch (_aim)
			{
				case DOWN:
					velocity.y -= 100;

				case DOWNLEFT:
					velocity.y -= 100;
					velocity.x += 300;
				case DOWNRIGHT:
					velocity.y -= 100;
					velocity.x -= 300;

				case LEFT:
					velocity.x += 300;
				case RIGHT:
					velocity.x -= 300;

				case UP:
					velocity.y += 100;

				case UPLEFT:
					velocity.y += 100;
					velocity.x += 300;
				case UPRIGHT:
					velocity.y += 100;
					velocity.x -= 300;
			}
		}
	}

	override public function destroy():Void
	{
		super.destroy();

		#if VIRTUAL_PAD
		virtualPad = FlxDestroyUtil.destroy(virtualPad);
		#end

		_bullets = null;
		_gibs = null;
	}
}

@:enum abstract Animation(String) to String
{
	var IDLE = "idle";
	var WALK = "walk";
	var JUMP_AIR = "jump_air";
	var JUMP_IDLE = "jump_idle";
	var SHOOT = "shoot";
	var SHOOT_DOWN = "shoot_down";
	var SHOOT_UP = "shoot_up";
	var SHOOT_DIAG_UP = "shoot_diag_up";
	var SHOOT_DIAG_DOWN = "shoot_diag_down";
	var JUMP_RECOIL = "jump_recoil";
	var HURT = "hurt";
	var DEATH = "death";
}
