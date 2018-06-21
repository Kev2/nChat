unit logf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, ExtCtrls, functions, LConvEncoding;

type

  { Tflogr }

  Tflogr = class(TForm)
    abm: TMenuItem;
    CheckGroup1: TCheckGroup;
    filem: TMenuItem;
    hlpm: TMenuItem;
    linel: TLabel;
    coll: TLabel;
    charl: TLabel;
    Panel1: TPanel;
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
    procedure srchlKeyPress(Sender: TObject; var Key: char);
    procedure memlogKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
  if (key <> 13) then srchl.SetFocus;
  if (key = 13) then begin

     if (srchl.Caption <> '') then begin
        srch;
        memlog.SetFocus;
     end;
  end;
end;

procedure Tflogr.memlogKeyPress(Sender: TObject; var Key: char);
begin
     if (key <> #13) then srchl.SetFocus else srch;
end;


procedure Tflogr.openmClick(Sender: TObject);
var  line:   string;
     l:      smallint = 1;
     p:      boolean = false;
     f:      TextFile;
     ch:     smallint = 1;              // Search for illegal characters
     spec:  string = 'áéíóúëïöüÁÉÍÓÚËÏÖÜñÑ* :.,;|+-=_/\#%&[]"@~¡!¿?()<>^`’$';
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

                       memlog.Lines[l]:= line;
                 inc(l);
                 end;

                 Caption:= logd.FileName;
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
      r:     integer = 0; // res position;
      res:   array of integer = nil; // Array of results

var l:     smallint = 0; // Line
    lin:   string; // Current line
    car:   integer = 0; // Selstart
    del:   smallint = 0;
    dif:   smallint = 0;
    ch:    smallint = 1; // Selstart
    stxt:  string; // Text to search
    scan:  smallint = 0; // Search or navigate
    tmp:   string;
    lc:    smallint = 0; // current line
    //spec:  string = 'ÁÉÍÓÚÄËÏÖÜâêîôûÂÊÎÔÛ* :.,;|+-=_/\#&[]"@~¡!¿?()<>^`’$';
    spec:  string = 'ÁÉÍÓÚÄËÏÖÜêîôûÊÎÔÛ* :.,;|+-=_/\#&[]"@~¡!¿?()<>^`$"''';
    //sp2:   string = '';
    nof:   boolean = false;
begin
  spec:= spec + char(10) + char(13);

  if (stxt <> last) or (last = '') then
     if not CheckGroup1.Checked[0] then stxt:= lowercase(srchl.Caption) else stxt:= srchl.Caption;
     //stxt:= 'Ã';

  if (last = stxt) and (last <> '') then
     if not CheckGroup1.Checked[1] then scan:= 1 else scan:= 2;


with memlog do begin

case scan of

     0: begin
     last:= stxt;
     setlength(res, 0);
     r:= 0;
     if lines.Count > 0 then
     //ShowMessage(inttostr(length(lines[0])));
     while (l < lines.Count) do begin
           if not CheckGroup1.Checked[0] then
             lin:= lowercase(lines[l]) else lin:= lines[l];


             //if (pos('’', lin) > 0) then
             //ShowMessage(inttostr(length(UTF8ToISO_8859_15(lin))));


           ch:= 1;
           del:= 0;
           nof:= true;
           tmp:= '';
           while (ch < length(lin)) do begin
                 if (length(lin) > 0) then if (pos(lin[ch], spec) > 0) then begin
                    //if (length(lin) > 0) then if (pos(lin[ch], spec) > 0) then ShowMessage(lin[ch]);
                    //dec(car); //dec(car); dec(car);
                    //inc(ch); //inc(car);
                 //inc(ch);
                 end;

                 tmp:= copy(lin, ch, length(stxt));
                 //ShowMessage(tmp);
                 if not (tmp[1] in ['a'..'z']) and not (tmp[1] in ['A'..'Z']) and not (tmp[1] in ['0'..'9'])
                    and (pos(tmp[1], spec) = 0)
                 then begin
                    //ShowMessage(tmp);
                    del:= del+1;
                    //dec(car);
                      //lines[l]:= StringReplace(lines[l], tmp[1], ' ', [rfReplaceAll]);
                      //if ch > 3 then
                      //if pos(' ', tmp) > 0 then //del:= del-2;
                      //ShowMessage(tmp);
                      nof:= false;
                    end;

                                      //ShowMessage(tmp);
                 if tmp = stxt then begin
                    SetLength(res, length(res)+1);
                    res[r]:= car + (ch) -1;
                    //res[r]:= 44;
                    if (nof = false) then res[r]:= res[r]-(del);

                    if not CheckGroup1.Checked[1] then if r = 0 then lc:= l else lc:= l;

                    //ShowMessage(inttostr(del));

                    //if (pos('​', lin) > 0) and (pos('​', lin) < res[r]-car) then res[r]:= res[r]-1;
                    //if (pos('ä', lin) > 0) and (pos('ä', lin) < res[r]-car) then res[r]:= res[r]-1;
                    //if (pos(char(124), lin) > 0) then ShowMessage('255');
                 inc(r);
                 end;

           inc(ch);
           end;

     car:= car + length(UTF8ToISO_8859_15(lin)) +1;

     inc(l);
     end;

     if (not CheckGroup1.Checked[1]) then r:= 0 else dec(r);
       if length(res) > 0 then begin
          SelStart:= res[r];
          SelLength:= length(stxt);
          //if (nof = false) then SelLength:= length(stxt)-1 else
          {
          linel.Caption:= 'line: ' + inttostr(memlog.CaretPos.y);
          coll.Caption:= 'col: ' + inttostr(memlog.CaretPos.x);
          charl.Caption:= 'character: ' + inttostr(res[r]);
          }
       if (not CheckGroup1.Checked[1]) then inc(r) else dec(r);
       end;

     end; // 0

     1: begin // Scan forward
        if r < length(res) then begin

        SelStart:= res[r];
        SelLength:= length(stxt);
        end;
     if r < length(res)-1 then inc(r) else r:= 0;
     end; // 1

     2: begin // Scan backwards
        if r > 0 then begin
        SelStart:= res[r];
        SelLength:= length(stxt);

        end;
     if r > 0 then dec(r) else r:= length(res);
     end; // 1


     end; // Case

end; // Memlog


//memlog.SetFocus;

end;

procedure Tflogr.srchlKeyPress(Sender: TObject; var Key: char);
begin
  if (key = #13) then begin

     if (srchl.Caption <> '') then begin
        srch;
        memlog.SetFocus;
     end;
  end;
end;

procedure Tflogr.memlogKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var ch:  integer = 0;
    c:  integer = 0;
begin
  //if (key >= 37) and (key <= 40) then begin
  for ch:= 0 to memlog.CaretPos.y-1 do c:= c + length(UTF8ToISO_8859_15(memlog.Lines[ch])) +1;
      c:= c + memlog.CaretPos.x;
     linel.Caption:= 'line: ' + inttostr(memlog.CaretPos.y);
     coll.Caption:= 'col: ' + inttostr(memlog.CaretPos.x);
     charl.Caption:= 'char: ' + inttostr(c);
  //end;
end;

end.

