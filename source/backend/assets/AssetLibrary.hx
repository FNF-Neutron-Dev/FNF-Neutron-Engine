package backend.assets;

import haxe.ds.Map;
import lime.utils.AssetLibrary as LimeAssetLibrary;
import lime.utils.Assets as LimeAssets;

class AssetLibrary
{
	// The rest of libraries are added by a macro
	// to add your own library here just define it like the others inside of Project.xml then the macro will do the magic~~
	public static final DEFAULT:Library = new Library("default", null, true);

	/**
	 * A Map that specifies the default usage of each library.
	 */
	public static var librariesDefault:Map<String, Array<Library>>;

	// perhaps i should changes these into an abstract?
	public static final IMAGES_USAGE:String = 'images';
	public static final AUDIO_USAGE:String = 'sounds';
	public static final DATA_USAGE:String = 'data';

	public static function init():Void
	{
		for (callback in Library.initCallBacks)
			callback();
		Library.initCallBacks = null;

		librariesDefault = [IMAGES_USAGE => [IMAGES], AUDIO_USAGE => [SOUNDS, MUSIC], DATA_USAGE => [DATA]];
	}

	/**
	 * Helper function to get a appropriat library for your usage.
	 * @param library The `Library` you want to use.
	 * @param usage   Your usage for the library.
	 * @return        If your `library` is usable for `usage` then it's returned. otherwise the default library for `usage` is returned.
	 */
	public static function getUsableLibrary(?library:Library, usage:String):Library
	{
		if (!librariesDefault.get(usage).contains(library) || library == null)
		{
			if (library != null)
			{
				NeutronLogger.warn("Cannot use the library " + library.name + " for " + usage + ". swtiching to default.");
			}

			library = librariesDefault.get(usage)[0];
		}

		return library;
	}

	/**
	 * Get an Array that contains every library
	 * @return Array<Library>
	 */
	public static function list():Array<Library>
	{
		var classFields = Type.getClassFields(AssetLibrary);
		classFields = classFields.filter((field) -> Std.isOfType(Reflect.field(AssetLibrary, field), Library));
		return [for (field in classFields) Reflect.field(AssetLibrary, field)];
	}
}

class Library
{
	public var library:LimeAssetLibrary;
	public var name:String;

	@:allow(backend.assets.AssetLibrary)
	private static var initCallBacks:Array<Void->Void> = [];

	public function new(name:String, ?library:LimeAssetLibrary, ?addInitCallBack:Bool = false)
	{
		this.name = name;

		if (library == null && addInitCallBack)
			initCallBacks.push(() -> this.library = LimeAssets.getLibrary(name));
		else
			this.library = library ?? LimeAssets.getLibrary(name);
	}
}
