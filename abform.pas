unit abform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, LCLIntf;

type

  { Tabf }

  Tabf = class(TForm)
      abfoot: TLabel;
      abImage: TImage;
      abb: TButton;
      clb: TButton;
      email: TLabel;
      Heading2: TLabel;
      http: TLabel;
      Image1: TImage;
      liclic: TLabel;
      licb: TButton;
      Memo1: TMemo;
      Notebook1: TNotebook;
      About: TPage;
      Licence: TPage;
      verl: TLabel;
      procedure FormActivate(Sender: TObject);
      procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);

      procedure abbClick(Sender: TObject);
      procedure clbClick(Sender: TObject);
      procedure emailClick(Sender: TObject);
      procedure httpClick(Sender: TObject);
      procedure licbClick(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  abf: Tabf;

implementation

{$R *.lfm}

{ Tabf }

procedure Tabf.FormActivate(Sender: TObject);
begin
     //http.Caption:= 'http://kelvin.net46.net';
end;

procedure Tabf.httpClick(Sender: TObject);
begin
    OpenURL('http://posmith.imgur.com');
end;

procedure Tabf.licbClick(Sender: TObject);
begin
    notebook1.PageIndex:=1;
end;

procedure Tabf.emailClick(Sender: TObject);
begin
     OpenURL('mailto:nventafini@gmail.com?Subject=Lemon Chat');
end;


procedure Tabf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    notebook1.PageIndex:=0;
end;


procedure Tabf.abbClick(Sender: TObject);
begin
    notebook1.PageIndex:= 0;
end;

procedure Tabf.clbClick(Sender: TObject);
begin
    abf.Close;
end;

end.

