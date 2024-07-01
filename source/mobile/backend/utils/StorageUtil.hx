package mobile.backend.utils;

import haxe.io.Path;
import haxe.Exception;
#if (android || doc_gen)
import android.Permissions as AndroidPermissions;
import android.widget.Toast as AndroidToast;
import android.Settings as AndroidSettings;
#end

/**
 * A utility class for handling storage operations on mobile devices.
 * Provides methods for retrieving storage directories, creating directories, saving content,
 * and managing permissions.
 * 
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class StorageUtil
{
	#if sys
	/**
	 * The root directory for the application storage.
	 */
	public static final rootDir:String = LimeSystem.applicationStorageDirectory;

	/**
	 * Retrieves the storage directory path.
	 *
	 * @param force If true, forces the storage type retrieval.
	 * @return The storage directory path.
	 */
	public static function getStorageDirectory(?force:Bool = false):String
	{
		var daPath:String = Sys.getCwd();
		#if android
		if (!FileSystem.exists(rootDir + 'storagetype.txt'))
			File.saveContent(rootDir + 'storagetype.txt', 'EXTERNAL_DATA');
		var curStorageType:String = File.getContent(rootDir + 'storagetype.txt');
		daPath = force ? StorageType.fromStrForce(curStorageType) : StorageType.fromStr(curStorageType);
		daPath = Path.addTrailingSlash(daPath);
		#elseif ios
		daPath = LimeSystem.documentsDirectory;
		#end

		return daPath;
	}

	/**
	 * Creates directories recursively if they do not exist.
	 *
	 * @param directory The path of the directory to create.
	 */
	public static function mkDirs(directory:String):Void
	{
		try
		{
			if (FileSystem.exists(directory) && FileSystem.isDirectory(directory))
				return;
		}
		catch (e:Exception)
		{
			trace('Something went wrong while looking at folder. (${e.message})');
		}

		var total:String = '';
		if (directory.substr(0, 1) == '/')
			total = '/';

		var parts:Array<String> = directory.split('/');
		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part != '')
			{
				if (total != '' && total != '/')
					total += '/';

				total += part;

				try
				{
					if (!FileSystem.exists(total))
						FileSystem.createDirectory(total);
				}
				catch (e:Exception)
					trace('Error while creating folder. (${e.message})');
			}
		}
	}

	/**
	 * Saves content to a file in the 'saves' directory.
	 *
	 * @param fileName The name of the file.
	 * @param fileExtension The extension of the file.
	 * @param fileData The content to save in the file.
	 */
	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json',
			fileData:String = 'You forgor to add somethin\' in yo code :3'):Void
	{
		try
		{
			if (!FileSystem.exists('saves'))
				FileSystem.createDirectory('saves');

			File.saveContent('saves/' + fileName + fileExtension, fileData);
			FlxG.stage.window.alert(fileName + " file has been saved.", "Success!");
		}
		catch (e:Exception)
			trace('File couldn\'t be saved. (${e.message})');
	}

	#if (android || doc_gen)
	/**
	 * Handles Android permissions for external storage.
	 */
	public static function doPermissionsShit():Void
	{
		if (!AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')
			&& !AndroidPermissions.getGrantedPermissions().contains('android.permission.WRITE_EXTERNAL_STORAGE'))
		{
			AndroidPermissions.requestPermission('READ_EXTERNAL_STORAGE');
			AndroidPermissions.requestPermission('WRITE_EXTERNAL_STORAGE');
			FlxG.stage.window.alert('If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash'
				+ '\nPress Ok to see what happens', 'Notice!');
			if (!AndroidEnvironment.isExternalStorageManager())
				AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}
		else
		{
			try
			{
				if (!FileSystem.exists(StorageUtil.getStorageDirectory()))
					FileSystem.createDirectory(StorageUtil.getStorageDirectory());
			}
			catch (e:Dynamic)
			{
				FlxG.stage.window.alert('Please create folder to\n' + StorageUtil.getStorageDirectory(true) + '\nPress OK to close the game', 'Error!');
				LimeSystem.exit(1);
			}
		}
	}

	/**
	 * Checks external paths for mounted storage directories.
	 *
	 * @param splitStorage If true, splits the storage paths.
	 * @return An array of external storage paths.
	 */
	public static function checkExternalPaths(?splitStorage = false):Array<String>
	{
		var process = new Process('grep -o "/storage/....-...." /proc/mounts | paste -sd \',\'');
		var paths:String = process.stdout.readAll().toString();
		if (splitStorage)
			paths = paths.replace('/storage/', '');
		return paths.split(',');
	}

	/**
	 * Retrieves the directory path for a specified external storage.
	 *
	 * @param external The external storage identifier.
	 * @return The directory path of the specified external storage.
	 */
	public static function getExternalDirectory(external:String):String
	{
		var daPath:String = '';
		for (path in checkExternalPaths())
			if (path.contains(external))
				daPath = path;

		daPath = haxe.io.Path.addTrailingSlash(daPath.endsWith("\n") ? daPath.substr(0, daPath.length - 1) : daPath);
		return daPath;
	}
	#end

	#end
}

