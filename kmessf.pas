unit kmessf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { Tfkickmess }

  Tfkickmess = class(TForm)
    Edit1: TEdit;
    procedure Edit1KeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fkickmess: Tfkickmess;

implementation

{$R *.lfm}

{ Tfkickmess }

procedure Tfkickmess.Edit1KeyPress(Sender: TObject; var Key: char);
begin
     if key = #13 then close;
end;

end.

