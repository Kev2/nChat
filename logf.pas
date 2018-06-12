unit logf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, ExtCtrls, functions, srchf;

type

  { Tflogr }

  Tflogr = class(TForm)
    abm: TMenuItem;
    casebox: TCheckBox;
    filem: TMenuItem;
    hlpm: TMenuItem;
    srchl: TLabeledEdit;
    logd: TOpenDialog;
    MainMenu1: TMainMenu;
    memlog: TMemo;
    savd: TSaveDialog;
    savm: TMenuItem;
    openm: TMenuItem;
    optm: TMenuItem;
    quitm: TMenuItem;
    setm: TMenuItem;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure memlogKeyPress(Sender: TObject; var Key: char);
    procedure openmClick(Sender: TObject);
    procedure quitmClick(Sender: TObject);
    procedure savmClick(Sender: TObject);
    procedure srch;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  flogr: Tflogr;

implementation

{$R *.lfm}

{ Tflogr }


procedure Tflogr.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (key = 13) then memlog.SetFocus;
  if (srchl.Caption <> '') then srch;
end;

procedure Tflogr.memlogKeyPress(Sender: TObject; var Key: char);
begin
  if (key <> #13) then srchl.SetFocus;
  if (key = #13) then
     if (srchl.Caption <> '') then begin
        srch;
        memlog.SetFocus;
  end;
end;


procedure Tflogr.openmClick(Sender: TObject);
var  line:   string;
     l:      smallint = 1;
     p:      boolean = false;
     f:      TextFile;
begin

     repeat
        p:= true;

        if logd.Execute then begin

           if FileExists(logd.FileName) then
              p:= true else p:= false;

              if p = true then begin

                 AssignFile(f, logd.FileName);
                 reset(f);

                 if not Visible then begin
                    Show;
                    Activate;
                 end;
                 memlog.Clear;
                 l:= 0;

                 while (not EOF(f)) do begin
                       ReadLn(f, line);
                       memlog.lines[l]:= line;
                 inc(l);
                 end;

              closefile(f);
              end;
     end;
     until (p = true);
end;


procedure Tflogr.savmClick(Sender: TObject);
var  line:   string;
     l:      smallint = 0;
     p:      boolean = false;
     f:      TextFile;
begin
     repeat
        p:= true;

        if savd.Execute then begin

           if FileExists(savd.FileName) then
              if (univ('File exists, are you sure you want to replace it?',
                 pchar(ApplicationName),0,savm) = false) then
                 p:= false else p:= true;

              if p = true then begin

                 // Adding file extension
                 line:= ExtractFileExt(savd.FileName);
                 if line <> '.txt' then line:= savd.FileName + '.txt' else line:= savd.filename;

                 AssignFile(f, line);
                 Rewrite(f);

                 while (l < memlog.lines.count) do begin
                       writeln(f, memlog.lines[l]);
                 inc(l);
                 end;

              closefile(f);
              end;
     end;
     until (p = true);
end;

procedure Tflogr.quitmClick(Sender: TObject);
begin

end;

procedure Tflogr.srch;
const last:  string = '';
      r:     smallint = 0; // res position;
      res:   array of smallint = nil; // Array of results

var l:     smallint = 0; // Line
    lin:   string; // Current line
    char:  smallint = 0; // Selstart
    stxt:  string; // Text to search
    scan:  smallint = 0; // Search or navigate
begin
  if (stxt <> last) or (last = '') then
     if not casebox.Checked then stxt:= lowercase(srchl.Caption) else stxt:= srchl.Caption;

  if (last = stxt) and (last <> '') then scan:= 1;

with memlog do begin

case scan of

     0: begin
     last:= stxt;
     setlength(res, 0);
     r:= 0;
     if lines.Count > 0 then
     while (l < lines.Count) do begin
           if not casebox.Checked then
             lin:= lowercase(lines[l]) else lin:= lines[l];

             if (pos(stxt, lin) > 0) then begin
                SetLength(res, length(res)+1);
                res[r]:= char + pos(stxt, lin)-1;
                inc(r);
             end;

     char:= char + (length(lines[l])+1);
     inc(l);
     end;
     r:= 0;
       if length(res) > 0 then begin
       SelStart:= res[r];
       SelLength:= length(stxt);
       inc(r);
       end;
     end; // 0

     1: begin // Scan
        if r < length(res) then begin
        SelStart:= res[r];
        SelLength:= length(stxt);
        end;
     if r < length(res)-1 then inc(r) else r:= 0;
     end; // 1

     end; // Case

end; // Memlog

end;

end.

