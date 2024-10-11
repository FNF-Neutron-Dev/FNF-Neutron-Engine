package backend.assets;

import backend.assets.AssetLibrary as NuetronAssetLibrary;
import backend.assets.AssetLibrary.Library;
import backend.assets.Assets;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.Path;
import lime.media.AudioBuffer;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.ByteArray;
#if cpp
import cpp.vm.Gc;
#end

// TODO add more functions

@:access(lime.utils.Assets)
@:access(flixel.system.frontEnds.BitmapFrontEnd)
@:access(flixel.sound.FlxSound)
/**
 * Helper class for caching assets and retriving them.
 */
class Paths
{
	/**
	 * Setup the default fallback assets cache.
	 */
	@:noCompletion @:dox(show)
	public static function cacheFallbackAssets():Void
	{
		if (!OpenFLAssets.cache.hasSound('flixel-beep'))
			OpenFLAssets.cache.setSound('flixel-beep', OpenFLAssets.getSound("flixel/sounds/beep.ogg"));
		if (!OpenFLAssets.cache.hasBitmapData('flixel-logo'))
			OpenFLAssets.cache.setBitmapData('flixel-logo', new FlixelLogo(16, 16));
	}

	/**
	 * Clears everything that has been cached from bitmaps, sounds and fonts.
	 */
	public static inline function clearMemory():Void
	{
		clearBitmapsCache(true, false);
		clearSoundCache(true, false);
		OpenFLAssets.cache.clearFont();
		OpenFLSystem.gc();
		#if cpp
		Gc.compact();
		#end
	}

	/**
	 * Create and return a `FlxGraphic` object.
	 * @param key The name/path of the image in `assets/images/`
	 * @return    A `FlxGraphic` with the bitmap in the path of `key`.
	 */
	public static function graphic(key:String):FlxGraphic
	{
		var bitmap:BitmapData = getBitmapData(key);
		var assetKey:String = bitmap.key;

		if (FlxG.bitmap.checkCache(assetKey))
			return FlxG.bitmap.get(assetKey);

		var graphic:FlxGraphic = FlxG.bitmap.add(bitmap, false, assetKey);
		graphic.persist = false;
		graphic.destroyOnNoUse = false;
		return graphic;
	}

	/**
	 * Cache and return a `FlxSound` object that plays the sound refrenced by `key` in `assets/sounds/`
	 * @param key         The name/path of the sound in `assets/sounds/`.
	 * @param volume      The volume of the sound.
	 * @param loop        Wethere the sound should loop.
	 * @param autoDestroy Wether to destroy this sound when it finishs playing. Leave it to `false` if you want to use this sound instance multiple times.
	 * @return       A `FlxSound` with the sound of `key`.
	 */
	public static inline function sound(key:String, ?volume:Float = 1.0, ?loop:Bool = false, autoDestroy:Bool = false):FlxSound
	{
		return FlxG.sound.load(getSound(key, NuetronAssetLibrary.SOUNDS), volume, loop, null, autoDestroy);
	}

	public static function getContent(key:String, extension:String, ?library:Library)
	{
		var file:String = Assets.getPath(Path.withExtension(key, extension), library);
		var location:AssetLocation = Assets.checkFileLocation(file, library);

		#if sys
		if (location == FILE_SYSTEM || location == BOTH)
			return File.getContent(Assets.stripLibrary(file));
		#end

		if (location == ASSET_LIBRARY)
			return OpenFLAssets.getText(file);

		if (location == NONE)
			NeutronLogger.warn('Tried to get the content of a text file from $file${library.name == null ? ' in the library ${library.name}' : ""} but it dosen\'t exist anywhere on the FileSystem or AssetLibrary');

		return "EOF";
	}

	/**
	 * Create a `FlxAtlasFrames` for the sprite sheet refrence by `key`.
	 * @param key The name/path of the spritesheet in `assets/images/`
	 * @return    A `FlxAtlasFrames` with the frames of `key`.
	 */
	public static function getSparrowAtlas(key:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = graphic(key);
		var xml:String = getContent(key, "xml", Assets.getAssetLibrary(graphic.key));

		return FlxAtlasFrames.fromSparrow(graphic, xml);
	}

