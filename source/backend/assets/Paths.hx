package backend.assets;

import lime.media.AudioBuffer;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;
import haxe.ds.Map;
import haxe.io.Path;
import openfl.display.BitmapData;
import openfl.media.Sound;

// TODO add more functions

@:access(lime.utils.Assets)
@:access(flixel.system.frontEnds.BitmapFrontEnd)
class Paths
{
	@:noCompletion @:dox(show)
	private static var initialized:Bool = false;

	public static var bitmapsKeys:Map<BitmapData, String> = new Map();

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
		{
			NeutronLogger.warn("Tried to initialize Paths but it's already initialized.");
		}
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
	 * @param path    The path to look up in `library`.
	 * @param library The library to use.
	 * @return        Returns `path` in the specified `library`.
	 */
	public static function getPath(path:String, ?library:Library):String
	{
		if (library == null)
			return 'assets/$path';

		var libName:String = library.getName().toLowerCase();
		return '$libName:assets/$libName/$path';
	}

	/**
	 * Removes the library from a path.
	 * @param path The path to remove the library from.
	 * @return     The path without the library.
	 */
	public static inline function stripLibrary(path:String):String
	{
		if (path.contains(':'))
			return path.split(':')[1];
		return path;
	}

	/**
	 * Get the `Library` of a Asset
	 * @param path The path of the Asset
	 * @return     The `Library` that contains `path`
	 */
	public static function getAssetLibrary(path:String):Library
	{
		for (library in Library.createAll())
		{
			var libraryName = library.getName().toLowerCase();
			if (LimeAssets.exists('$libraryName:$path'))
				return library;
		}

		return null;
	}

	/**
	 * Get the `Library` as a `String`
	 * @param library The `Library` to transform.
	 * @return        `library` as a lowercase string.
	 */
	public static inline function getLibraryName(library:Library):String
	{
		if (library == null)
			return null;
		return library.getName().toLowerCase();
	}

	/**
	 * Create and return a `FlxGraphic` object.
	 * @param key            The name/path of the image in `assets/images/`
	 * @param shouldPersist  Wethere the graphic should stay in memory or get dumpped instantly when unued.
	 * @return               A `FlxGraphic` with the bitmap in the path of `key`.
	 */
	public static function graphic(key:String, ?shouldPersist:Bool = true):FlxGraphic
	{
		var bitmap:BitmapData = getBitmapData(key);
		var assetKey:String = bitmapsKeys.get(bitmap);

		if (FlxG.bitmap.checkCache(assetKey))
			return FlxG.bitmap.get(assetKey);

		var graphic:FlxGraphic = FlxG.bitmap.add(bitmap, false, assetKey);
		graphic.persist = shouldPersist;
		graphic.destroyOnNoUse = !shouldPersist;
		return graphic;
	}

	/**
	 * Cache and return a `FlxSound` object that plays the sound refrenced by `key` in `assets/sounds/`
	 * @param key    The name/path of the sound in `assets/sounds/`.
	 * @param volume The volume of the sound.
	 * @param loop   Wethere the sound should loop or not.
	 * @return       A `FlxSound` with the sound of `key`.
	 */
	public static inline function sound(key:String, ?volume:Float = 1.0, ?loop:Bool = false):FlxSound
	{
		return FlxG.sound.load(getSound(key), volume, loop);
	}

	public static function getContent(key:String, extension:String, ?library:Library)
	{
		var file:String = getPath(Path.withExtension(key, extension), library);
		var libraryName:String = getLibraryName(library);
		var location:AssetLocation = checkFileLocation(file, library);

		#if sys
		if (location == FILE_SYSTEM || location == BOTH)
			return File.getContent(stripLibrary(file));
		#end

		if (location == ASSET_LIBRARY)
			return OpenFLAssets.getText(file);

		if (location == NONE)
			NeutronLogger.warn('Tried to get the content of a text file from $file${libraryName == null ? ' in the library $libraryName' : ""} but it dosen\'t exist anywhere on the FileSystem or AssetLibrary');

		return "null";
	}

	/**
	 * Create a `FlxAtlasFrames` for the sprite sheet refrence by `key`.
	 * @param key            The name/path of the spritesheet in `assets/images/`
	 * @param shouldPersist  Wethere the graphic should stay in memory or get dumpped instantly when unused.
	 * @return               A `FlxAtlasFrames` with the frames of `key`.
	 */
	public static function getSparrowAtlas(key:String, ?shouldPersist:Bool = true):FlxAtlasFrames
	{
		var graphic:FlxGraphic = graphic(key, shouldPersist);
		var xml:String = getContent(key, "xml", getAssetLibrary(graphic.key));

		return FlxAtlasFrames.fromSparrow(graphic, xml);
	}

