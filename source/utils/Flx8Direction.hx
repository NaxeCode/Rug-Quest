package utils;

import flixel.util.FlxDirectionFlags;

/**
 * Simple enum for orthogonal directions. Can be combined into `FlxDirectionFlags`.
 * @since 4.10.0
 */
@:enum abstract Flx8Direction(Int) to Int
{
	/*
		up+right
		up+left
		down+left
		down+right
	 */
	var LEFT = 0x0001;
	var RIGHT = 0x0010;
	var UP = 0x0100;
	var UPLEFT = 0x0101;
	var UPRIGHT = 0x0110;
	var DOWN = 0x1000;
	var DOWNLEFT = 0x1001;
	var DOWNRIGHT = 0x1010;

	public function toString() {}
}
