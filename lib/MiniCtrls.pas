{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit MiniCtrls;

{$warn 5023 off : no warning about unused units}
interface

uses
  PHPUtils, GUIMsgBox, mnFonts, ColorUtils, mnSynUtils, PHPProcessor, 
  HTMLProcessor, mnSynHighlighterXHTML, mnSynHighlighterStdSQL, 
  mnSynHighlighterApache, mnSynHighlighterConfig, mnSynHighlighterCpp, 
  mnSynHighlighterD, mnSynHighlighterFirebird, mnSynHighlighterLua, 
  mnSynHighlighterMultiProc, mnSynHighlighterGo, mnSynHighlighterSARD,
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('MiniCtrls', @Register);
end.
