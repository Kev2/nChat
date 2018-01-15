unit chanlist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls, ExtCtrls, LCLType, Menus, ComCtrls, functions;

type

  { Tfclist }

  Tfclist = class(TForm)
    Label1: TLabel;
    MainMenu1: TMainMenu;
    filem: TMenuItem;
    exitm: TMenuItem;
    chlistm: TMenuItem;
    servm: TMenuItem;
    savem: TMenuItem;
    openm: TMenuItem;
    odd: TOpenDialog;
    sdd: TSaveDialog;
    srchb: TButton;
    LabeledEdit1: TLabeledEdit;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    procedure FormResize(Sender: TObject);

    procedure openmClick(Sender: TObject);
    procedure savemClick(Sender: TObject);
    procedure chlistmClick(Sender: TObject);
    procedure srchbClick(Sender: TObject);
    procedure LabeledEdit1KeyPress(Sender: TObject; var Key: char);

    procedure getchannels(con: smallint; nick: string);
    procedure filter(Sender: TObject);
    procedure parse(txt: array of string);

    function univ(Txt, cption: PChar; Flags: longint; sender: tobject): boolean;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fclist: Tfclist;

implementation
uses mainc;

{$R *.lfm}

{ Tfclist }

procedure Tfclist.FormResize(Sender: TObject);
begin
     StringGrid1.Columns[2].Width:= Width-200;
     LabeledEdit1.SetFocus;
end;

procedure Tfclist.chlistmClick(Sender: TObject);
var n:  smallint = 0;
    c:  string;       // Tsyn channel name
begin
     if (fmainc.TreeView1.Selected <> nil) then
        if fmainc.TreeView1.Selected.Parent = nil then n:= fmainc.TreeView1.Selected.AbsoluteIndex else
           n:= fmainc.TreeView1.Selected.Parent.AbsoluteIndex;

     n:= fmainc.cnode(5, n, 0, ''); // Getting array of TSyn. Network is the number before the channel name
     c:= copy(m0[n].chan, 1, 1);
     while (m0[n].chan[length(c)+1] in ['0'..'9']) do c:= copy(m0[n].chan, 1, length(c)+1);
     n:= strtoint(c);

     if assigned(net[n+1]) then getchannels(n+1, net[n+1].nick);
end;


procedure Tfclist.LabeledEdit1KeyPress(Sender: TObject; var Key: char);
begin
     if key = #13 then srchbClick(LabeledEdit1);
end;


procedure Tfclist.srchbClick(Sender: TObject);
var l: smallint = 0;
    c: smallint = 0;
begin
     {
     for l:= 1 to 12 do begin
         inc(c);
         if c = 3 then c:= 0;
         StringGrid1.Cells[c,l]:= inttostr(l);
     end;
     }
     if (LabeledEdit1.Caption <> '') then filter(srchb);
end;

procedure tfclist.getchannels(con: smallint; nick: string);
var
   r:     string;          // String from the server
   ch:    TStringList;     // List of channels
   ch1:   array of string;
   l:     integer = 0;     // Tstrings number
   tmp:   string;          // Temp to sort
