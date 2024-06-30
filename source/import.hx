#if !macro
import openfl.utils.Assets as OpenFLAssets;
import lime.utils.Assets as LimeAssets;
import lime.system.System as LimeSystem;
import openfl.system.System as OpenFLSystem;
// Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.util.FlxDestroyUtil;
// Android
#if (android || doc_gen)
import android.content.Context as AndroidContext;
import android.widget.Toast as AndroidToast;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.os.BatteryManager as AndroidBatteryManager;
#end
#if sys
import sys.*;
import sys.io.*;
#end
import mobile.backend.utils.StorageUtil;

using StringTools;
using flixel.util.FlxArrayUtil;
#end