	/**
	 * Cache a BitmapData
	 * @param key The name/path of the bitmap in `assets/images/`
	 * @return    The bitmap that has been cached, or flixel logo if it dosen't exist
	 */
	public static function getBitmapData(key:String):BitmapData
	{
		var bitmap:BitmapData = null;
		var assetKey:String = getPath('$key.png', IMAGES);
		var assetsKey:String = stripLibrary(assetKey);
		var library:String = getLibraryName(IMAGES);
		var location:AssetLocation = checkFileLocation(assetKey, IMAGES);

		if (OpenFLAssets.cache.hasBitmapData((assetsKey)))
			return OpenFLAssets.cache.getBitmapData(assetsKey);

		#if sys
		if (location == FILE_SYSTEM || location == BOTH)
			bitmap = BitmapData.fromBytes(File.getBytes(assetsKey));
		#end
		if (location == ASSET_LIBRARY && bitmap == null)
			bitmap = OpenFLAssets.getBitmapData(assetKey);

		if (bitmap != null)
		{
			#if !flash
			if (bitmap.width > FlxG.bitmap.maxTextureSize || bitmap.height > FlxG.bitmap.maxTextureSize)
				NeutronLogger.warn("The bitmap with the key of '"
					+ assetKey
					+ "' has a size that's larger than the device's maxTextureSize, Issues drawing the object might happen.");
			#end

			bitmapsKeys.set(bitmap, assetsKey);
			OpenFLAssets.cache.setBitmapData(assetsKey, bitmap);
		}

		if (location == NONE)
		{
			NeutronLogger.warn("Tried to load a bitmap with the key of "
				+ assetKey
				+ " but it dosen't exist anywhere on the FileSystem or the Asset Library "
				+ library
				+ '.');
			bitmap = OpenFLAssets.cache.getBitmapData('flixel-logo');
			bitmapsKeys.set(bitmap, 'flixel-logo');
		}

		return bitmap;
	}

	/**
	 * Cache a openfl `Sound` object refrence by `key`.
	 * @param key     The name/path of the sound in `assets/sounds/` or `assets/music/`
	 * @param library Can be either `SOUNDS` or `MUSIC`, if it's `SOUNDS` then `assets/sounds/` will be used to cache the sound, otherwise `assets/music/` is used.
	 * @return        The `Sound` that has been cached, or a flixel beep sound if it dosen't exists.
	 */
	public static function getSound(key:String, ?library:Library = SOUNDS):Sound
	{
		if (library != MUSIC && library != SOUNDS)
		{
			NeutronLogger.warn("Tried to play a sound using the library " + library.getName() + ", defaulting to SOUNDS");
			library = SOUNDS;
		}

		var sound:Sound = null;
		var libraryName:String = getLibraryName(library);
		var assetKey:String = getPath('$key.ogg', library);
		var assetsKey:String = stripLibrary(assetKey);
		var location:AssetLocation = checkFileLocation(assetsKey, library);

		if (OpenFLAssets.cache.hasSound(assetsKey))
			return OpenFLAssets.cache.getSound(assetsKey);

		#if sys
		if (location == FILE_SYSTEM || location == BOTH)
			sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(File.getBytes(assetsKey)));
		#end
		if (location == ASSET_LIBRARY && sound == null)
			sound = OpenFLAssets.getSound(assetKey);

		if (sound != null)
			OpenFLAssets.cache.setSound(assetsKey, sound);

		if (location == NONE)
		{
			NeutronLogger.warn("Tried to load a sound with the key of "
				+ assetKey
				+ " but it dosen't exist anywhere on the FileSystem or the Asset Library "
				+ libraryName
				+ '.');
			sound = OpenFLAssets.cache.getSound('flixel-beep');
		}

		return sound;
	}

	/**
	 * Checks where the file precisely exists.
	 * @param path    The path of the file to check for.
	 * @param library The library to use when checking for the file in the OpenFL/Lime AssetLibrary.
	 * @return        If the file exists in the OpenFL/Lime AssetLibrary, returns `ASSET_LIBRARY`. If it's in the filesystem only, returns `FILE_SYSTEM`. If both, returns `BOTH`, otherwise returns `NONE`.
	 */
	public static function checkFileLocation(path:String, ?library:Library):AssetLocation
	{
		path = stripLibrary(path);
		var libraryName:String = getLibraryName(library);
		var al:Bool = OpenFLAssets.exists(libraryName == null ? path : '$libraryName:$path');
		#if sys
		var fs:Bool = FileSystem.exists(path);
		if (fs && al)
			return BOTH;
		if (!fs && al)
			return ASSET_LIBRARY;
		if (fs && !al)
			return FILE_SYSTEM;
		#else
		if (al)
			return ASSET_LIBRARY;
		#end
		NeutronLogger.note('the asset $path Couldn\'t be located in the FileSystem or the AssetLibrary ${libraryName == null ? 'default' : libraryName}');
		return NONE;
	}

	/**
	 * Clears bitmaps cache
	 * @param allBitmaps Wethere it should clear every bitmap that has been cached so far (including the bitmaps tht should persist) or only what's unused.
	 */
	public static function clearBitmapsCache(?allBitmaps:Bool = false):Void
	{
		if (allBitmaps)
		{
			for (key in bitmapsKeys)
				OpenFLAssets.cache.clear();
			bitmapsKeys.clear();
			FlxG.bitmap.clearCache();
			FlxG.bitmap.reset();
		}
		else
		{
			FlxG.bitmap.clearUnused();

			for (graphic in FlxG.bitmap._cache)
			{
				var key:String = graphic.key;
				if (FlxG.bitmap.checkCache(key))
					FlxG.bitmap.removeIfNoUse(graphic);

				if (!FlxG.bitmap.checkCache(key))
					OpenFLAssets.cache.removeBitmapData(key);
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

	/**
	 * Logs the Assets Libraries available and the assets they contain, useful for debugging.
	 */
	public static inline function logAssetsLibraryInfo():String
	{
		var libs = LimeAssets.libraries;
		var assets:Array<String> = [];
		for(libName in libs.keys())
			assets.push(' $libName - ${libs.get(libName).list(null)}');

		var info = 'Assets Library info:' + assets.join('\n');
		NeutronLogger.note(info);
		return info;
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

enum Library
{
	IMAGES;
	SOUNDS;
	MUSIC;
	DATA;
}

@:noCompletion @:keep @:bitmap("assets/images/logo/default.png")
class FlixelLogo extends BitmapData {}
