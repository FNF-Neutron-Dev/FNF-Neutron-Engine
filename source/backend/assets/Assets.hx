package backend.assets;

import backend.assets.AssetLibrary as NuetronAssetLibrary;
import backend.assets.AssetLibrary.Library;
import backend.assets.Paths;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.Path;
import lime.media.AudioBuffer;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.ByteArray;

@:access(lime.utils.Assets)
/**
 * Helper class for getting assets.
 */
class Assets
{
	/**
	 * @param path      The path to return.
	 * @param library   The library to use.
	 * @return `String` With `path` in the specified `library`.
	 */
	public static function getPath(path:String, ?library:Library):String
	{
		if (library == null)
			return 'assets/$path';

		return '${library.name}:assets/${library.name}/$path';
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
		for (library in NuetronAssetLibrary.list())
		{
			if (OpenFLAssets.exists('${library.name}:$path'))
				return library;
		}

		return null;
	}

	/**
	 * Get the bytes of a bitmap from the filesytem and asset library.
	 * @param path         The path of the bitmap.
	 * @param  library     The library of the bitmap. is set to `images` by default.
	 * @return `ByteArray` Containing the bytes of the Bitmap.
	 */
	public static function getBitmapBytes(path:String, library:Library):ByteArray
	{
		var bitmapBytes:ByteArray = null;
		var assetKey:String = stripLibrary(path);
		var location:AssetLocation = Assets.checkFileLocation(assetKey, library);

		switch (location)
		{
			#if sys
			case FILE_SYSTEM | BOTH:
				bitmapBytes = File.getBytes(assetKey);
			#end
			case ASSET_LIBRARY:
				bitmapBytes = OpenFLAssets.getBytes(path);
			case NONE:
				NeutronLogger.warn("Tried to load a bitmap with the key of "
					+ assetKey
					+ " but it dosen't exist anywhere on the FileSystem or the Asset Library "
					+ library.name
					+ '.');
		}

		return bitmapBytes;
	}

	/**
	 * Get the bytes of a audio buffer from the filesytem and asset library.
	 * @param  path        The path of the audio file.
	 * @param  library     The library of the audio file. is set to `sounds` by default.
	 * @return `ByteArray` Containing the bytes of the audio buffer.
	 */
	public static function getAudioBufferBytes(path:String, library:Library):ByteArray
	{
		var audioBufferBytes:ByteArray = null;
		var assetKey:String = stripLibrary(path);
		var location:AssetLocation = Assets.checkFileLocation(assetKey, library);

		switch (location)
		{
			#if sys
			case FILE_SYSTEM | BOTH:
				audioBufferBytes = File.getBytes(assetKey);
			#end
			case ASSET_LIBRARY:
				audioBufferBytes = OpenFLAssets.getBytes(path);
			case NONE:
				NeutronLogger.warn("Tried to load a audio buffer with the key of "
					+ assetKey
					+ " but it dosen't exist anywhere on the FileSystem or the Asset Library "
					+ library.name
					+ '.');
		}

		return audioBufferBytes;
	}

	/**
	 * Checks where the file precisely exists.
	 * @param path    The path of the file to check for.
	 * @param library The library to use when checking for the file in the OpenFL/Lime AssetLibrary.
	 * @return        If the file exists in the OpenFL/Lime AssetLibrary, returns `ASSET_LIBRARY`. If it's in the filesystem only, returns `FILE_SYSTEM`. If both, returns `BOTH`, otherwise returns `NONE`.
	 */
	public static function checkFileLocation(path:String, ?library:Library):AssetLocation
	{
		if (library == null)
			library = NuetronAssetLibrary.DEFAULT;
		path = stripLibrary(path);
		var libraryName:String = library.name;
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
		NeutronLogger.note('the asset $path Couldn\'t be located in the FileSystem or the AssetLibrary $libraryName');
		return NONE;
	}

	/**
	 * Logs the Assets Libraries available and the assets they contain, useful for debugging.
	 */
	public static inline function logAssetsLibraryInfo()
	{
		var libs = LimeAssets.libraries;
		var assets:Array<String> = [];
		for (libName in libs.keys())
			assets.push(' $libName - ${libs.get(libName).list(null)}');

		NeutronLogger.print('[Neutron Engine Asset Library Info]\n' + assets.join('\n'));
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