	/**
	 * Cache a BitmapData
	 * @param key The name/path of the bitmap in `assets/images/`
	 * @return    The bitmap that has been cached, or flixel logo if it dosen't exist
	 */
	public static function getBitmapData(key:String, ?library:Library):BitmapData
	{
		library = NuetronAssetLibrary.getUsableLibrary(library, NuetronAssetLibrary.IMAGES_USAGE);

		var extension:Null<String> = (Path.extension(key) == null || Path.extension(key) == '') ? 'png' : null;
		var assetPath:String = Assets.getPath(extension == null ? key : '$key.$extension', library);
		var assetKey:String = Assets.stripLibrary(assetPath);

		if (OpenFLAssets.cache.hasBitmapData(assetKey))
			return OpenFLAssets.cache.getBitmapData(assetKey);

		var bitmap:BitmapData = null;
		var bitmapBytes:ByteArray = Assets.getBitmapBytes(assetPath, library);

		if (bitmapBytes == null)
		{
			return OpenFLAssets.cache.getBitmapData('flixel-logo');
		}

		bitmap = BitmapData.fromBytes(bitmapBytes);
		bitmapBytes.clear();

		if (bitmap.width > FlxG.bitmap.maxTextureSize || bitmap.height > FlxG.bitmap.maxTextureSize)
		{
			NeutronLogger.warn("The bitmap with the key of '"
				+ assetKey
				+ "' has a size that's larger than the device's maxTextureSize.\nIssues drawing the object may accure.");
		}

		bitmap.key = assetKey;
		OpenFLAssets.cache.setBitmapData(assetKey, bitmap);

		return bitmap;
	}

	/**
	 * Cache a openfl `Sound` object refrence by `key`.
	 * @param key     The name/path of the sound in `assets/sounds/` or `assets/music/`
	 * @param library The library to cache the sound from.
	 * @return        The `Sound` that has been cached, or a flixel beep sound if it dosen't exists.
	 */
	public static function getSound(key:String, ?library:Library):Sound
	{
		library = NuetronAssetLibrary.getUsableLibrary(library, NuetronAssetLibrary.AUDIO_USAGE);

		var assetPath:String = Assets.getPath('$key.ogg', library);
		var assetKey:String = Assets.stripLibrary(assetPath);

		if (OpenFLAssets.cache.hasSound(assetKey))
			return OpenFLAssets.cache.getSound(assetKey);

		var soundBytes:ByteArray = Assets.getAudioBufferBytes(assetPath, library);

		if (soundBytes == null)
		{
			return OpenFLAssets.cache.getSound('flixel-beep');
		}

		var sound:Sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(soundBytes));
		soundBytes.clear();

		OpenFLAssets.cache.setSound(assetKey, sound);
		sound.key = assetKey;

		return sound;
	}

	/**
	 * Clears bitmaps cache
	 * @param allBitmaps Wethere it should clear every bitmap that has been cached so far (including the bitmaps tht should persist).
	 * @param runGC      Wethere it should run the Garbage Collector to clear memory properly.
	 * 
	 */
	public static function clearBitmapsCache(?allBitmaps:Bool = false, ?runGC:Bool = true):Void
	{
		if (allBitmaps)
		{
			OpenFLAssets.cache.clearBitmapData();
			FlxG.bitmap.clearCache();
			FlxG.bitmap.reset();
		}
		else
		{
			FlxG.bitmap.clearUnused();

			for (key in FlxG.bitmap._cache.keys())
			{
				if (FlxG.bitmap.checkCache(key))
					FlxG.bitmap.removeIfNoUse(FlxG.bitmap.get(key));

				if (!FlxG.bitmap.checkCache(key))
					OpenFLAssets.cache.removeBitmapData(key);
			}
		}

		cacheFallbackAssets();

		if (runGC)
			OpenFLSystem.gc();
	}

	/**
	 * Clear sounds cache
	 * @param allSounds Wethere it should clear EVERY sound that has been cached so far.
	 * @param runGC     Wethere it should run the Garbage Collector to clear memory properly.
	 */
	public static function clearSoundCache(?allSounds:Bool = false, ?runGC:Bool = true):Void
	{
		if (allSounds)
		{
			OpenFLAssets.cache.clearSound();
		}
		else
		{
			var soundsToIgnore:Array<String> = [];
			FlxG.sound.list.forEachAlive((sound:FlxSound) -> soundsToIgnore.push(sound._sound.key));
			for (sound in FlxG.sound.defaultSoundGroup.sounds)
				if (!soundsToIgnore.contains(sound._sound.key))
					soundsToIgnore.push(sound._sound.key);
			for (sound in FlxG.sound.defaultMusicGroup.sounds)
				if (!soundsToIgnore.contains(sound._sound.key))
					soundsToIgnore.push(sound._sound.key);

			for (key in OpenFLAssets.cache.sound.keys())
			{
				if (!soundsToIgnore.contains(key))
					OpenFLAssets.cache.removeSound(key);
			}
		}

		cacheFallbackAssets();

		if (runGC)
			OpenFLSystem.gc();
	}
}

@:noCompletion @:keep @:bitmap("assets/images/logo/default.png")
class FlixelLogo extends BitmapData
{
}
