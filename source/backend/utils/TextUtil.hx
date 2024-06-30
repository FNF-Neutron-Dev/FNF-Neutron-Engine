package backend.utils;

class TextUtil
{
	public static inline function last<T>(array:Array<T>):T
	{
		return array[array.length - 1];
	}
}
