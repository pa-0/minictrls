unit ntvPageControls;
{**
 *  This file is part of the "Mini Library"
 *
 * @url       http://www.sourceforge.net/projects/minilib
 * @license   modifiedLGPL (modified of http://www.gnu.org/licenses/lgpl.html)
 *            See the file COPYING.MLGPL, included in this distribution,
 * @author    Belal Alhamed <belalhamed at gmail dot com>
 * @author    Zaher Dirkey <zaher at parmaja dot com>
 *}
{$mode objfpc}{$H+}

interface

uses
  Classes, Messages, Controls, SysUtils, Contnrs, Graphics, Forms, Types,
  LMessages, LCLType, LCLIntf, LCLProc,
  ntvTabs, ntvTabSets, ntvUtils;

type
  TntvPageControl = class;
  TntvPageItem = class;

  { TntvPageItem }

  TntvPageItem = class(TntvTabItem)
  private
    FControl: TControl;
    procedure SetControl(const Value: TControl);
    function GetPageControl: TntvPageControl;
  protected
    procedure SetIndex(Value: Integer); override;
  public
    constructor Create(vCollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property PageControl: TntvPageControl read GetPageControl;
  published
    property Control: TControl read FControl write SetControl;
  end;

  TntvPageItemClass = class of TntvPageItem;

  { TntvPages }

  TntvPages = class(TntvTabSetItems)
  private
    function GetItem(Index: Integer): TntvPageItem;
    function GetPageControl: TntvPageControl;
    procedure SetItem(Index: Integer; Value: TntvPageItem);
  protected
    property PageControl: TntvPageControl read GetPageControl;
  public
    function GetOwner: TPersistent; override;
    function Add: TntvPageItem;
    function FindControl(vControl: TControl): TntvPageItem;
    function IndexOf(vControl: TControl): Integer;
    function AddControl(vControl: TControl; vShow: Boolean = True): TntvPageItem;
    function ExtractControl(vControl: TControl): TControl;
    property Items[Index: Integer]: TntvPageItem read GetItem write SetItem stored False; default;
  published
  end;

  { TntvPageControl }

  TntvPageControl = class(TntvCustomTabSet)
  private
    FMargin: Integer;
    procedure CMControlChange(var Message: TCMControlChange); message CM_CONTROLCHANGE;
    procedure SetMargin(const Value: Integer);
    procedure SetActiveControl(const Value: TControl);
    function GetActiveControl: TControl;
    function GetItems: TntvPages;
    procedure SetItems(Value: TntvPages);
    function GetPageItem(vControl: TControl): TntvPageItem;
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CreateParams(var Params: TCreateParams); override;
    function CreateTabs: TntvTabs; override;
    procedure ShowControl(AControl: TControl); override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;

    function GetPageRect: TRect; virtual;

    procedure BringControl(vControl: TControl; vSetFocus: Boolean);

    procedure DoTabShow(Index: Integer; vSetfocus: Boolean); override;
    procedure DoTabShowed(Index: Integer; vSetfocus: Boolean); override;
    class function GetControlClassDefaultSize: TSize; override;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSetFocus(var Msg: TLMSetFocus); message WM_SETFOCUS;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ActivableControl: TWinControl;
    procedure ActivateControl;
    property ActiveControl: TControl read GetActiveControl write SetActiveControl;
    property Page[Control: TControl]: TntvPageItem read GetPageItem;
  published
    property Margin: Integer read FMargin write SetMargin default 3;
    property ChildSizing;
    property BorderSpacing;
    property StoreIndex;
    property ShowButtons;
    property ShowTabs;
    property ShowBorder;
    property ItemIndex;
    property ImageList;
    property ActiveColor;
    property NormalColor;

    property Items: TntvPages read GetItems write SetItems;
    property OnTabSelected;
    property OnTabSelect;
    property TabStyle;
    property TabPosition;

    property Align;
    property Anchors;
    property BiDiMode;
    property Color;
    property Constraints;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDockDrop;
    property OnDockOver;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

implementation

{ TntvPageControl }

constructor TntvPageControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMargin := 3;
  with GetControlClassDefaultSize do
    SetInitialBounds(0, 0, CX, CY);
end;

destructor TntvPageControl.Destroy;
begin
  inherited;
end;

function TntvPageControl.ActivableControl: TWinControl;
var
  aList: TFPList;
  i: Integer;
begin
  Result := nil;
  if (ActiveControl is TWinControl) and (ActiveControl as TWinControl).CanFocus then
  begin
    aList := TFPList.Create;
    try
      (ActiveControl as TWinControl).GetTabOrderList(aList);
      aList.Add(ActiveControl as TWinControl);
      for i := 0 to aList.Count - 1 do
      begin
        if (TControl(aList[i]) as TWinControl).CanFocus and (TControl(aList[i]) as TWinControl).TabStop then
        begin
          Result := TControl(aList[i]) as TWinControl;
          break;
        end;
      end;
    finally
      aList.Free;
    end;
  end
end;

procedure TntvPageControl.ActivateControl;
var
  ParentForm: TCustomForm;
  aList: TFPList;
  i: Integer;
  aControl: TWinControl;
begin
  ParentForm := GetParentForm(Self);
  if ParentForm <> nil then
  begin
    aControl := ActivableControl;
    if aControl <> nil then
      ParentForm.ActiveControl := aControl
  end;
end;

procedure TntvPageControl.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_CLIPCHILDREN;
    WindowClass.style := WindowClass.style or (CS_HREDRAW or CS_VREDRAW);
  end;
end;

function TntvPageControl.CreateTabs: TntvTabs;
begin
  Result := TntvPages.Create(TntvPageItem);
  (Result as TntvPages).Control := Self;
end;

procedure TntvPageControl.ShowControl(AControl: TControl);
var
  i: Integer;
begin
  if (AControl <> nil) and (AControl is TControl) then
  begin
    i := Items.IndexOf(AControl as TControl);
    if i >=0 then
    begin
      SelectTab(I);
      Exit;
    end;
  end;
  inherited;
end;

procedure TntvPageControl.AlignControls(AControl: TControl; var Rect: TRect);
begin
  Rect := GetPageRect;
  inherited;
end;

procedure TntvPageControl.BringControl(vControl: TControl; vSetFocus: Boolean);
begin
  if vControl <> nil then
    with vControl do
    begin
      BringToFront;
      Visible := True;
      if vControl.Parent = Self then
        Align := alClient;
      if not (csLoading in ComponentState) and (vSetFocus) and (not Self.Focused) and (vControl is TWinControl) then
      begin
        if not (csDesigning in ComponentState) then
          ActivateControl;
      end;
    end;
end;

procedure TntvPageControl.DoTabShow(Index: Integer; vSetfocus: Boolean);
var
  i: Integer;
begin
  inherited;
  if not (csDesigning in ComponentState) then
    for i := 0 to Items.Visibles.Count - 1 do
      //To sure all tabs controls is hidden
      if (Items.Visibles[i] as TntvPageItem).Control <> nil then
        (Items.Visibles[i] as TntvPageItem).Control.Visible := False;
end;

procedure TntvPageControl.DoTabShowed(Index: Integer; vSetfocus: Boolean);
begin
  inherited;
  BringControl((Items.Visibles[Index] as TntvPageItem).Control, vSetfocus);
end;

procedure TntvPageControl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent <> Self) and (AComponent is TControl) and (Items.FindControl((AComponent as TControl)) <> nil) then
  begin
    Items.ExtractControl(AComponent as TControl);
  end;
end;

procedure TntvPageControl.CMControlChange(var Message: TCMControlChange);
begin
  inherited;
  with Message do
  begin
    if not (csLoading in ComponentState) then
      if Inserting then
      begin
        Items.AddControl(Control);
        ShowControl(Control);
        if Control.Parent = Self then
          Control.Align := alClient;
        Result := 1;
      end
  end;
end;

procedure TntvPageControl.SetMargin(const Value: Integer);
begin
  if FMargin <> Value then
  begin
    FMargin := Value;
    Realign;
  end;
end;

function TntvPageControl.GetPageRect: TRect;
begin
  Result := ClientRect;
  if ShowTabs then
  begin
    case TabPosition of
      tbpTop: Inc(Result.Top, GetHeaderHeight);
      tbpBottom: Dec(Result.Bottom, GetHeaderHeight);
    end;
  end;
  InflateRect(Result, -FMargin, -FMargin);
end;

procedure TntvPageControl.SetActiveControl(const Value: TControl);
var
  i: Integer;
begin
  for i := 0 to Items.Visibles.Count - 1 do
  begin
    if (Items.Visibles[i] as TntvPageItem).Control = Value then
    begin
      SelectTab(i, True);
      Break;
    end;
  end;
end;

function TntvPageControl.GetActiveControl: TControl;
begin
  if (ItemIndex >= 0) and (ItemIndex < Items.Visibles.Count) then
    Result := (Items.Visibles[ItemIndex] as TntvPageItem).Control
  else
    Result := nil;
end;

procedure TntvPageItem.Assign(Source: TPersistent);
begin
  if Source is TntvPageItem then
  begin
  end;
  inherited;
end;

constructor TntvPageItem.Create(vCollection: TCollection);
begin
  inherited;
  if (vCollection <> nil) then
  begin
    if not (csLoading in PageControl.ComponentState) then
    begin
      Name := Format(PageControl.Name + '_Item%d', [Index]);
      Caption := Name;
    end;
  end;
end;

destructor TntvPageItem.Destroy;
begin
  inherited;
end;

function TntvPageItem.GetPageControl: TntvPageControl;
begin
  if Collection <> nil then
    Result := (Collection as TntvPages).FControl as TntvPageControl
  else
    Result := nil;
end;


procedure TntvPageItem.SetControl(const Value: TControl);
begin
  if (FControl <> Value) then
  begin
    FControl := Value;
    if (Value <> nil) and (Value.Parent = PageControl) then
      FControl.Align := alClient;
  end;
end;

function TntvPageControl.GetPageItem(vControl: TControl): TntvPageItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Items.Count - 1 do
    if Items[i].Control = vControl then
    begin
      Result := Items[i];
      Break;
    end;
end;

procedure TntvPageControl.Loaded;
begin
  inherited Loaded;
end;

function TntvPageControl.GetItems: TntvPages;
begin
  Result := (inherited Items) as TntvPages;
end;

procedure TntvPageControl.SetItems(Value: TntvPages);
begin
   inherited Items := Value;
end;


class function TntvPageControl.GetControlClassDefaultSize: TSize;
begin
  Result.cx := 200;
  Result.cy := 240;
end;

procedure TntvPageControl.WMKillFocus(var Msg: TWMKillFocus);
begin
  inherited;
  Invalidate;
end;

procedure TntvPageControl.WMSetFocus(var Msg: TLMSetFocus);
begin
  inherited;
  Invalidate;
end;

{ TntvPages }

function TntvPages.Add: TntvPageItem;
begin
  Result := TntvPageItem(inherited Add);
end;

function TntvPages.AddControl(vControl: TControl; vShow: Boolean): TntvPageItem;
begin
  if vControl <> nil then
  begin
    BeginUpdate;
    try
      Result := TntvPageItem.Create(Self);
      with Result do
      begin
        Name := vControl.Name;
        Caption := Name;
        Control := vControl;
//        Collection := Self; //Add to Pages list; Or when Create(Self) the page
        Control.FreeNotification(PageControl);
        if (Control is TWinControl) and (Control.Parent = PageControl) then
          Control.Align := alClient;
        if not (csDesigning in Control.ComponentState) then
        begin
          if vShow then
            Control.Show
        end;
      end;
    finally
      EndUpdate;
    end;
  end
  else
    Result := nil;
end;

function TntvPages.ExtractControl(vControl: TControl): TControl;
var
  i: Integer;
  c: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if Items[i].Control = vControl then
    begin
      Result := Items[i].Control;
      Items[i].Control := nil;
      Delete(i);
      if not (csDestroying in Control.ComponentState) then
      begin
        c := i;
        if c > 0 then
          c := c - 1;
        PageControl.ShowTab(c);
      end;
      Break;
    end;
end;

function TntvPages.FindControl(vControl: TControl): TntvPageItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if Items[i].Control = vControl then
    begin
      Result := Items[i];
      Break;
    end;
end;

function TntvPages.GetItem(Index: Integer): TntvPageItem;
begin
  Result := (inherited Items[Index] as TntvPageItem);
end;

function TntvPages.GetPageControl: TntvPageControl;
begin
  Result := Control as TntvPageControl;
end;

function TntvPages.GetOwner: TPersistent;
begin
  Result := Control as TntvPageControl;
end;

procedure TntvPages.SetItem(Index: Integer; Value: TntvPageItem);
begin
  inherited SetItem(Index, Value);
end;

function TntvPages.IndexOf(vControl: TControl): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count -1 do
  begin
    if Items[i].Control = vControl then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TntvPageItem.SetIndex(Value: Integer);
var
  ShowSelf: Boolean;
begin
  if PageControl <> nil then
    ShowSelf := PageControl.ItemIndex = Index
  else
    ShowSelf := False;

  inherited;

  if PageControl <> nil then
  begin
    if ShowSelf then
    begin
      PageControl.ShowTab(Index, True);
    end
    else
      PageControl.ShowTab(PageControl.ItemIndex, True);
  end;
end;

end.

