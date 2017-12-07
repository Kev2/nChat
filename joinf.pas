unit joinf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls;

type

  { Tfjoin }

  Tfjoin = class(TForm)
    jedit: TEdit;
    Label1: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure jeditKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fjoin: Tfjoin;

implementation

{$R *.lfm}

{ Tfjoin }

procedure Tfjoin.FormActivate(Sender: TObject);
begin
     //if not active then show;
     jedit.SelStart:= length(jedit.Caption);
end;


procedure Tfjoin.FormKeyPress(Sender: TObject; var Key: char);
begin
     if key = #27 then close;
end;

procedure Tfjoin.jeditKeyPress(Sender: TObject; var Key: char);
begin
     if key = #13 then close;
end;


end.

