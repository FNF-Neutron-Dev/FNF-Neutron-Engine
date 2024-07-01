package backend.assets;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import frontend.system.Log;
import haxe.io.Path;
import openfl.display.BitmapData;
import openfl.media.Sound;
import lime.utils.AssetType;

// TODO add more functions
class Paths
{
	@:noCompletion @:dox(show)
	private static var initialized:Bool = false;

	/**
	 * Enable the OpenFL/Lime AssetLibrary cache system and Initialize the default fallback assets cache.
	 */
	@:noCompletion @:dox(show)
	public static function init():Void
	{
		if (!initialized)
		{
			initialized = true;
			OpenFLAssets.cache.enabled = true;
			LimeAssets.cache.enabled = true;
			OpenFLAssets.cache.setSound('flixel-beep', OpenFLAssets.getSound("flixel/sounds/beep.ogg"));
			OpenFLAssets.cache.setBitmapData('flixel-logo', new FlixelLogo(16, 16));
		}
		else
			Log.warn("Tried to initialize Paths but it's already initialized.");
	}

	/**
	 * Clears everything that has been cached from bitmaps, sounds and fonts.
	 */
	public static inline function clearMemory():Void
	{
		clearBitmapsCache(true);
		clearSoundCache();
		for (key in LimeAssets.cache.font.keys())
			OpenFLAssets.cache.removeFont(key);
	}

	/**
	 * Create and return a `FlxGraphic` object.
	 * @param key            The name/path of the image in `assets/images/`
	 * @param shouldPersist  Wethere the graphic should stay in memory even after it has been destroyed or get dumpped instantly.
	 * @param destroyOnNoUse Wethere the graphic should be destroyed when it's unused or stay.
	 * @return `FlxGraphic`
	 */
	public static function graphic(key:String, ?shouldPersist:Bool = false, ?destroyOnNoUse:Bool = true):FlxGraphic
	{
		var bitmap:BitmapData = getBitmapData(key);
		var assetKey:String = null;

		for (iKey in LimeAssets.cache.image.keys())
		{
			if (LimeAssets.cache.image.get(iKey) == bitmap.image)
			{
				assetKey = iKey;
				break;
			}
		}

		if (FlxG.bitmap.checkCache(assetKey))
			return FlxG.bitmap.get(assetKey);

		var graphic:FlxGraphic = FlxG.bitmap.add(bitmap, false, assetKey);
		graphic.persist = shouldPersist;
		graphic.destroyOnNoUse = destroyOnNoUse;
		return graphic;
	}

	/**
	 * Cache and return a `FlxSound` object that plays the sound refrenced by `key` in `assets/sounds/`
	 * @param key    The name/path of the sound in `assets/sounds/`.
	 * @param volume The volume of the sound.
	 * @param loop   Wethere the sound should loop or not.
	 * @return `FlxSound`
	 */
	public static inline function sound(key:String, ?volume:Float = 1.0, ?loop:Bool = false):FlxSound
	{
		return FlxG.sound.load(getSound(key), volume, loop);
	}

	/**
	 * Create a `FlxAtlasFrames` for the sprite sheet refrence by `key`.
	 * @param key            The name/path of the spritesheet in `assets/images/`
	 * @param shouldPersist  Wethere the spritesheet's graphic should stay in memory even after it has been destroyed or get dumpped instantly.
	 * @param destroyOnNoUse Wethere the spritesheet's graphic should be destroyed when it's unused or stay.
	 * @return `FlxAtlasFrames`
	 */
	public static function getSparrowAtlas(key:String, ?shouldPersist:Bool = false, ?destroyOnNoUse:Bool = true):FlxAtlasFrames
	{
		var graphic:FlxGraphic = graphic(key, shouldPersist, destroyOnNoUse);
		var xmlPath:String = Path.withExtension(Path.withoutExtension(graphic.key), "xml");
		var location:AssetLocation = checkFileLocation(xmlPath, "images");
		var xml:String = "";

		if (location == ASSET_LIBRARY || location == BOTH)
			xml = OpenFLAssets.getText('images:$xmlPath')
		#if sys
		else if (location == FILE_SYSTEM)
			xml = File.getContent(xmlPath)
		#end
	else
		Log.warn("Tried to parse a sparrow atlas sprite sheet but the XML animations file dosen't exist.");

		return FlxAtlasFrames.fromSparrow(graphic, xml);
	}

	/**
	 * Cache a BitmapData
	 * @param key The name/path of the bitmap in `assets/images/`
	 * @return The bitmap that has been cached, or flixel logo if it dosen't exist
	 */
	public static function getBitmapData(key:String):BitmapData
	{
		var bitmap:BitmapData = null;
		var assetKey:String = 'assets/images/$key.png';
		var location:AssetLocation = checkFileLocation(key, 'images');

		if (OpenFLAssets.cache.hasBitmapData(assetKey))
			return OpenFLAssets.cache.getBitmapData(assetKey);

		if (location == ASSET_LIBRARY || location == BOTH)
			bitmap = OpenFLAssets.getBitmapData('images:$key');
		#if sys
		else if (location == FILE_SYSTEM)
			bitmap = BitmapData.fromFile(key);
		#end

		if (bitmap != null)
		{
			#if !flash
			if (bitmap.width > FlxG.bitmap.maxTextureSize || bitmap.height > FlxG.bitmap.maxTextureSize)
				Log.warn("The bitmap with the key of '"
					+ assetKey
					+ "' has a size that's larger than the device's maxTextureSize, Issues drawing the object might happen.");
			#end

			OpenFLAssets.cache.setBitmapData(assetKey, bitmap);
		}

		if (location == NONE)
		{
			Log.warn("Tried to load a bitmap with the key of " + assetKey + " but it dosen't exist anywhere on the FileSystem or Asset Library.");
			bitmap = OpenFLAssets.cache.getBitmapData('flixel-logo');
		}

		return bitmap;
	}

