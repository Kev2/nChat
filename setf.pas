unit setf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, IniFiles, LConvEncoding;

type

  { Tfsett }

  Tfsett = class(TForm)
    chg1: TCheckGroup;
    chooseb: TButton;
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    pathl: TLabeledEdit;
    SelectDirectoryDialog1: TSelectDirectoryDialog;

    procedure chg1ItemClick(Sender: TObject; Index: integer);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure choosebClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fsett: Tfsett;

implementation

{$R *.lfm}

{ Tfsett }


procedure Tfsett.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  path:    array[0..MAX_PATH] of char;
  r:       boolean;
  ini:     TIniFile;
begin
  // ini.file
  {$ifdef Windows}
  path:= GetEnvironmentVariable('APPDATA') + DirectorySeparator + 'nchat';
  if not DirectoryExists(path) then mkdir(path);
  ini:= TIniFile.Create(path + DirectorySeparator + 'nchat.ini');
  r:= SHGetSpecialFolderPath(0, path, CSIDL_PERSONAL, false);
  //path:= SysToUtf8(path);
  path:= path + DirectorySeparator + 'nchat logs';
  {$endif}

  {$ifdef unix}
  path:= GetEnvironmentVariable('HOME') + DirectorySeparator + '.config' + DirectorySeparator + 'nchat';
  if not DirectoryExists(path) then mkdir(path);
  ini:= TIniFile.Create(path + DirectorySeparator + 'nchat.ini');
  path:= path + '/Logs/';
  {$endif}

  if pathl.Caption <> '' then path:= pathl.Caption else pathl.Caption:= path;

  if (chg1.Checked[1]) then begin
     if not DirectoryExists(path) then mkdir(path);
  end;

  if fsett.chg1.Checked[0] then
     ini.WriteString('Settings', 'Traffic', 'yes') else ini.WriteString('Settings', 'Traffic', 'no');
  if fsett.chg1.Checked[1] then
     ini.WriteString('Settings', 'Log', 'yes') else ini.WriteString('Settings', 'Log', 'no');

  if fsett.pathl.Caption = '' then
     ini.WriteString('Log', 'LogPath', path + DirectorySeparator + 'Logs\') else ini.WriteString('Path', 'LogPath', fsett.pathl.Caption);

end;

procedure Tfsett.chg1ItemClick(Sender: TObject; Index: integer);
begin
  if (chg1.Checked[1]) then GroupBox1.Enabled:= true else GroupBox1.Enabled:= false;
end;


procedure Tfsett.choosebClick(Sender: TObject);
begin
    if SelectDirectoryDialog1.Execute then
    pathl.Caption:= SelectDirectoryDialog1.FileName;
end;


end.

