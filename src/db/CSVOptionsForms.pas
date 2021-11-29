unit CSVOptionsForms;
{$mode objfpc}{$H+}
{**
 *  This file is part of the "Mini Library"
 *
 * @license   modifiedLGPL (modified of http://www.gnu.org/licenses/lgpl.html)
 *            See the file COPYING.MLGPL, included in this distribution,
 * @author    Zaher Dirkey <zaher, zaherdirkey>
 *}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls,
  mnStreams, mncCSV;

type

  { TCSVOptionsForm }

  TCSVOptionsForm = class(TForm)
    IgnoreEmptyLinesChk: TCheckBox;
    CancelBtn: TButton;
    ANSIFileChk: TCheckBox;
    SkipColumnEdit: TEdit;
    HeaderList: TComboBox;
    EOLCharList: TComboBox;
    Label1: TLabel;
    QuoteCharLbl: TLabel;
    QuoteCharLbl1: TLabel;
    QuoteCharLbl2: TLabel;
    QuoteCharLbl3: TLabel;
    QuoteCharList: TComboBox;
    OkBtn: TButton;
    DelimiterList: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
  public
  end;

function ShowCSVOptions(Title: string; var vCSVIE: TmncCSVOptions): Boolean;

implementation

{$R *.lfm}

function ShowCSVOptions(Title: string; var vCSVIE: TmncCSVOptions): Boolean;
var
  s: string;
  c: Char;
begin
  with TCSVOptionsForm.Create(Application) do
  begin
    Caption := Title;

    QuoteCharList.Text := vCSVIE.QuoteChar;
    if vCSVIE.DelimiterChar < #32 then
      DelimiterList.Text := '#'+IntToStr(ord(vCSVIE.DelimiterChar))
    else
      DelimiterList.Text := vCSVIE.DelimiterChar;
    HeaderList.ItemIndex := Ord(vCSVIE.HeaderLine);
    ANSIFileChk.Checked := vCSVIE.ANSIContents;
    IgnoreEmptyLinesChk.Checked := vCSVIE.SkipEmptyLines;

    SkipColumnEdit.Text := IntToStr(vCSVIE.SkipColumn);
    if vCSVIE.EndOfLine = sWinEndOfLine then
      EOLCharList.ItemIndex := 0
    else if vCSVIE.EndOfLine = sUnixEndOfLine then
      EOLCharList.ItemIndex := 1
    else if vCSVIE.EndOfLine = sMacEndOfLine then
      EOLCharList.ItemIndex := 2
    else if vCSVIE.EndOfLine = sGSEndOfLine then
      EOLCharList.ItemIndex := 3
    else
      EOLCharList.ItemIndex := 0;//

    Result := ShowModal = mrOK;
    if Result then
    begin
      case HeaderList.ItemIndex of
        0: vCSVIE.HeaderLine := hdrNone;
        1: vCSVIE.HeaderLine := hdrSkip;
        2: vCSVIE.HeaderLine := hdrNormal;
      end;
      s := DelimiterList.Text;
      if s = '' then
        c := #0
      else if LeftStr(s, 1) = '#' then
        c := Char(StrToIntDef(Copy(s, 2, MaxInt), 0))
      else
        c := s[1];
      vCSVIE.DelimiterChar := c;

      s := QuoteCharList.Text;
      if s = '' then
        vCSVIE.QuoteChar := #0
      else
        vCSVIE.QuoteChar := s[1];
      if vCSVIE.QuoteChar < #32 then
        vCSVIE.QuoteChar := #0;


      case EOLCharList.ItemIndex of
        1: vCSVIE.EndOfLine := sUnixEndOfLine;
        2: vCSVIE.EndOfLine := sMacEndOfLine;
        3: vCSVIE.EndOfLine := sGSEndOfLine;
        else
          vCSVIE.EndOfLine := sWinEndOfLine;
      end;
      vCSVIE.ANSIContents := ANSIFileChk.Checked;
      vCSVIE.SkipEmptyLines := IgnoreEmptyLinesChk.Checked;
      vCSVIE.SkipColumn := StrToIntDef(SkipColumnEdit.Text, 0);
    end;
  end;
end;

{ TCSVOptionsForm }

procedure TCSVOptionsForm.FormCreate(Sender: TObject);
begin
  HeaderList.Items.Add('No Header');
  HeaderList.Items.Add('Skip header');
  HeaderList.Items.Add('Header contain fields');
  HeaderList.ItemIndex := 0;

  DelimiterList.Items.Add(';');
  DelimiterList.Items.Add(',');
  DelimiterList.Items.Add('|');
  DelimiterList.Items.Add('#9');
  DelimiterList.Items.Add('#29');
  DelimiterList.Text := ';';
  DelimiterList.ItemIndex := 0;

  EOLCharList.Items.Add('Windows');
  EOLCharList.Items.Add('Unix');
  EOLCharList.Items.Add('Mac');
  EOLCharList.Items.Add('GS');
  EOLCharList.ItemIndex := 0;

  QuoteCharList.Items.Add('');
  QuoteCharList.Items.Add('"');
  QuoteCharList.Items.Add('''');
  QuoteCharList.ItemIndex := 0;
end;

procedure TCSVOptionsForm.OkBtnClick(Sender: TObject);
begin

end;

end.

