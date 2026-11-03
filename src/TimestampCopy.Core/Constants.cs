namespace TimestampCopy.Core;

public static class Constants
{
	public const string Homepage = "https://github.com/jurakovic/TimestampCopy";
	public const string Version = "3.0.0";

	// Compatibility contract with the 2.x PowerShell releases ($datetimeFormat, $appdataPath,
	// $clipPath, $undoPath in TimestampCopy.ps1). Upgrading from 2.x keeps whatever was already
	// copied only while these match, so they must not drift.
	public const string DateTimeFormat = "yyyy-MM-dd HH:mm:ss";

	public static string AppDataPath { get; } = Path.Combine(
		Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
		"TimestampCopy");

	public static string ClipPath { get; } = Path.Combine(AppDataPath, "clip");

	public static string UndoPath { get; } = Path.Combine(AppDataPath, "clip-undo");

	// The two executables always sit in the same folder - they share one copy of the runtime.
	// The installer registers these paths, so it works from wherever the folder was unzipped.
	public static string ExePath { get; } = Path.Combine(AppContext.BaseDirectory, "tscp.exe");

	public static string ExePathBackground { get; } =
		Path.Combine(AppContext.BaseDirectory, "tscpw.exe");
}
