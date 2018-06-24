unit logf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, ExtCtrls, functions, LConvEncoding, strutils, setf, abform;

type

  { Tflogr }

  Tflogr = class(TForm)
    abm: TMenuItem;
    srchb: TButton;
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
    procedure abmClick(Sender: TObject);
    procedure CheckGroup1ItemClick(Sender: TObject; Index: integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure memlogKeyPress(Sender: TObject; var Key: char);
    procedure openmClick(Sender: TObject);
    procedure quitmClick(Sender: TObject);
    procedure savmClick(Sender: TObject);
    procedure srch;
    procedure srchbClick(Sender: TObject);
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

procedure Tflogr.abmClick(Sender: TObject);
begin
 abf.ShowModal;
end;

procedure Tflogr.CheckGroup1ItemClick(Sender: TObject; Index: integer);
begin
  srchl.SetFocus;
end;

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
     logd.Filter:= 'Log files(*.log)|*.log|Text files (*.txt)|*.txt|All files (*.*)|*.*';
     if fsett.pathl.Caption <> '' then begin
        logd.FileName:= fsett.pathl.Caption;
        logd.DoSelectionChange;
     end;

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
                 {
                 while not (eof(f)) do begin
                       readln(f, line);
                       memlog.Append(line);
                 end;
                 }
                 memlog.Lines.LoadFromFile(logd.FileName);
                 //memlog.Text:= Utf8ToAnsi(memlog.Text);
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
     savd.Filter:= 'Log files(*.log)|*.log';
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
                 if line <> '.log' then line:= savd.FileName + '.log' else line:= savd.filename;

                 AssignFile(f, line);
                 Rewrite(f);

                 {
                 while (l < memlog.lines.count) do begin
                       writeln(f, memlog.lines[l]);
                 inc(l);
                 end;
                 }
                 memlog.Lines.LoadFromFile(logd.FileName);
              closefile(f);
              end;
     end;
     until (p = true);
end;

procedure Tflogr.quitmClick(Sender: TObject);
begin
  close;
end;

procedure Tflogr.srch;
const
       last:  string = '';
       res:   array of integer = nil;
       ap:    integer = 0; // array position
var
    r:     integer = 1;
    str:   string;
    ch:    integer = 0;
begin
  if (CheckGroup1.Checked[0]) then str:= (srchl.Caption) else str:= lowercase(srchl.Caption);
  str:= UTF8ToISO_8859_15(str);

  if (srchl.Caption <> last) then SetLength(res, 0);

  if length(res) = 0 then ap:= 0;
  if length(res) = 0 then
  repeat
        if (CheckGroup1.Checked[0]) then
        r:= PosEx(str, UTF8ToISO_8859_15(memlog.Text), r) else
          r:= PosEx(str, UTF8ToISO_8859_15(lowercase(memlog.Text)), r);

  if r > 0 then begin
     SetLength(res, length(res)+1);
     //ShowMessage('r ' +inttostr(ap));
     res[ap]:= r-1;
     memlog.SelStart:= r -1;
     memlog.SelLength:= length(str);
     r:= r + length(str);
     inc(ap);
  end;
  until r = 0;


  // Navigating array
  if length(res) > 0 then
  if not CheckGroup1.Checked[1] then begin
  if (last <> srchl.Caption) then ap:= 0;
     //ShowMessage('0' + inttostr(ap));
     memlog.SelStart:= res[ap];
     memlog.SelLength:= length(str);
     if ap < length(res)-1 then inc(ap) else ap:= 0;
  end else begin
  if (last <> srchl.Caption) then ap:= length(res)-1;
      memlog.SelStart:= res[ap];
      memlog.SelLength:= length(str);
      if ap > 0 then dec(ap) else ap:= length(res)-1;
  end; // Checked
  //ShowMessage(inttostr(ap));
  last:= srchl.caption;
end;


{
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
    spec:  string = 'ÁÉÍÓÚÄËÏÖÜêîôûÊÎÔÛ* :.,;|+-=_/\#&[]"@%~¡!¿?()<>^`''$"';
    //sp2:   string = '';
    nof:   boolean = false;
    pch:   pChar;
begin
  spec:= spec + char(9) + char(10) + char(13);

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
             lin:= lowercase((lines[l])) else lin:= lines[l];
             //lin:= UTF8ToISO_8859_15(lin);

             //ShowMessage(inttostr(ord(char(memlog.Text[1]))) + sLineBreak + inttostr(ord(char(memlog.Text[2]))));
             {if l = 0 then
                if (ord(char(memlog.Text[1])) = 239) then dec(car);}

             {if (length(lin) > 0) then
             ShowMessage(inttostr(length(lin)));}
             {if (length(lin) > 0) and (l < 10) then
                ShowMessage(lin + sLineBreak + inttostr(ord(lin[length(lin)])) + '_');}

             //if (pos('’', lin) > 0) then
             //ShowMessage(inttostr(length(UTF8ToISO_8859_15(lin))));
             {
             lines[l]:= StringReplace(lines[l], 'â', 'â', [rfReplaceAll]);
             lines[l]:= StringReplace(lines[l], '¢', '€', [rfReplaceAll]);

             lin:= StringReplace(lin, '’', '*', [rfReplaceAll]);
             lin:= StringReplace(lin, '''', '*', [rfReplaceAll]);
             lin:= StringReplace(lin, 'äs', 'ä', [rfReplaceAll]);
             //lin:= StringReplace(lin, '•', char(249), [rfReplaceAll]);
             //lines[l]:= StringReplace(lines[l], '…', '...', [rfReplaceAll]);
             }
             //lin:= StringReplace(lin, '¡A', '¡A', [rfReplaceAll]);
             //lin:= StringReplace(lin, '’', '*', [rfReplaceAll]);

           ch:= 1;
           del:= 0;
           nof:= true;
           tmp:= '';
           while (ch < length(lin)) do begin
                 //if memlog.Text[car + ch+2] = char(10) then del:= del+2;
           //dec(car); //dec(car); dec(car);
                    //inc(ch); //inc(car);
                 //inc(ch);

                 tmp:= copy(lin, ch, length(stxt));
                 //ShowMessage(tmp);
                 if not (tmp[1] in ['a'..'z']) and not (tmp[1] in ['A'..'Z']) and not (tmp[1] in ['0'..'9'])
                    and (pos(tmp[1], spec) = 0)
                 then begin
                    //ShowMessage('del ' + tmp);
                    //del:= del+1;
                    //dec(car);
                      //lines[l]:= StringReplace(lines[l], tmp[1], ' ', [rfReplaceAll]);
                      //if ch > 3 then
                      //if pos(char(10), tmp) > 0 then //del:= del-2;
                      //ShowMessage(tmp);
                      nof:= false;
                    end;

                                      //ShowMessage(tmp);
                 if tmp = stxt then begin
                    SetLength(res, length(res)+1);
                    res[r]:= car + (ch) -1;
                    //res[r]:= FindIntToIdent(tmp, memlog.Text, ch);
                    //res[r]:= 44;
                    //if (nof = false) then
                    if not nof then res[r]:= res[r]-(del);

                    if not CheckGroup1.Checked[1] then if r = 0 then lc:= l else lc:= l;

                    //ShowMessage(inttostr(del));

                    //if (pos('​', lin) > 0) and (pos('​', lin) < res[r]-car) then res[r]:= res[r]-1;
                    //if (pos('ä', lin) > 0) and (pos('ä', lin) < res[r]-car) then res[r]:= res[r]-1;
                    //if (pos(char(124), lin) > 0) then ShowMessage('255');
                 inc(r);
                 end;

           inc(ch);
           end;
     //if (pos(char(124), lin) > 0) then ShowMessage(inttostr(ord((char('​'))));
     //if (pos(char(124), lin) > 0) then ShowMessage(inttostr(ord(char('a'))));
     //if (length(lin) > 0) then
     //if (length(lines[l]) > (ch-1)) then dec(car);
     //car:= car + (length((lines[l]))+2);

     //if (length(lin) > 0) and (l = 3) then ShowMessage(inttostr(ord(lines[l][ch])));

     //if l = 8 then ShowMessage(inttostr(ord(char(memlog.Text[489])))); //489

     {This code decreases one character when the line is wrapped
     On Windows, when the line is wrapped, there is not #13#10}
     if length(lin) > 0 then begin
     //ShowMessage(inttostr(ord(char(ord(memlog.text[car + ch +1])))));
     //ShowMessage(inttostr(ord(char(ord(memlog.text[car + ch +1])))));
     //if (memlog.Text[car + length(lin) +1] <> char(13)) and (memlog.Text[car + length(lin) +1] <> char(10)) then dec(car);
     end;

     //if l = 8 then ShowMessage(inttostr( car + ch )); //489

           if (memlog.Text[car + length(lin)] = char(13)) then
           car:= car+1 + length((lin))+2  else car:= car + length((lin)) +1;
           //car:= car + length(UTF8ToISO_8859_15(lin))+2 else car:= car + length(UTF8ToISO_8859_15(lin)) +1;

           if length(lin) = 0 then if (memlog.Text[car + ch-1] = char(13)) then inc(car);
           if length(lin) > 0 then
           if (memlog.Text[car + length(lin)] = char(13)) then ShowMessage('13');

           {$ifdef Windows}
           {if (l < 3) then if (ord(char(memlog.Text[1])) = 239) then car:= car +2 else}
              //if (ord(char(memlog.Text[1])) = 239) or (ord(char(memlog.Text[1])) = 79) then car:= car-1;
              //if (ord(char(memlog.Text[1])) = 79) then car:= car+1;
              //ShowMessage(inttostr(ord(char(memlog.Text[1]))));
              //if l = 2 then ShowMessage(inttostr(length(lin)));
           {$endif}

           inc(l);
           end;

     if (not CheckGroup1.Checked[1]) then r:= 0 else dec(r);
       if length(res) > 0 then begin
          SelStart:= res[r];
          SelLength:= length(stxt);
          //if (nof = false) then SelLength:= length(stxt)-1 else
          linel.Caption:= 'line: ' + inttostr(memlog.CaretPos.y);
          coll.Caption:= 'col: ' + inttostr(memlog.CaretPos.x);
          charl.Caption:= 'character: ' + inttostr(res[r]);
       if (not CheckGroup1.Checked[1]) then inc(r) else dec(r);
       end;

     end; // 0

     1: begin // Scan forward
        if r < length(res) then begin

        SelStart:= res[r];
        SelLength:= length(stxt);

          linel.Caption:= 'line: ' + inttostr(memlog.CaretPos.y);
          coll.Caption:= 'col: ' + inttostr(memlog.CaretPos.x);
          charl.Caption:= 'character: ' + inttostr(res[r]);

        end;
     if r < length(res)-1 then inc(r) else r:= 0;
     end; // 1

     2: begin // Scan backwards
        if r > 0 then begin
        SelStart:= res[r];
        SelLength:= length(stxt);

          linel.Caption:= 'line: ' + inttostr(memlog.CaretPos.y);
          coll.Caption:= 'col: ' + inttostr(memlog.CaretPos.x);
          charl.Caption:= 'character: ' + inttostr(res[r]);
        end;
     if r > 0 then dec(r) else r:= length(res);
     end; // 1


     end; // Case

end; // Memlog


//memlog.SetFocus;

end;
}

procedure Tflogr.srchlKeyPress(Sender: TObject; var Key: char);
begin
  if (key = #13) then
     if (srchl.Caption <> '') then
        srchbClick(srchl);
end;

procedure Tflogr.srchbClick(Sender: TObject);
begin
  srch;
  memlog.SetFocus;
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