	/**
	 * Cache a openfl `Sound` object refrence by `key`.
	 * @param key  The name/path of the sound in `assets/sounds/` or `assets/music/`
	 * @param type Can be either `SOUNDS` or `MUSIC`, if it's `SOUNDS` then `assets/sounds/` will be used to cache the sound, otherwise `assets/music/` is used.
	 * @return the `Sound` that has been cached, or a flixel beep sound if it dosen't exists.
	 */
	public static function getSound(key:String, type:Library = SOUNDS):Sound
	{
		if (type != MUSIC && type != SOUNDS)
		{
			Log.warn("Tried to play a sound using a library type of " + type.getName() + ", defaulting to SOUNDS");
			type = SOUNDS;
		}

		var sound:Sound = null;
		var library:String = type.getName().toLowerCase();
		var assetKey:String = 'assets/$library/$key.ogg';
		var location:AssetLocation = checkFileLocation(assetKey, library);

		if (OpenFLAssets.cache.hasSound(assetKey))
			return OpenFLAssets.cache.getSound(assetKey);

		if (location == ASSET_LIBRARY || location == BOTH)
			sound = OpenFLAssets.getSound('$library:$assetKey');
		#if sys
		else if (location == FILE_SYSTEM)
			sound = Sound.fromFile(assetKey);
		#end

		if (sound != null)
			OpenFLAssets.cache.setSound(assetKey, sound);

		if (location == NONE)
		{
			Log.warn("Tried to load a sound with the key of " + assetKey + " but it dosen't exist anywhere on the FileSystem or Asset Library.");
			sound = OpenFLAssets.cache.getSound('flixel-beep');
		}

		return sound;
	}

	/**
	 * Checks where the file precisely exists.
	 * @param path    The path of the file to check for.
	 * @param library The library to use when checking for the file in the OpenFL/Lime AssetLibrary.
	 * @return if the file exists in the OpenFL/Lime AssetLibrary, returns `ASSET_LIBRARY`. If it's in the filesystem only, returns `FILE_SYSTEM`. If both, returns `BOTH`, otherwise returns `NONE`.
	 */
	public static function checkFileLocation(path:String, ?library:String):AssetLocation
	{
		var al:Bool = OpenFLAssets.exists(library == null ? path : '$library:$path');
		#if sys
		var fs:Bool = FileSystem.exists(path);
		if (fs && al)
			return BOTH;
		if (!fs && al)
			return ASSET_LIBRARY;
		if (fs && !al)
			return FILE_SYSTEM;
		return NONE;
		#else
		if (al)
			return ASSET_LIBRARY;
		return NONE;
		#end
	}

	/**
	 * Clears bitmaps cache
	 * @param allBitmaps Wethere it should clear every bitmap that has been cached so far (including the bitmaps tht should persist) or only what's unused.
	 */
	public static function clearBitmapsCache(?allBitmaps:Bool = false):Void
	{
		@:privateAccess
		var bitmapCache = FlxG.bitmap._cache;

		if (allBitmaps)
		{
			for (key in bitmapCache.keys())
				OpenFLAssets.cache.removeBitmapData(key);

			FlxG.bitmap.clearCache();
			FlxG.bitmap.reset();
		}
		else
		{
			FlxG.bitmap.clearUnused();
			for (graphic in bitmapCache)
			{
				var key:String = graphic.key;
				if (FlxG.bitmap.checkCache(key))
				{
					FlxG.bitmap.removeIfNoUse(graphic);
					if (!FlxG.bitmap.checkCache(key))
						OpenFLAssets.cache.removeBitmapData(key);
				}
			}
		}

		if (!OpenFLAssets.cache.hasBitmapData('flixel-logo'))
			OpenFLAssets.cache.setBitmapData('flixel-logo', new FlixelLogo(16, 16));
	}

	/**
	 * Clear the cache of every sound that has been cached so far.
	 */
	public static inline function clearSoundCache():Void
	{
		for (key in LimeAssets.cache.audio.keys())
			OpenFLAssets.cache.removeSound(key);
		OpenFLAssets.cache.setSound('flixel-beep', OpenFLAssets.getSound("flixel/sounds/beep.ogg"));
	}
}

@:dox(hide)
enum AssetLocation
{
	FILE_SYSTEM;
	ASSET_LIBRARY;
	BOTH;
	NONE;
}

@:dox(hide)
enum Library
{
	IMAGES;
	SOUNDS;
	MUSIC;
	DATA;
}

@:noCompletion @:keep @:bitmap("assets/images/logo/default.png")
class FlixelLogo extends BitmapData {}