begin
     ch:= TStringList.Create;

     label1.Visible:= true;
     if not Visible then show;
     repaint;
     sleep(2000);

     with fmainc do begin
     Timer1.Enabled:= false;

     net[con].conn.SendString('LIST' + #13#10);
          repeat
          r:= '';
          r:= net[con].conn.RecvString(10);
          if (r <> '') and (pos(':end of', lowercase(r)) = 0) then ch.Add(r);

          //ShowMessage(r);
          //if (pos('end of', lowercase(r)) > 0) and (pos('list', lowercase(r)) > 0) then ShowMessage(r);

          until (pos(':end of ', lowercase(r)) > 0) and (pos('list', lowercase(r)) > 0);

          // Parsing
          l:= 0;
          while (l < ch.Count) do begin
                tmp:= ch[l];
                delete(tmp, 1, pos(nick, tmp)+length(nick));
                ch[l]:= tmp;
                ch[l]:= StringReplace(ch[l], ' ', ',', [rfReplaceAll]);
                ch[l]:= StringReplace(ch[l], ':', ',', [rfReplaceAll]);
          inc(l);
          end;

          {
          // Deleting
          l:= 0;
          while (l < ch.Count) do begin
                tmp:= ch[l];
          inc(l);
          end;
          }

          // Converting to array to send to parse
          SetLength(ch1, ch.Count);
          for l:= 0 to ch.Count-1 do ch1[l]:= ch[l];


                 // Parsing
                    Parse(ch1);
                    StringGrid1.FixedRows:= 1;

                // Sorting
                   StringGrid1.SortColRow(true, 0);

     Timer1.Enabled:= true;
     end;
     ch.Free;
end;

procedure Tfclist.filter(Sender: TObject);
var
   row:    integer = 1;
   col:    integer = 0;
   str:    array of string;
   snd:    array of string;
   tmp:    string;

begin
     SetLength(str, StringGrid1.RowCount);
     SetLength(snd, StringGrid1.RowCount);

     while (row < StringGrid1.RowCount) do begin
           while (col < StringGrid1.ColCount) do begin
                 tmp:= StringGrid1.Cells[col,row];
                 if col = 0 then
                    str[row]:= ( StringGrid1.Cells[col,row] ) else
                    str[row]:= str[row] + ',' + tmp;
           inc(col);
           end;
           //ShowMessage(str[row]);
     col:= 0;
     inc(row);
     end;

     // Searching
     row:= 0;

     if LabeledEdit1.Caption <> '' then
     while (row < StringGrid1.RowCount) do begin
           if (pos(lowercase(LabeledEdit1.Caption), lowercase(str[row]) ) > 0) then snd[row]:= ( str[row] );
           //ShowMessage(snd[row]);
     inc(row);
     end;

     // Parsing and showing
     if (LabeledEdit1.Caption = '*') then parse(str) else
        parse(snd);
end;

procedure Tfclist.parse(txt: array of string);
var
   l:    smallint = 0;
   tmp:  string;
   col:  smallint = 0;
   row:  smallint = 0;
begin

// Sending to grid
   l:= 0;
   StringGrid1.Clear;
   StringGrid1.RowCount:= 1;

   while (l < length(txt)) do begin
         tmp:= txt[l];
         if tmp <> '' then begin
            tmp:= StringReplace(tmp, char(9), '', [rfReplaceAll]);
            inc(row);
            StringGrid1.RowCount:= StringGrid1.RowCount +1;

         while (col < 2) do begin
         //if (l > 4) then StringGrid1.RowCount:= l+1;
         StringGrid1.Cells[col, row]:= copy(tmp, 1, pos(',',tmp)-1);
         delete(tmp, 1, pos(',', tmp));
         inc(col);
         end;
         tmp:= StringReplace(tmp, ',', ' ', [rfReplaceAll]);
         StringGrid1.Cells[col, row]:= copy(tmp, 1, length(tmp));
   end;
   inc(l);
   col:= 0;
   end;

   label1.Visible:= true;
   label1.Caption:= inttostr(row) + ' channels';
end;



procedure Tfclist.openmClick(Sender: TObject);
var txt:   TextFile;
    l:     integer = 0;
    str:   TStrings;
    snd:   array of string;
    path:  string;
    tmp:   string;
begin
     {$ifdef linux}
        //path:= GetEnvironmentVariable('HOME') + '/' + fmainc.TreeView1.Selected.Text + ' channels.txt';
        path:= GetEnvironmentVariable('HOME') + '/' + 'Freenode ' + ' channels.txt';
     {$endif}

     {$ifdef Windows}
     //path:= GetEnvironmentVariable('PERSONAL') + fmainc.TreeView1.Selected.Text + ' channels.txt';
     {$endif}

     str:= TStringList.Create;
     odd.FileName:= path;

     if odd.Execute then begin
        str.LoadFromFile(odd.FileName);
        parse(snd);
     end;

     {
     SetLength(snd, str.Count);
     for l:= 0 to str.Count-1 do snd[l]:= str[l];
     }
     str.Free;

end;

procedure Tfclist.savemClick(Sender: TObject);
var
   exe:   boolean = false;
   path:  string;
   t:     TextFile;
begin
     {$ifdef linux}
        //path:= GetEnvironmentVariable('HOME') + '/' + fmainc.TreeView1.Selected.Text + ' channels.txt';
        path:= GetEnvironmentVariable('HOME') + '/' + 'Freenode ' + ' channels.csv';
     {$endif}

     {$ifdef Windows}
     //path:= GetEnvironmentVariable('PERSONAL') + fmainc.TreeView1.Selected.Text + ' channels.txt';
     {$endif}

     sdd.Filter:= 'Comma Separated Values|*.csv'; sdd.FileName:= path;

     while exe = false do begin
           exe:= true;

     if sdd.Execute then begin

        path:= ExtractFilePath(sdd.FileName);
        if not FileExists(path) then mkdir(path);

        path:= path + ExtractFileName(sdd.FileName);
        if ExtractFileExt(path) <> '.csv' then
           path:= path + '.csv';
           if FileExists(path) then
              if univ('File exists, do you want to overwrite it?', '', 1, savem) = false then
                 exe:= false else DeleteFile(path);

                 StringGrid1.SaveToCSVFile(path,',', true);

     end; // sdd.execute
     end; // while exe = false

end;


// Universal Ok
function Tfclist.univ(Txt, cption: PChar; Flags: longint; sender: tobject): boolean;
var reply, boxstyle: integer;
begin
     if flags = 1 then
           boxstyle :=  MB_ICONASTERISK + MB_YESNO else
           boxstyle :=  MB_ICONHAND + MB_OK;

     reply:= Application.MessageBox(Txt, pchar(Application.Title), boxstyle);

     if reply = idno then result:= false;
     if reply = idyes then result:= true;
end;

end.

