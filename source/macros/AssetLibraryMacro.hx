package macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.xml.Access;
import haxe.xml.Parser;
import sys.io.File;

class AssetLibraryMacro
{
	public static function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		var pos = Context.currentPos();
		var accessXml = new Access(Parser.parse(File.getContent("Project.xml")));

		debugPrint('----Neutron Engine Asset Library Macro----');

		for (assetNode in accessXml.nodes.resolve("project")[0].nodes.resolve("library"))
		{
			debugPrint('Searching for library...');
			var libName:String = assetNode.att.resolve("name");

			debugPrint('found library ${libName}!');

			// don't know any other way of making a Expr out of a constructor... using `macro new Library(${args})` made it use default args for some reason
			var typePath:TypePath = {
				name: 'AssetLibrary',
				pack: ['backend', 'assets'],
				sub: 'Library'
			};

			var args:Array<Expr> = [
				Context.makeExpr(libName, pos),
				Context.makeExpr(null, pos),
				Context.makeExpr(true, pos)
			];

			var expr:Expr = {
				expr: ENew(typePath, args),
				pos: pos
			};

			fields.push({
				name: libName.toUpperCase(),
				access: [APublic, AStatic, AFinal],
				kind: FVar(macro :backend.assets.AssetLibrary.Library, expr),
				pos: pos,
			});

			debugPrint('added library ${libName}');
		}

		return fields;
	}

	private static function debugPrint(message:String)
	{
		#if MACROS_DEBUG_PRINTS
		Sys.println(message);
		#end
	}
}
#end
