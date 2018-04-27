unit banlist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dateutils, Forms, Dialogs, Grids,
  StdCtrls, LCLType, functions;

type

  { Tfbanlist }

  Tfbanlist = class(TForm)
    remb: TButton;
    cropb: TButton;
    clb: TButton;
    StringGrid1: TStringGrid;
    procedure clbClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    function getcon: smallint;
    procedure rembClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fbanlist: Tfbanlist;
  n:        smallint;

implementation
uses mainc;

{$R *.lfm}

{ Tfbanlist }

procedure Tfbanlist.FormResize(Sender: TObject);
var n:    smallint;
begin
     for n:= 0 to 2 do StringGrid1.Columns[n].Width:= trunc(width / 3) -10;
end;

procedure Tfbanlist.FormActivate(Sender: TObject);
var
   a:           string = '';
   row:         smallint = 1;
   ban,op,dat: string;
begin
     caption:= 'n-Chat' + ' ' + fmainc.TreeView1.Selected.Text;
     Show;
     // :server code nick #nvx mcclane!*@* Sollo!~Sollo@181.31.118.135 1500940056

     net[getcon].conn.SendString('MODE ' + fmainc.TreeView1.Selected.Text + ' +b ' + #13#10);
     while (pos('end of', LowerCase(a)) = 0) do begin
           a:= '';
           while (a = '') do a:= net[getcon].conn.RecvString(300);

           if (pos('end of', LowerCase(a)) = 0) then begin
           // Processing string
           delete(a, 1, pos(' ', a));  delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a));
           ban:= copy(a, 1, pos(' ', a)-1);

           delete(a, 1, pos(' ', a));
           op:= copy(a, 1, pos(' ', a)-1);

           delete(a, 1, pos(' ', a));
           dat:= a;

             StringGrid1.Cells[0,row]:= ban;
             StringGrid1.Cells[1,row]:= op;
             StringGrid1.Cells[2,row]:= DateTimeToStr(UnixToDateTime(strtoint(dat)) );
     inc(row);
     StringGrid1.RowCount:= row +1;
     end;
     end;
end;


function Tfbanlist.getcon: smallint;
begin
     if (fmainc.TreeView1.Selected <> nil) then
        if fmainc.TreeView1.Selected.Parent = nil then
           univ('', '', 0, nil)
           else result:= fmainc.TreeView1.Selected.Parent.Index +1;
end;

procedure Tfbanlist.rembClick(Sender: TObject);
begin
     if (pos( '@', fmainc.srchnick(net[getcon].nick, 2, fmainc.cnode(2,0,0,inttostr(getcon-1) + fmainc.TreeView1.Selected.Text))) > 0) then begin
        if StringGrid1.RowCount > 0 then begin

     fmainc.Timer1.Interval:= 50;
     net[getcon].conn.SendString('MODE ' + fmainc.TreeView1.Selected.Text + ' -b ' +
                                       StringGrid1.Cells[StringGrid1.Selection.Left, StringGrid1.Selection.Bottom] + #13#10);
     StringGrid1.DeleteRow(StringGrid1.Selection.Bottom);
     fmainc.Timer1.Interval:= 2000;
     end;

     end else ShowMessage('You need to be channel operator to perform this action');
end;

procedure Tfbanlist.clbClick(Sender: TObject);
var r:    smallint = 1;
    a:    string = '';
begin
          if (pos( '@', fmainc.srchnick(net[getcon].nick, 2, fmainc.cnode(2,0,0,inttostr(getcon-1) + fmainc.TreeView1.Selected.Text))) > 0) then begin

        if StringGrid1.RowCount > 0 then begin

     if (univ('Are you sure you want to remove all bans?', '', 1, clb)) = true then
     while (r < StringGrid1.RowCount -1) do begin
     net[getcon].conn.SendString('MODE ' + fmainc.TreeView1.Selected.Text + ' -b ' +
     StringGrid1.Cells[0, StringGrid1.Selection.Bottom] + #13#10);

     StringGrid1.DeleteRow(StringGrid1.Selection.Bottom);
     end;
     end;

     end else ShowMessage('You need to be channel operator to perform this action');
     //while (a = '') do a:= net[getcon].conn.RecvString(100);
     //fmainc.Timer1.Interval:= 2000;
end;


end.

