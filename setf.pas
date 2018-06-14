unit setf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, IniFiles;

type

  { Tfsett }

  Tfsett = class(TForm)
    chg1: TCheckGroup;
    pathl: TLabeledEdit;
    Panel1: TPanel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
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
  path:    string;
  ini:     TIniFile;
begin
  // ini.file
  {$ifdef Windows}
  path:= GetEnvironmentVariable('APPDATA') + DirectorySeparator + 'LemonChat';
  if not DirectoryExists(path) then mkdir(path);
  ini:= TIniFile.Create(path + DirectorySeparator + 'Lemon.ini');
  path:= SHGetSpecialFolderLocation(0, CSIDL_PERSONAL, PIDL);
  path:= path + DirectorySeparator + 'LemonChat/Logs';
  {$endif}

  {$ifdef unix}
  path:= GetEnvironmentVariable('HOME') + DirectorySeparator + '.config' + DirectorySeparator + 'LemonChat';
  if not DirectoryExists(path) then mkdir(path);
  ini:= TIniFile.Create(path + DirectorySeparator + 'Lemon.ini');
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
     ini.WriteString('Path', 'LogPath', path + DirectorySeparator + 'Logs/') else ini.WriteString('Path', 'LogPath', fsett.pathl.Caption);

end;

end.