#if (android || doc_gen)
/**
 * An enum abstract representing different storage types on Android.
 */
@:runtimeValue
enum abstract StorageType(String) from String to String
{
	@:dox(hide)
	final forcedPath = '/storage/emulated/0/';
	@:dox(hide)
	final packageNameLocal = 'com.neutrondev.neutronengine';
	@:dox(hide)
	final fileLocal = 'Neutron';

	@:dox(hide)
	var EXTERNAL_DATA = "EXTERNAL_DATA";
	@:dox(hide)
	var EXTERNAL_OBB = "EXTERNAL_OBB";
	@:dox(hide)
	var EXTERNAL_MEDIA = "EXTERNAL_MEDIA";
	@:dox(hide)
	var EXTERNAL = "EXTERNAL";

	/**
	 * Retrieves the storage type from a string.
	 *
	 * @param str The string representing the storage type.
	 * @return The storage type.
	 */
	public static function fromStr(str:String):StorageType
	{
		final EXTERNAL_DATA = AndroidContext.getExternalFilesDir();
		final EXTERNAL_OBB = AndroidContext.getObbDir();
		final EXTERNAL_MEDIA = AndroidEnvironment.getExternalStorageDirectory() + '/Android/media/' + lime.app.Application.current.meta.get('packageName');
		final EXTERNAL = AndroidEnvironment.getExternalStorageDirectory() + '/.' + lime.app.Application.current.meta.get('file');

		return switch (str)
		{
			case "EXTERNAL_DATA": EXTERNAL_DATA;
			case "EXTERNAL_OBB": EXTERNAL_OBB;
			case "EXTERNAL_MEDIA": EXTERNAL_MEDIA;
			case "EXTERNAL": EXTERNAL;
			default: StorageUtil.getExternalDirectory(str) + '.' + fileLocal;
		}
	}

	/**
	 * Retrieves the forced storage type from a string.
	 *
	 * @param str The string representing the storage type.
	 * @return The forced storage type.
	 */
	public static function fromStrForce(str:String):StorageType
	{
		final EXTERNAL_DATA = forcedPath + 'Android/data/' + packageNameLocal + '/files';
		final EXTERNAL_OBB = forcedPath + 'Android/obb/' + packageNameLocal;
		final EXTERNAL_MEDIA = forcedPath + 'Android/media/' + packageNameLocal;
		final EXTERNAL = forcedPath + '.' + fileLocal;

		return switch (str)
		{
			case "EXTERNAL_DATA": EXTERNAL_DATA;
			case "EXTERNAL_OBB": EXTERNAL_OBB;
			case "EXTERNAL_MEDIA": EXTERNAL_MEDIA;
			case "EXTERNAL": EXTERNAL;
			default: StorageUtil.getExternalDirectory(str) + '.' + fileLocal;
		}
	}
}
#end
