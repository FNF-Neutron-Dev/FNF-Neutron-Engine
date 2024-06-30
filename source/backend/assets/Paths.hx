package backend.assets;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.Path;
import openfl.display.BitmapData;
import openfl.media.Sound;
import lime.utils.AssetType;

// TODO add more functions and comments
class Paths
{
    @:noCompletion static var initialized:Bool = false;
    @:noCompletion
    public static function init():Void
    {
        if (!initialized) {
        OpenFLAssets.cache.enabled = true;
        LimeAssets.cache.enabled = true;
        OpenFLAssets.cache.setSound('flixel-beep', OpenFLAssets.getSound("flixel/sounds/beep.ogg"));
        OpenFLAssets.cache.setBitmapData('flixel-logo', new FlixelLogo(16, 16));
        } else
        FlxG.log.warn("[WARNING] Tried to initialize Paths but it's already initialized.");
    }

    public static inline function clearMemory():Void
    {
        clearBitmapsCache(true);
        clearSoundCache();
        for(key in LimeAssets.cache.font.keys())
            OpenFLAssets.cache.removeFont(key);
    }

    public static function graphic(key:String, ?shouldPersist:Bool = false, ?destroyOnNoUse:Bool = true):FlxGraphic
    {
        var bitmap:BitmapData = getBitmapData(key);
        var assetKey:String = null;

        for(iKey in LimeAssets.cache.image.keys())
        {
            if(LimeAssets.cache.image.get(iKey) == bitmap.image)
            {
                assetKey = iKey;
                break;
            }
        }

        if(FlxG.bitmap.checkCache(assetKey)) return FlxG.bitmap.get(assetKey);

        var graphic:FlxGraphic = FlxG.bitmap.add(bitmap, false, assetKey);
        graphic.persist = shouldPersist;
        graphic.destroyOnNoUse = destroyOnNoUse;
        return graphic;
     
    }

    public static inline function sound(key:String, ?volume:Float = 1.0, ?loop:Bool = false):FlxSound
    {
        return FlxG.sound.load(getSound(key), volume, loop);
    }

    inline static public function getSparrowAtlas(key:String, ?shouldPersist:Bool = false, ?destroyOnNoUse:Bool = true):FlxAtlasFrames
	{
		var graphic:FlxGraphic = graphic(key, shouldPersist, destroyOnNoUse);
        var xmlPath:String = Path.withExtension(Path.withoutExtension(graphic.key), "xml");
        var location:AssetLocation = checkFileLocation(xmlPath, "images");
        var xml:String = "";

        if(location == ASSET_LIBRARY || location == BOTH)
            xml = OpenFLAssets.getText('images:$xmlPath')
        #if sys
        else if(location == FILE_SYSTEM)
            xml = File.getContent(xmlPath)
        #end
        else
            FlxG.log.warn("[WARNING] Tried to parse a sparrow atlas sprite sheet but the XML animations file dosen't exist.");
        
		return FlxAtlasFrames.fromSparrow(graphic, xml);
	}

    public static function getBitmapData(key:String):BitmapData
    {
        var bitmap:BitmapData = null;
        var assetKey:String = 'assets/images/$key.png';
        var location:AssetLocation = checkFileLocation(key, 'images');

        if(OpenFLAssets.cache.hasBitmapData(assetKey)) return OpenFLAssets.cache.getBitmapData(assetKey);

        if(location == ASSET_LIBRARY || location == BOTH)
            bitmap = OpenFLAssets.getBitmapData('images:$key');
        #if sys
        else if(location == FILE_SYSTEM)
            bitmap = BitmapData.fromFile(key);
        #end

        if(bitmap != null)
        {
            if(bitmap.width > FlxG.bitmap.maxTextureSize || bitmap.height > FlxG.bitmap.maxTextureSize)
                FlxG.log.warn("[WARNING] The bitmap with the key of '" + assetKey + "' has a size that's larger than the device's maxTextureSize, Issues drawing the object might happen.");
            
            OpenFLAssets.cache.setBitmapData(assetKey, bitmap);
        }

        if(location == NONE)
        {
            FlxG.log.warn("[WARNING] Tried to load a bitmap with the key of " + assetKey + " but it dosen't exist anywhere on the FileSystem or Asset Library.");
            bitmap = OpenFLAssets.cache.getBitmapData('flixel-logo');
        }

        return bitmap;
    }

    // use AssetType.MUSIC to get audio file from assets/music
    public static function getSound(key:String, type:AssetType = SOUND):Sound
    {
        var sound:Sound = null;
        // i might remake this later because it looks so ass
        var library:String = type;
        library = library.toLowerCase();
        if(type == SOUND) library += "s";
        var assetKey:String = 'assets/$library/$key.ogg';
        var location:AssetLocation = checkFileLocation(assetKey, library);

        if(OpenFLAssets.cache.hasSound(assetKey)) return OpenFLAssets.cache.getSound(assetKey);

        if(location == ASSET_LIBRARY || location == BOTH)
            sound = OpenFLAssets.getSound('$library:$assetKey');
        #if sys
        else if(location == FILE_SYSTEM)
            sound = Sound.fromFile(assetKey);
        #end

        if(sound != null)
            OpenFLAssets.cache.setSound(assetKey, sound);

        if(location == NONE)
        {
            FlxG.log.warn("[WARNING] Tried to load a sound with the key of " + assetKey + " but it dosen't exist anywhere on the FileSystem or Asset Library.");
            sound = OpenFLAssets.cache.getSound('flixel-beep');
        }

        return sound;
    }

    public static function checkFileLocation(path:String, ?library:String):AssetLocation
    {
        var al:Bool = OpenFLAssets.exists(library == null ? path : '$library:$path');
        #if sys
        var fs:Bool = FileSystem.exists(path);
        if(fs && al) return BOTH;
        if(!fs && al) return ASSET_LIBRARY;
        if(fs && !al) return FILE_SYSTEM;
        return NONE;
        #else
        if(al) return ASSET_LIBRARY;
        return NONE;
        #end
    }

    public static function clearBitmapsCache(?allBitmaps:Bool = false):Void
    {
        @:privateAccess
        var bitmapCache = FlxG.bitmap._cache;

        if(allBitmaps)
        {
            for(key in bitmapCache.keys())
                OpenFLAssets.cache.removeBitmapData(key);

            FlxG.bitmap.clearCache();
            FlxG.bitmap.reset();
        }
        else
        {
            FlxG.bitmap.clearUnused();
            for(graphic in bitmapCache)
            {
                var key:String = graphic.key;
                if(FlxG.bitmap.checkCache(key))
                {
                    FlxG.bitmap.removeIfNoUse(graphic);
                    if(!FlxG.bitmap.checkCache(key))
                        OpenFLAssets.cache.removeBitmapData(key);
                }
            }
        }

        if(!OpenFLAssets.cache.hasBitmapData('flixel-logo'))
            OpenFLAssets.cache.setBitmapData('flixel-logo', new FlixelLogo(16, 16));
    }

    public static function clearSoundCache():Void
    {
        for(key in LimeAssets.cache.audio.keys())
            OpenFLAssets.cache.removeSound(key);
        OpenFLAssets.cache.setSound('flixel-beep', OpenFLAssets.getSound("flixel/sounds/beep.ogg"));
    }
}

enum AssetLocation
{
    FILE_SYSTEM;
    ASSET_LIBRARY;
    BOTH;
    NONE;
}

@:noCompletion @:keep @:bitmap("assets/images/logo/default.png")
class FlixelLogo extends BitmapData {}