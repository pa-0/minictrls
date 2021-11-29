unit mnSynHighlighterGo;
{$mode objfpc}{$H+}
{**
 * NOT COMPLETED
 *
 *  This file is part of the "Mini Library"
 *
 * @url       http://www.sourceforge.net/projects/minilib
 * @license   modifiedLGPL (modified of http://www.gnu.org/licenses/lgpl.html)
 *            See the file COPYING.MLGPL, included in this distribution,
 * @author    Zaher Dirkey <zaher at parmaja dot com>
 *
 *    https://www.tutorialspoint.com/go/go_basic_syntax.htm
 *
 *}

interface

uses
  Classes, SysUtils,
  SynEdit, SynEditTypes,
  SynEditHighlighter, SynHighlighterHashEntries, mnSynHighlighterMultiProc;

type

  { TGoProcessor }

  TGoProcessor = class(TCommonSynProcessor)
  private
  protected
    function GetIdentChars: TSynIdentChars; override;
    function GetEndOfLineAttribute: TSynHighlighterAttributes; override;
  public
    procedure QuestionProc;
    procedure SlashProc;

    procedure GreaterProc;
    procedure LowerProc;

    procedure Next; override;

    procedure Prepare; override;
    procedure MakeProcTable; override;
  end;

  { TSynDSyn }

  TSynGoSyn = class(TSynMultiProcSyn)
  private
  protected
    function GetSampleSource: string; override;
  public
    class function GetLanguageName: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure InitProcessors; override;
  published
  end;

const

  SYNS_LangGo = 'Go';
  SYNS_FilterGo = 'Go Lang Files (*.go)|*.go';

  cGoSample =
      'package main'#13#10+
      '//line comment'#13#10+
      'import "fmt"'#13#10+
      'func main() {'#13#10+
      '    fmt.Println("hello world")'#13#10+
      '    /* All rest of program here'#13#10+
      '    */'#13#10+
      '}'#13#10;

{$INCLUDE 'GoKeywords.inc'}

implementation

uses
  mnUtils;

procedure TGoProcessor.GreaterProc;
begin
  Parent.FTokenID := tkSymbol;
  Inc(Parent.Run);
  if Parent.FLine[Parent.Run] in ['=', '>'] then
    Inc(Parent.Run);
end;

procedure TGoProcessor.LowerProc;
begin
  Parent.FTokenID := tkSymbol;
  Inc(Parent.Run);
  case Parent.FLine[Parent.Run] of
    '=': Inc(Parent.Run);
    '<':
      begin
        Inc(Parent.Run);
        if Parent.FLine[Parent.Run] = '=' then
          Inc(Parent.Run);
      end;
  end;
end;

procedure TGoProcessor.SlashProc;
begin
  Inc(Parent.Run);
  case Parent.FLine[Parent.Run] of
    '/':
      begin
        SLCommentProc;
      end;
    '*':
      begin
        Inc(Parent.Run);
        if Parent.FLine[Parent.Run] = '*' then
          DocumentProc
        else
          CommentProc;
      end;
  else
    Parent.FTokenID := tkSymbol;
  end;
end;

procedure TGoProcessor.MakeProcTable;
var
  I: Char;
begin
  inherited;
  for I := #0 to #255 do
    case I of
      '?': ProcTable[I] := @QuestionProc;
      '''': ProcTable[I] := @StringSQProc;
      '"': ProcTable[I] := @StringDQProc;
      '`': ProcTable[I] := @StringBQProc;
      '/': ProcTable[I] := @SlashProc;
      '>': ProcTable[I] := @GreaterProc;
      '<': ProcTable[I] := @LowerProc;
      '0'..'9':
        ProcTable[I] := @NumberProc;
      'A'..'Z', 'a'..'z', '_':
        ProcTable[I] := @IdentProc;
    end;
end;

procedure TGoProcessor.QuestionProc;
begin
  Inc(Parent.Run);
  case Parent.FLine[Parent.Run] of
    '>':
      begin
        Parent.Processors.Switch(Parent.Processors.MainProcessor);
        Inc(Parent.Run);
        Parent.FTokenID := tkProcessor;
      end
  else
    Parent.FTokenID := tkSymbol;
  end;
end;

procedure TGoProcessor.Next;
begin
  Parent.FTokenPos := Parent.Run;
  if (Parent.FLine[Parent.Run] in [#0, #10, #13]) then
    ProcTable[Parent.FLine[Parent.Run]]
  else case Range of
    rscComment:
    begin
      CommentProc;
    end;
    rscDocument:
    begin
      DocumentProc;
    end;
    rscStringSQ, rscStringDQ, rscStringBQ:
      StringProc;
  else
    if ProcTable[Parent.FLine[Parent.Run]] = nil then
      UnknownProc
    else
      ProcTable[Parent.FLine[Parent.Run]];
  end;
end;

procedure TGoProcessor.Prepare;
begin
  inherited;
  EnumerateKeywords(Ord(tkKeyword), sGoKeywords, TSynValidStringChars, @DoAddKeyword);
  EnumerateKeywords(Ord(tkFunction), sGoFunctions, TSynValidStringChars, @DoAddKeyword);
  SetRange(rscUnknown);
end;

function TGoProcessor.GetEndOfLineAttribute: TSynHighlighterAttributes;
begin
  if (Range = rscDocument) or (LastRange = rscDocument) then
    Result := Parent.DocumentAttri
  else
    Result := inherited GetEndOfLineAttribute;
end;

function TGoProcessor.GetIdentChars: TSynIdentChars;
begin
  Result := TSynValidStringChars;
end;

constructor TSynGoSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDefaultFilter := SYNS_FilterGo;
end;

procedure TSynGoSyn.InitProcessors;
begin
  inherited;
  Processors.Add(TGoProcessor.Create(Self, 'Go'));

  Processors.MainProcessor := 'Go';
  Processors.DefaultProcessor := 'Go';
end;

class function TSynGoSyn.GetLanguageName: string;
begin
  Result := SYNS_LangGo;
end;

function TSynGoSyn.GetSampleSource: string;
begin
  Result := cGoSample;
end;

end.
