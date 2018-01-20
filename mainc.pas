unit mainc;

{$mode objfpc}{$H+}{$m+}

interface

uses
    Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
    StdCtrls, ExtCtrls, ComCtrls, Menus, ActnList, LCLIntf, LConvEncoding, blcksock, ssl_openssl, ssl_openssl_lib,
    SynEdit, SynHighlighterPosition,
    dateutils, abform, servf, chanlist, joinf, functions, Types, Clipbrd, kmessf, banlist;
    //LMessages; //, LType;

Type

{
  Tloop=class(TThread)
  public
    // the main body of the thread
  constructor Create(CreateSuspended: boolean);
  procedure Execute; override;
  end;
}
  tchans = record
    node:  smallint; // Tree node
    chan:  string;   // Connection number followed by chan name
    arr:   smallint; // array number
  end;

  { Tfmainc }

  Tfmainc = class(TForm)
    Image1: TImage;
    Image2: TImage;
    ImageList1: TImageList;
    Label2: TLabel;
    MainMenu1: TMainMenu;
    filem: TMenuItem;
    dconm: TMenuItem;
    clistm: TMenuItem;
    infm: TMenuItem;
    gvm: TMenuItem;
    bnickm: TMenuItem;
    banidm: TMenuItem;
    banipm: TMenuItem;
    kickm: TMenuItem;
    kbnm: TMenuItem;
    kbim: TMenuItem;
    kbipm: TMenuItem;
    banlm: TMenuItem;
    chanm: TMenuItem;
    gopm: TMenuItem;
    clink: TMenuItem;
    helpm: TMenuItem;
    abm: TMenuItem;
    hlpm: TMenuItem;
    optm: TMenuItem;
    poplm: TPopupMenu;
    topm: TMenuItem;
    tvm: TMenuItem;
    opam: TMenuItem;
    nckm: TMenuItem;
    rconm: TMenuItem;
    setm: TMenuItem;
    quitm: TMenuItem;
    openm: TMenuItem;
    servm: TMenuItem;
    joinm: TMenuItem;
    closem: TMenuItem;
    Splitter1: TSplitter;
    tclosem: TMenuItem;
    Timer1: TTimer;
    traypop: TPopupMenu;
    privm: TMenuItem;
    TrayIcon1: TTrayIcon;
    treepop: TPopupMenu;
    nickpop: TPopupMenu;
    servm1: TMenuItem;
    Notebook1: TNotebook;
    Server0: TPage;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    TreeView1: TTreeView;

    procedure abmClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure quitmClick(Sender: TObject);

    function dconmClick(Sender: TObject): smallint;
    procedure rconmClick(Sender: TObject);
    procedure TimerOnTimer(sender: TObject);

    function srchtree(nod: string):boolean; // Function which search duplicates rooms
    procedure mstatusChange(Sender: TObject);

    procedure servm1Click(Sender: TObject);
    procedure clistmClick(Sender: TObject);
    procedure banlmClick(Sender: TObject);
    procedure closemClick(Sender: TObject); // Delete Tree Item and leave a channel
    procedure closenClick(rc: smallint; c: string); // Delete Tree Items and TNotebook pages and close network

    procedure einputKeyPress(Sender: TObject; var Key: char);
    procedure einputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure joinmClick(Sender: TObject);
    procedure createlog(con: smallint; chann: string);
    function nicktab(ch: smallint; test: string):string;
    procedure raw(r: string);
    procedure fillnames(r: string; ch: smallint);
    procedure lbsort(a: smallint);
    function srchnick(nick: string; task, ch: smallint): string;
    procedure lbchange(nick1, newnick: string; task, a, con: smallint);

    procedure lbmouseup(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbxDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure tclosemClick(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);

    procedure TreeView1CustomDraw(Sender: TCustomTreeView; const ARect: TRect;
      var DefaultDraw: Boolean);
    procedure TreeView1CustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure TreeView1CustomCreateItem(Sender: TCustomTreeView;
      var ATreeNode: TTreenode);
    procedure TreeView1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TreeView1SelectionChanged(Sender: TObject);

    procedure txp(con: smallint; c,nick: string; r, query, go: boolean);
    procedure nbadd1(c,nick: string; con,i: smallint);
    procedure nbadd2(c,nick: string; con,i: smallint);
    function  cnode(task,nod,ord: smallint; chan: string) :smallint;

    //procedure wr(app: boolean; o: smallint); // o = memo id
    //procedure unwr(o: smallint); // o = memo id
    procedure infmClick(Sender: TObject);
    procedure privmClick(Sender: TObject);

    function nickinfo(nick: string): string;
    procedure bans(com, chan: string; con: smallint);
    procedure nickrclick(sender: TMenuItem);

    // Hypertext
    procedure tsynMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure tsynMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tsynPaint(Sender: TObject; ACanvas: TCanvas);
    procedure opmClick(Sender: TObject);
    procedure clinkClick(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;


  connex = class
  public
  num:     smallint;
  conn:    TTCPBlockSocket;
  nick:    string;
  nick2:   string;
  nick3:   string;

  public
  server:  string;
  servadd: string;
  constructor create;
  destructor destroy;
  procedure connect(co: smallint; createnode: boolean);
  procedure reconn;
  procedure join;
  procedure send(t: string);

  function loop: string;
  procedure recstatus(r: string);

  procedure output(c: tcolor; r: string; o: smallint);
  function gtopic(r: string): string;
  function gnicks(ch: string): string;

  end;

  TSyn = class(bsynedit)
  //property Cursor: TCursor write SetCursor default crNo;
  public
  var
     nnick,chan:   string;
     node:         smallint;
     first:        string;
     last:         smallint;        // The last line. Used to set the marker line
     shw:          boolean;         // If it is not visible, saves the last line for the marker line
     lc:            integer;        // When reach 100 lines becomes true
  //   lin:          TBitmap;
     com:          array of string; // Command history
     comn:         integer;         // Command position
  procedure procstring(r: string);
  procedure fcolors(app: boolean; co: tcolor; r: string);
  procedure wr(app: boolean); // o = memo id
  procedure unwr; // o = memo id
  //procedure tsynOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  //procedure crb(posx,posy: integer);
  end;


var
  fmainc: Tfmainc;
  net:      array[1..10] of connex;
  //conn:     array[0..9] of TTCPBlockSocket;
  log:      array of string; // Log file names
  t:        TextFile;
  chanod:   array of tchans; // Chans and nodes. Remember chan names are preceded by connection number
  m0:       array[0..20] of TSyn;
  ed0:      array[0..20] of TEdit;
  gb0:      array[1..20] of TGroupBox;
  lb0:      array[1..20] of TListBox;
  lab0:     array[1..20] of TLabel;
  splt:     array[1..20] of TSplitter;
  //com:      array of array of string;
  rc:       smallint; // right click treenode or nick / Send origin
  gr:       array[1..4] of TPortableNetworkGraphic;
  str:      string; // Hyperlink in clipboard

implementation

{$R *.lfm}

{ Tfmainc }


constructor connex.create;
begin
     conn:= TTCPBlockSocket.Create;
end;

destructor connex.destroy;
begin
     FreeAndNil(conn);
end;


procedure connex.connect(co: smallint; createnode: boolean);
var
   n:    smallint = 0; // Node absolute index to get the memo for MOTD
   r:    string;
   mess: string;
begin
     //fmainc.TreeView1.Items[0].Text:= fserv.netw.Caption;
     //ShowMessage(inttostr(co));
     if fmainc.TreeView1.Selected = nil then
        fmainc.TreeView1.Items[0].Selected:= true;

     num:= co; // Connection number

     if createnode = true then begin
        //if not fserv.globalc.Checked then
           server:= fserv.netw.Caption;
           servadd:= fserv.serv.Caption;
           if fmainc.TreeView1.items[0].Text[1] <> '(' then
             fmainc.txp(num, server, fserv.nick1.Caption, true, true, true) else
             fmainc.txp(co, server, fserv.nick1.Caption, true, true, true);
     end;

     if fserv.nick1.Caption <> '' then
        if not fserv.globalc.Checked then
           nick:= fserv.nick1.Caption else
           nick:= fserv.gnick1.Caption else
           nick:= 'Lemon1';

     //TTCBlockSocket.Create;
     //Tloop.Create(true); // Connecting
     //Tloop.Start;
     conn.SetRemoteSin('','');
     while (conn.GetRemoteSinIP = '') do begin
           conn.Connect(servadd, fserv.Port.Caption);
           if (fserv.Port.Caption = '6697') or (fserv.Port.Caption = '7000') or (fserv.Port.Caption = '7070') then
           conn.SSLDoConnect;
           if (conn.GetRemoteSinIP = '') then conn.CloseSocket;
     end;
     //if conn.GetRemoteSinIP <> '' then ShowMessage(conn.GetRemoteSinIP);
     fmainc.timer1.Interval:= 50;

     if conn.GetRemoteSinIP <> '' then

     try
        fmainc.timer1.Interval:= 50;
        //conn.SendString('PASS oasis ' + #13#10);
        conn.SendString('NICK ' + nick + #13#10);

        if not fserv.globalc.Checked then
        conn.sendstring('USER ' + nick + ' 0 * :' + fserv.rname.Caption + #13#10) else
           conn.sendstring('USER ' + nick + ' 0 * :' + fserv.grname.Caption + #13#10);

        //conn.SendString('USER McClane 0 * :John McClane' + #13#10);// You want to use SendStream or SendStreamRaw for binary.

        //conn.SendString('SERVICE dict * *.fr 0 0 :French Dictionary %x0D%x0A');
        //conn.SendString('MOTD ' + #13#10);

        //conn.SendString('JOIN #nvz ' + #13#10);
        //conn.SendString('TOPIC #nvz ' + #13#10);

        // Deleting parenthesis
        if createnode = false then begin
            while (fmainc.TreeView1.Items[n].Index < num) do
                  n:= fmainc.TreeView1.Items[n].GetNextSibling.AbsoluteIndex;

              fmainc.TreeView1.Items[n].Text:= StringReplace(fmainc.TreeView1.Items[n].Text, '(', '', [rfReplaceAll]);
              fmainc.TreeView1.Items[n].Text:= StringReplace(fmainc.TreeView1.Items[n].Text, ')', '', [rfReplaceAll]);
        server:= fmainc.TreeView1.Items[n].Text;
        end;
        n:= 0;


// Getting TreeNode and Getting MOTD

   while (fmainc.TreeView1.Items[n].Index < num) do begin
         n:= fmainc.TreeView1.Items[n].GetNextSibling.AbsoluteIndex;
   end;
   //if fmainc.TreeView1.Items.Count = 2 then n:= 1;

   if conn.GetRemoteSinIP <> '' then m0[n].Lines.Add('Connected... now logging in');

   fmainc.TreeView1.Items[n].Selected:= true;
   m0[n].chan:= inttostr(num) + fmainc.TreeView1.Items[n].Text;
   //fmainc.createlog(co, server);

{
   // Testing connection
   //fmainc.createlog('test');
   r:= '';
   fmainc.Timer1.Enabled:= true;
   repeat
   r:= '';
   r:= conn.RecvString(1000);

   // Processing r
   delete(r, 1, 1);
   mess:= copy(r, pos(':', r)+1, length(r));
   if (pos('NOTICE', r) = 0) then
      r:= copy(r, pos(nick, r)+length(nick)+1, length(r)) else
      r:= '';
   delete(r, pos(mess, r)-1, length(r));

   output(clnone, r, n);
   until r = '';
   }
   //writeln(t, r + mess);
   {
   m0[n].lines.append(r + mess);
   m0[n].SelStart:= length(m0[n].Text);

   m0[n].Append(r);

   output(clnone, r, n);
   writeln(t, r);

   until r='';
   closefile(t);
   }
   if not fmainc.timer1.Enabled then fmainc.Timer1.Enabled:= true;

     except
           //mstatus.SetHtml(conn.LastErrorDesc);
     end;

{
     fmainc.txp('none', true, true);
     fmainc.txp('none', false, false);
     fmainc.txp('none', true, true);
     fmainc.TreeView1.Items[0].Selected:= true;
     fmainc.txp('none', false, true);
     //fmainc.privmClick(nil);
}
end;

procedure connex.reconn;
begin
     //conn.AbortSocket;
     num:= num -1;
     connect(num, false);
end;

{
constructor Tloop.Create(CreateSuspended : boolean);
  begin
    FreeOnTerminate := True;
    inherited Create(CreateSuspended);
  end;

procedure Tloop.Execute;
const c: smallint = 0;
begin
     //TTCPBlockSocket[c].Create;
     //while conn[c].GetRemoteSinIP = '' do conn[c].Connect(fserv.serv.Caption, fserv.Port.Caption);
end;
}

function Tfmainc.dconmClick(Sender: TObject): smallint;
var
   s:   smallint = 0;
   n:   smallint = 0;
begin
     if (TreeView1.Selected.Parent = nil) then s:= TreeView1.Selected.AbsoluteIndex else
        s:= TreeView1.Selected.Parent.AbsoluteIndex;
        n:= s;

     //if not (sender = rconm) then
     repeat
           if pos('(', TreeView1.Items[n].Text) = 0 then begin
           TreeView1.Items[n].Text:= '(' + TreeView1.Items[n].Text + ')';
           m0[n].Append('Disconnected');
           end;
           if assigned(lb0[n]) then lb0[n].Clear;
     inc(n);
     if (n < TreeView1.Items.Count) then
        if (TreeView1.Items[n].Parent = nil) then n:= TreeView1.Items.Count;
     until (n = TreeView1.Items.Count);

     if (TreeView1.Selected.Parent = nil) then s:= TreeView1.Selected.Index else
        s:= TreeView1.Selected.Parent.Index;

     //net[s+1].conn.SendString('KILL' + #13#10);
     //net[s+1].conn.SendString('KILL ' + net[s+1].nick + #13#10);
     net[s+1].conn.CloseSocket;
     //ShowMessage(net[s+1].conn.SocksIP:= '');
     result:= s+1;
end;

procedure Tfmainc.rconmClick(Sender: TObject);
var
   s: smallint = 0;
begin
     if (TreeView1.Selected.Parent = nil) then s:= TreeView1.Selected.Index else
        s:= TreeView1.Selected.Parent.Index;

     s:= dconmClick(rconm);
     net[s].conn.CloseSocket;
     net[s].connect(s-1, false);
end;


procedure connex.join;
begin
     conn.SendString('JOIN ' + fjoin.jedit.Caption + #13#10);
end;

procedure connex.send(t: string);
begin
     conn.SendString(t + #13#10);
end;

// Starting date thu 2016-sep-08
// 4500 lines 2017-nov-24
procedure Tfmainc.FormActivate(Sender: TObject);
var n: smallint = 0;
begin
     caption:= 'n-chat';
     //einput.SetFocus;
     TrayIcon1.Show;
     if not assigned(m0[0]) then begin
        fserv.Show;

        for n:= 1 to 4 do begin
            gr[n]:= TPortableNetworkGraphic.Create;
        end;

        gr[1].LoadFromFile( ExtractFilePath(ParamStr(0)) + 'vio.png' );
        gr[2].LoadFromFile( ExtractFilePath(ParamStr(0)) + 'blue.png' );
        gr[3].LoadFromFile( ExtractFilePath(ParamStr(0)) + 'green.png' );
        gr[4].LoadFromFile( ExtractFilePath(ParamStr(0)) + 'voice.png' );
     end;
     {TreeView1.SelectionFontColor:= clblue;
     TreeView1.Items[0].Selected:=true;}
end;

procedure Tfmainc.abmClick(Sender: TObject);
begin
     abf.ShowModal;
end;


procedure Tfmainc.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var i: smallint = 0;
begin
     while (i < length(log)) do begin
           AssignFile(t, log[i]);
           //ShowMessage(log[i]);
           if FileExists(log[i]) then append(t);
           writeln(t, '**** END LOGGING AT ' + FormatDateTime('MMMM, ddd d hh:mm:ss yyyy', now));
           writeln(t, #13#10);
           //writeln(t, #13#10);
           CloseFile(t);
     inc(i);
     end;
     for i:= 1 to 4 do gr[i].Free;
end;


procedure Tfmainc.FormWindowStateChange(Sender: TObject);
var w: smallint = 0;
    n: smallint = 1;
begin
     while Assigned(splt[n]) do begin
           //ShowMessage(inttostr(fmainc.Width));
           splt[n].Left:= trunc(fmainc.Width * (800) / 1106);
     inc(n);
     end;
     //ShowMessage(inttostr(lb0[1].Width))
end;


procedure Tfmainc.quitmClick(Sender: TObject);
begin
     close;
end;


procedure Tfmainc.FormPaint(Sender: TObject);
begin
     if assigned(m0[1]) then begin
        if fmainc.Active then TreeView1SelectionChanged(fmainc);
     end;
end;

procedure Tfmainc.FormResize(Sender: TObject);
begin
     Splitter1Moved(nil);
end;


// Menus
procedure Tfmainc.servm1Click(Sender: TObject);
begin
     fserv.Show;
end;

procedure Tfmainc.clistmClick(Sender: TObject);
begin
     fclist.Show;
end;

procedure tfmainc.joinmClick(Sender: TObject);
begin

     //net[1].timer.Enabled:= false;
     fjoin.ShowModal;

     with fjoin do
        if (jedit.Caption <> '') then begin
           if (pos('#', jedit.caption) = 0) then
           jedit.Caption:= '#' + jedit.Caption;
           if jedit.Caption <> '#' then
           if TreeView1.Selected.Parent = nil then
              //net[TreeView1.Selected.Index +1].conn.SendString('JOIN ' + jedit.Caption + #13#10) else
              //net[TreeView1.Selected.Parent.Index +1].conn.SendString('JOIN ' + jedit.Caption + #13#10);
              net[TreeView1.Selected.Index +1].join else
              net[TreeView1.Selected.Parent.Index +1].join;

           jedit.Caption:= '#';
        end;

     //net[1].timer.Enabled:= true;
     //txp('jpña', false, false);
     //TreeView1.Items.AddFirst(nil, 'hola');
end;

procedure Tfmainc.banlmClick(Sender: TObject);
begin
     if (fmainc.TreeView1.Selected <> nil) then
        if fmainc.TreeView1.Selected.Parent = nil then
           univ('To see bans list, please select a channel', '', 0, nil)
           else fbanlist.FormActivate(banlm);
end;


procedure tfmainc.createlog(con: smallint; chann: string);
var
   i:             smallint = 0;
   path:          string;
begin
     path:= ExtractFilePath(paramstr(0)) + 'logs/';
     if not DirectoryExists(path) then mkdir(path);

     {
     // Getting server from treeview
     if TreeView1.Selected.Parent = nil then
        path:= path + TreeView1.Selected.Text else
           path:= path + TreeView1.Selected.Parent.Text;
     if not DirectoryExists(path) then mkdir(path);
     }

     // Getting server from con
     path:= path + net[con+1].server;
     if not DirectoryExists(path) then mkdir(path);

     //if pos('#', chann) > 0 then delete(chann, 1, 1);

     chann:= StringReplace(chann, '-', '_', [rfReplaceAll]);
     path:= path + DirectorySeparator + chann;

     if length(log) = 0 then SetLength(log, 1);

     while (path <> log[i]) and (i < length(log)-1) do inc(i);

         if length(log) = 1 then i:= 0;
         if (path <> log[i]) and (log[i] <> '') then begin
            inc(i);
            SetLength(log, i+1);
         //if (i > 0) then ShowMessage(inttostr(i));
         end;

     try

     //ShowMessage(path);
     AssignFile(t, path);
     if not FileExists(path) then Rewrite(t) else append(t);
     // Adding header
        if (FileSize(path) = 0) or (dateof(FileDateToDateTime(FileAge(path))) <> Today) then
           writeln(t, '**** LOGGING STARTED AT ' + FormatDateTime('MMMM, ddd d hh:mm:ss yyyy', now));
     log[i]:= path;
     finally
     end;
end;


function tfmainc.srchtree(nod: string):boolean; // Function which search duplicates rooms
// Returns true if finds duplicates
var i: smallint = 0;
    a: string   = '';
begin
     result:= false;
     with TreeView1 do
          while (i < TreeView1.Items.Count) do begin
                if Items[i].Text = nod then a:= Items[i].Text;
                inc(i);
                if i < items.Count then
                   if a = Items[i].Text then result:= true;
          end;
end;

procedure tfmainc.einputKeyPress(Sender: TObject; var Key: char);
const
    //l:    array of smallint = nil;          // array history
    trm:  smallint = 0;                    // tree history // Right memo array pos
var ne:   smallint;
    n:    smallint = 0;
    tc:   TControl;
    s:    string;
    b:    string;
    chan: string;
    pin:  smallint = 0;                    // Page index
begin
     with fmainc do begin

     if TreeView1.Selected.Parent = nil then
        ne:= TreeView1.Selected.Index +1 else
        ne:= TreeView1.Selected.Parent.Index +1;

     {
     // Getting page index from m0[].node
     s:= Notebook1.Page[0].name;
     //ShowMessage(s);
     if s <> '' then
     while (strtoint(s[length(s)]) > TreeView1.Selected.AbsoluteIndex) do begin
           s:= Notebook1.Page[n].name;
           inc(pin);
     end;
     }
     pin:= Notebook1.PageIndex;

     //ShowMessage('Chan: ' + chan + ' n: ' + inttostr(n) + ' pi: ' + inttostr(Notebook1.PageIndex));
     while not (Notebook1.Page[pin].Controls[n] is TSyn) do inc(n);
           tc:= Notebook1.Page[pin].Controls[n];
           s:= tsyn(Notebook1.Page[pin].Controls[n]).name;
           chan:= tsyn(tsyn(Notebook1.Page[pin].Controls[n])).chan;
           chan:= copy(chan, 2, length(chan));   // Chanel name
           //s:= copy(s, pos('_',s)+1, length(s)); // Memo number
           trm:= TreeView1.Selected.AbsoluteIndex;
           n:= cnode(5, trm,0,'');
           //if pos('#', chan) = 0 then chan:= '';
           //ShowMessage(inttostr(n));


     if key = #13 then begin

        //while (m0[n].node <> TreeView1.Selected.AbsoluteIndex) do inc(n); trm:= n; // Getting memo
        SetLength(m0[n].com, length(m0[n].com)+1);
        //SetLength(com, TreeView1.Items.Count, l[trm]+2);
        createlog(ne-1, TreeView1.Selected.Text);

        if TEdit(sender).Caption <> '' then begin

           s:= TEdit(sender).Caption;

               if not (TreeView1.Items[ne-1].HasChildren) then
               if (pos('/nick ', s) = 1) then net[ne].nick:= copy(s, pos(' ',s)+1, length(s));

           if (pos(lowercase('/list'), lowercase(s)) = 1) then fclist.getchannels(ne, net[ne].nick) else

           if (pos('/query', lowercase(s)) = 1) then begin
              if (pos('#', replce(s)) > 0) then
                 m0[n].Append('Usage /query <nick>, opens a private message window for someone') else
                 txp(ne-1,replce(s), net[ne].nick,false,true,true);
                 m0[n].CaretY:= m0[n].Lines.Count;
           end else

           if (pos('/', s) = 1) then begin

              // Bans
              if (pos('/ban', s) = 1) or (pos('/kb', s) = 1) then begin
                 s:= StringReplace(s, '   ', ' ', [rfReplaceAll]);
                 s:= StringReplace(s, '  ', ' ', [rfReplaceAll]);
                 //if (s[length(s)] = ' ') then delete(s, length(s), 1);
                 bans(s, chan, ne);
                 //ShowMessage('hey ' + s);

              end else

              if (pos(lowercase('/topic'), lowercase(s)) = 1) or
                 (pos(lowercase('/op'),lowercase(s)) = 1) or (pos(lowercase('/deop'),lowercase(s)) = 1) or
                 (pos(lowercase('/voice'),lowercase(s)) = 1) or (pos(lowercase('/devoice'),lowercase(s)) = 1) or
                 (pos(lowercase('/ban'),lowercase(s)) = 1) or (pos(lowercase('/unban'),lowercase(s)) = 1) or
                 (pos(lowercase('/kick'),lowercase(s)) = 1) or (pos(lowercase('/invite'),lowercase(s)) = 1)
                 then

              //if (pos('/ban', s) = 0) and (pos('/kb', s) = 0) then s:= s + ':' + chan;
              //if (pos('/ban', s) = 0) and (pos('/kb', s) = 0) then begin

                 net[ne].conn.SendString(replce(s + ':' + chan))
                 //ShowMessage(replce(s + ':' + chan))
              else
                  if (pos('/me', lowercase(s)) = 1) then
                  net[ne].send('PRIVMSG ' + copy(m0[n].chan,2,length(m0[n].chan)) + ' :' + replce(StringReplace(s, '/', '/ ', [rfReplaceAll]))) else
                  net[ne].conn.SendString(replce(s));
              //com[trm, l[trm]]:= s;
              //inc(l[trm]);
              m0[n].com[length(m0[n].com)-1]:= s;
              //inc(m0[n].comn);

              if (pos('/me', lowercase(TEdit(sender).Caption)) = 1) then net[ne].output(clPurple, replce(s + ':'+m0[n].nnick), n);
           end else begin

           rc:= n;

           //ShowMessage(inttostr(n));
           //net[1].conn.SendString('PRIVMSG ' + m0[n] + ' :' + s + #13#10) else
           //if chan[n] <> TreeView1.Selected.Text then chan[n]:= TreeView1.Selected.Text;
           //if assigned(m0[3]) then ShowMessage(copy(m0[n].chan,2,length(m0[n].chan)));

           net[ne].send('PRIVMSG ' + copy(m0[n].chan,2,length(m0[n].chan)) + ' :' + s + #13#10);

           net[ne].output(clnone, net[ne].nick + ': ' + s, n);
           CloseFile(t);

           //com[trm, l[trm]]:= s;
           //inc(l[trm]);
           //m0[n].com[length(m0[n].com)-1]:= s;
           end;
        end;
        TEdit(sender).Clear;
        m0[n].com[length(m0[n].com)-1]:= s;
        m0[n].comn:= length(m0[n].com);
     end;
     //tr:= TreeView1.Selected.AbsoluteIndex;
     end; // fmainc
end;


procedure tfmainc.einputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
const
      l:     smallint = 1;                     // array history
      tr:    smallint = 0;                     // tree history
      trm:   smallint = 0;                     // Right memo to get array position
      gnick: string = '';
      gn2:   string = '';
      last:  string = '';
var
   s:  string;
   ctrl: smallint = 0;
   pin:  smallint = 0;
   n:     smallint = 0;                     // array history
   x:     smallint = 0;
begin
     with fmainc do begin

     {
     // Getting page index from m0[].node
     s:= Notebook1.Page[Notebook1.PageIndex].name;
     if s <> '' then
          while (strtoint(s[length(s)]) < TreeView1.Selected.AbsoluteIndex) do begin
           s:= Notebook1.Page[pin].name;
           inc(pin);
     end;
     }
     pin:= Notebook1.PageIndex;

     // Getting the right memo to get treenode (notebook.page)
     ctrl:= 0;
     while not (Notebook1.Page[pin].Controls[ctrl] is TSyn) do inc(ctrl);
           s:= Notebook1.Page[pin].Controls[ctrl].Name;
           trm:= TreeView1.Selected.AbsoluteIndex;
           n:= cnode(5, trm,0,'');
           //ShowMessage('n: ' + inttostr(tsyn(Notebook1.page[Notebook1.PageIndex].Controls[ctrl]).node));

     // Re Page
     if (key = 33) or (key = 34) then
        if Shift = [ssCtrl] then begin

        if (key = 33) then begin
           if (TreeView1.Selected.AbsoluteIndex > 0) then
              TreeView1.Items[TreeView1.Selected.AbsoluteIndex -1].Selected:= true else
           if TreeView1.Items[0].Selected then
              TreeView1.Items[TreeView1.Items.Count -1].Selected:= true;
        end;

     // Av Page
        if (key = 34) then begin
           if (TreeView1.Selected.AbsoluteIndex < TreeView1.Items.Count -1) then
           TreeView1.Items[TreeView1.Selected.AbsoluteIndex +1].Selected:= true else
              TreeView1.Items[0].Selected:= true;
        end;

     key:= 0;
     end else // ssctl
         // Setting focus on TRichMemo when RPage and APage are pressed
         if (key = 33) or (key = 34) then m0[trm].SetFocus;
     end; // Fmainc
     ctrl:= 0;
     while not (Notebook1.Page[pin].Controls[ctrl] is TEdit) do inc(ctrl);
           //sender:= Notebook1.Page[pin].Controls[ctrl];

     // 38 / 40 UP DOwn arrow / Command history
     {Every TSyn has its own array of command history and comn is the last position}
     if length(m0[n].com) > 0 then begin

     if key = 38 then begin
        //if TEdit(sender).Caption = '' then m0[n].comn:= length(m0[n].com)-1;
           if m0[n].comn > 0 then dec(m0[n].comn);
           TEdit(sender).Caption:= m0[n].com[m0[n].comn];
           //if TEdit(sender).Caption <> '' then
           TEdit(sender).SelStart:= length(TEdit(sender).Caption);
     end;

     if key = 40 then begin
           if (length(m0[n].com) > 0) and (m0[n].comn < length(m0[n].com)) then inc(m0[n].comn); //and (n < length(com)) then inc(n);
           if m0[n].comn = length(m0[n].com) then
           TEdit(sender).Caption:= '' else
           TEdit(sender).Caption:= m0[n].com[m0[n].comn];
           TEdit(sender).SelStart:= length(TEdit(sender).Caption);
     end;
     end; // Up and down (Command History)

     // Tab completion
     if key = 9 then begin
        x:= trm;
        x:= cnode(5, x, 0, '');

        s:= tedit(sender).Caption;
        key := 0;
        ctrl:= TEdit(sender).CaretPos.X;
        if ctrl > 0 then
        if (s[ctrl] <> ' ') and (s <> '') then begin
           gnick:= copy(s, 1, ctrl);
           while (pos(' ', gnick) > 0) do delete(gnick, 1, pos(' ', gnick));
           last:= gnick;
        end;

        if assigned(lb0[x]) then gn2:= nicktab(x, gnick) else
           if (pos(gnick, lowercase(TreeView1.Selected.Text)) = 1) then gn2:= TreeView1.Selected.Text + ' ' else gn2:= '';

        if (ctrl > 0) then
           if (gn2 <> tedit(sender).Caption) and (gn2 <> '') then
        TEdit(sender).Caption:= copy( s, 1, ctrl - length(last)) +
        StringReplace(last, last, gn2, [rfReplaceAll]) + copy(tedit(sender).Caption, ctrl+1, length(s));

        //TEdit(sender).Caption:= StringReplace(TEdit(sender).Caption, last, gn2 + ' ', [rfReplaceAll]);

        if ctrl > 0 then if gn2 <> '' then
           TEdit(sender).SelStart:= ctrl - length(last) + length(gn2) else
           TEdit(sender).SelStart:= ctrl;
        last:= gn2;

     //end; // Assigned(lb0[x])
     end; // Key 9 (tab)
end;

procedure Tfmainc.Memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var n: smallint = 0;
begin
     with fmainc do begin
          if Notebook1.Page[Notebook1.PageIndex].ControlCount > 1 then
             while not (Notebook1.Page[Notebook1.PageIndex].Controls[n] is TEdit) do inc(n);
             tedit(Notebook1.Page[Notebook1.PageIndex].Controls[n]).SetFocus;     end;
end;

procedure tfmainc.raw(r: string);
var ro: TextFile;
begin
     if (r <> '') then m0[0].Lines.Add(r);
        AssignFile(ro, '/home/nor/lmc.txt');
        Rewrite(ro);
     append(ro);
     if (r <> '') then writeln(ro, r);
     closefile(ro);
end;

function connex.loop: string;
var r: string = ''; // recvstring
begin      r:= conn.RecvString(200);
           //if (pos('PING', r) > 0) then conn.SendString('PONG ' + copy(r, pos(':', r)+1, length(r)) + #13#10);
           if (r <> '' ) and (pos('PING :', r) = 0) then
           result:= r;
           recstatus(r);
           //fmainc.raw(r);
end;

procedure connex.recstatus(r: string);
var
          room:  boolean = false;
          n:     smallint = 0;
          m:     smallint = 0;
          s:     smallint = 0;
          cname: string = ''; // Channel name
          mess:  string;      // Message
          tmp:   string;
begin
        // Getting connection in the tree where num = connection number starting with 0
        //if (num = 0) then ShowMessage('zero');
        //if num > 0 then
        while (fmainc.TreeView1.Items[n].Index < num) do begin
              //ShowMessage(fmainc.TreeView1.Items[n].Text);
              if (fmainc.TreeView1.Items[n].GetNextSibling <> nil) then
              n:= fmainc.TreeView1.Items[n].GetNextSibling.AbsoluteIndex;
              //while (n <> m0[n].node) do inc(n);
        end;
           //if assigned(net[num]) then ShowMessage(inttostr(num));
           n:= fmainc.cnode(2,0,0,inttostr(num) + server);
     //if (assigned(m0[2])) and (pos('PART', r) > 0) then ShowMessage('n: ' + inttostr(n) + ' r: ' + r);

     if (pos(nick, r) > 0) and (pos('PART', r) > 0) then begin
        r:= 'PART :You left ' + copy(r, pos('#',r), length(r));
        //ShowMessage(r + ' n ' + inttostr(n));
     end;

     if (pos('PING', r) > 0) then begin
        conn.SendString('PONG ' + copy(r, pos(':', r)+1, length(r)) +#13#10);
     end;

     {
     if (pos('MODE', r) > 0) or (pos('Spotchat.org', r) > 0) or (pos('PING', r) > 0)
     and (pos('/MODE', r) = 0) and (pos('CHANMODES',r) = 0) and (pos('NICKLEN', r) = 0) then begin

        fmainc.createlog('test');
        writeln(t, r);
        closefile(t);
     end;
     }
     //if (pos('NOTICE', r) > 0) then ShowMessage(r);

     delete(r, 1, 1); // First colon

     //if (pos('331', r) > 0) or (pos('332', r) > 0) or (pos('333', r) > 0) then ShowMessage(r);

     {// Raw hispano
     if (not assigned(m0[1])) then begin
        assignfile(t, '/home/nor/Lazarus/n-chat3/Accessories/raw hispano');
        append(t);
        writeln(t, r);
        closefile(t);
     end;
     }

     // Getting Message
     tmp:= r;
     if pos(':', r) > 0 then begin
        mess:= copy(r, pos(':', r)+1, length(r));
         if (pos(':', r) > 0) and (pos('!',r) = 0) then r:= copy(r, 1, pos(':', r)-1);
         if (pos('TOPICLEN', tmp) = 0) then
         if (pos('JOIN', tmp) > 0) then r:= tmp;
     end;

     // Getting Server and Channel
     //if emotd = true then begin
     {
     if pos('McClane', r) > 0 then ShowMessage(r);
     delete(cname, pos(':', cname)-1, length(cname));
     if (pos('PRIVMSG',r) > 0) and (pos('!', r) > 0) then begin
        cname:= copy(r, 1, pos('!',r)-1);
     end else
     }

     if (pos(nick + '!', r) > 0) and (pos('JOIN', r) > 0)  then s:= 1;
     if (pos('NICK ', r) > 0) then s:= 2;
     if (pos('PRIVMSG', r) > 0) and (pos('@', r) > 0) and (pos('MODE', r) = 0) then s:= 3;
     //if (pos(copy(r, 2, pos('!', r) -1), r) = 0) and
     if (pos(nick, r) = 0) and (pos('JOIN', r) > 0) or (pos('PART', r) > 0) or (pos('QUIT', r) > 0) and
        (pos('QUITLEN',r) = 0) then s:= 4;
     if (pos('NOTICE ' + nick, r) > 0) then s:= 5;
     //if (pos('@', r) > 0) and (pos('!', r) > 0) and (pos('JOIN', r) = 0) then s:= 6; // Whois
     //if (pos('QUERY', r) > 0) and (pos('coccco', r) > 0) then s:= 7;
     //if fmainc.TreeView1.Items[n].HasChildren then
     //if (pos('#', r) > 0) and (pos('MODE', r) > 0) and (pos('MODES',r) = 0) then s:= 8;
     //if assigned(m0[1]) then ShowMessage(r);
     if (pos('TOPIC #', tmp) > 0) or (pos('331 ' + nick, tmp) > 0) or (pos('332 ' + nick, tmp) > 0) or (pos('333 ' + nick, tmp) > 0) then s:= 6;
     if (pos('INVITE',r) > 0) and (pos('341', r) > 0) then s:= 7;
     if (pos('KICK',r) > 0) and (pos('KICKLEN', r) = 0) then s:= 8;

     //if (assigned(m0[2])) and (pos('ART', r) > 0) then ShowMessage('n: ' + inttostr(n) + ' r: ' + r);
     if (pos('#', r) > 0) and (pos('=#',r) = 0) then begin
        cname:= r; cname:= StringReplace(cname, ':', ' ', [rfReplaceAll]);
        while pos('#', cname) > 1 do delete(cname, 1, pos(' ', cname));

     if cname <> '' then
     delete(cname, pos(' ', cname), length(cname));
     cname:= inttostr(num) + cname;
     end;
     if cname = '' then cname:= inttostr(num) + server;
     //if pos('topic is set', mess) > 0 then ShowMessage('mess ' + r);

     {
     // Getting the right memo
     if fmainc.TreeView1.Items[n].HasChildren then
        if (cname <> '') then
        if (pos('JOIN',r) = 0) then
           n:= fmainc.cnode(2,0,0, cname);
      }
     if (pos('You left', mess) > 0) then begin
        n:= fmainc.cnode(2,0,0, inttostr(num) + server);
     end;

     //if (mess <> '') then ShowMessage(r);
     //if cname <> '' then while (not assigned(m0[n])) do inc(n);

case s of
     0: Begin // MOTD

        if r <> '' then fmainc.Timer1.Interval:= 50 else
                        fmainc.Timer1.Interval:= 2000;

        if (r <> '') and (mess <> '') then begin
           //if (pos('hola', mess) > 0) then ShowMessage(mess);

        fmainc.createlog(num, server); //file open on connect

           if (pos('MODE ',r) > 0) then begin
              if mess = '' then begin
                 mess:= r;

              r:= copy(r, pos(nick, r) + length(nick)+1, pos(':', r)-1);
              if r <> ' ' then begin // space
                 mess:= copy(mess, pos(':', mess)+1, length(r));
                 mess:= r + mess;
              end;

              while (pos(':', mess) > 0) do delete(mess, 1, pos(':',mess));
              end;

              if (pos('!',r) > 0) then
              r:= copy(r, 1, pos('!',r)-1) else
              r:= copy(r, 1, pos(' ',r)-1);
              r:= r + ' sets mode ' + mess;

              //writeln(t, r);
              output(clnone, r, n);
              //m0[n].SelStart:= length(m0[n].Text);

           end else begin

           if (pos ('NOTICE',r) = 0) or (pos('CNOTICE',r) > 0) then
              r:= copy(r, pos(nick, r)+length(nick), length(r)) else
              r:= '';
              r:= StringReplace(r, char(3), '', [rfReplaceAll]);

           //delete(r, pos(mess, r)-1, length(r));
           //if pos('31,', mess) > 0 then ShowMessage(r + mess);
           //writeln(t, r + mess);
           output(clnone, r+mess, n);
           //m0[1].Lines.LoadFromFile(log[0]);
        end;
           if (pos('End of', mess) > 0) then fmainc.Timer1.Interval:= 2000;
           closefile(t);
        end;
     end;

     1: Begin // Join
       // Create room tab
       //ShowMessage('J: '+ cname);

       // Searching for created room
       //if num > 0 then
       n:= 0;
       while (fmainc.TreeView1.Items[n].Index < num) do
             n:= fmainc.TreeView1.Items[n].GetNextSibling.AbsoluteIndex;
       if (fmainc.TreeView1.Items[n].HasChildren) then
          while (n < fmainc.TreeView1.Items.Count) do begin
                if ('(' + copy(cname, 2, length(cname)) + ')' = fmainc.TreeView1.Items[n].Text) then room:= true;
                   fmainc.TreeView1.Items[n].Text:= StringReplace(fmainc.TreeView1.Items[n].Text, '(', '', [rfReplaceAll]);
                   fmainc.TreeView1.Items[n].Text:= StringReplace(fmainc.TreeView1.Items[n].Text, ')', '', [rfReplaceAll]);
       inc(n);
       end;

       if room = false then
       fmainc.txp(num, copy(r, pos('#', r), length(r)), nick, false, false, true);

       //closefile(t);

       //chan[fmainc.TreeView1.Selected.AbsoluteIndex]:= server + '_' + copy(r, pos('#', r), length(r));

       // Getting the right memo
       //ShowMessage('hoa cname: ' + cname + ' r: '+r);
       n:= fmainc.cnode(2,0,0, cname);

       //m0[n].Canvas.Pen.Color:= clred;
       //m0[n].Canvas.Line(0,m0[n].CaretY, m0[n].Width,m0[n].CaretY);

       fmainc.createlog(num, copy(cname, 2, length(cname)));

       fmainc.Timer1.Enabled:= false;
       repeat
        r:= '';
        r:= conn.recvstring(1000);
             //if pos ('Make sure to read the topic', r) > 0 then ShowMessage(r);
        //while (pos(':', r) > 0 ) do delete(r, 1, pos(':', r));
        if r <> '' then begin

        // MODE
        if (pos('MODE', r) > 0) and (pos(nick, r) = 0) then
           output(clnone, copy(r, pos(':', r)+1, pos(' ', r)-1) + 'sets ' + copy(r, pos('MODE', r), length(r)), n);

        // TOPIC
        //if (pos('333 ' + nick, r) = 0) and (pos('332 ' + nick, r) = 0) then conn.SendString('TOPIC ' + copy(m0[n].chan, 2, length(m0[n].chan)) +#13#10);
        if (pos('332 ' + nick, r) > 0) then begin
           if r = '' then r:= mess;

           delete(r, 1, pos('#',r));
           delete(r, 1, pos(' ',r)+1);

           if pos('Topic is', r) = 0 then
            //r:=  copy(r, pos(':', r)+1, length(r)) else
            r:= 'Topic for ' + copy(cname, 2, length(cname)) + ' is: ' + r;
               //if pos(char(3), r) = 0 then
               output(clpurple, r, n); // else output(clnone, r, n);
        end;

        {end else // Topic exists
            if (pos('/NAMES', r) = 0) then output(clnone, r, n);}


         if (pos('333 ' + nick, r) > 0) then begin
               r:= gtopic(r);
               output(clblue, r, n);
        //ShowMessage(r);

         end;
        if (pos('353 ' + nick, r) > 0) then begin // and (pos('/NAMES', r) = 0) do begin
        // NICKS
        //repeat
              //lb0[n].Clear;
              //ShowMessage('nicks ' + r);
              fmainc.fillnames(r, n);
              fmainc.lbsort(n);
              //r:= conn.RecvString(200);
              //r:= conn.RecvString(200);
        //until pos('/NAMES', r) > 0;           // END of /NAMES list
        end;

        // SERVICES
        if (pos('NOTICE', uppercase(r)) > 0) or (pos('service', lowercase(r)) > 0) then begin
           delete(r, 1, pos(':', r));
           delete(r, 1, pos(':', r));
           output(clgreen, r, n);
        end;

        // MODES
        if (pos('MODE', r) > 0) and (pos(nick, r) > 0) then begin
        if (pos('+', r) > 0) then
           mess:= copy(r, pos('+', r), length(r)) else
           mess:= copy(r, pos('-v', r), length(r));

        output(clnone, copy(r, 2, pos('!', r) -2) + ' sets mode ' + mess, n);
        //output(clgreen, r, n);
        if pos('+v',mess) > 0 then fmainc.lbchange(nick, '+', 3, n, num+1);
        if pos('-v',mess) > 0 then fmainc.lbchange(nick, '+', 4, n, num+1);
        end;

        end; // Empty
        until (r = '');
        output(clnone, #13, n);

        fmainc.timer1.Enabled:= true;
        CloseFile(t);

        //m0[n].Lines.LoadFromFile(log[n]);
    n:= 1;
    end; // JOIN

    2: Begin // nick
       // Sollo!~Sollo@181.31.118.135 NICK :collo

             if (pos('nickname already in use', r) > 0) then output(clblack, r, n) else

             if (mess = '') then mess:= copy(r, pos('NICK', r) + length('nick')+1, length(r));

             if (pos(nick, r) > 0) then
                cname:= 'You are now known as ' + mess
             else
                 cname:= copy(r, 1, pos('!', r)-1) + ' is now known as ' + mess;

             if (pos('You', cname) = 1) then net[n+1].nick:= mess;
       n:= 0;
       m:= 0;
       while (fmainc.TreeView1.Items[n].Index < num) do
             n:= fmainc.TreeView1.Items[n].GetNextSibling.AbsoluteIndex;

             if fmainc.TreeView1.Items[n].GetLastChild <> nil then
                m:= fmainc.TreeView1.Items[n].GetLastChild.AbsoluteIndex;

             while (n <= m) do begin
                   s:= 0;
                   //while (n <> chanod[s].node) do inc(s);
                   //s:= strtoint(copy(m0[s].Name, pos('_', m0[s].Name)+1, length(m0[s].Name)));

                   fmainc.createlog(num, copy(m0[n].chan,2,length(m0[n].chan)));

                   if (pos('You',cname) >0) then begin
                      m0[n].nnick:= mess;

                      output(clBlack, cname, n);
                   end;

                   if assigned(lb0[n]) then begin

                   if (fmainc.srchnick(copy(r, 1, pos('!', r)-1), 0, n)  = 'true') then begin
                   if mess <> '' then
                   //fmainc.lbchange(copy(r, 1, pos('!', r)-1), copy(r, pos('NICK', r)+6, length(r)), 2, n, num+1) else
                   //fmainc.lbchange(copy(r, 1, pos('!', r)-1), copy(r, pos('NICK', r)+5, length(r)), 2, n, num+1);

                   fmainc.lbchange(copy(r, 1, pos('!', r)-1), mess, 2, n, num+1) else
                   fmainc.lbchange(copy(r, 1, pos('!', r)-1), copy(r, pos('NICK', r) + Length('nick')+1, length(r)), 2, n, num+1);

                   if pos('You',cname) = 0 then
                      output(clBlack, cname, n);
                   CloseFile(t);
                   //m0[n].lines.LoadFromFile(log[n]);

                   end;

             end;
             inc(n);
             end; // lb0[n]
    n:= 1;
    end; // 2

    3: Begin // PRIVMSG
    //ShowMessage('r: ' + r + ' mess: ' + mess);
          if (pos('#', r) = 0) then
             cname:= copy(r, 1, pos('!', r)-1); // else


          //ShowMessage('3 priv: ' + cname);
          {
          cname:= copy(r, pos('#', r), length(r));
          delete(cname, pos(' ' , cname), length(r));
          }
          {
          // num is Connection number/name
          // Selecting the right memo number
          n:= 0;
          while (n < num) do begin
                n:= fmainc.TreeView1.Items[n].AbsoluteIndex;
                //ShowMessage(fmainc.TreeView1.Items[n].Text);
          end;
          }
          mess:= copy(r, 1, pos('!', r) -1) + ': '  + mess; // nick: message

          if (pos('#', cname) = 0) then begin
          s:= 0;
          if fmainc.TreeView1.Items.Count > 1 then
          while (lowercase(fmainc.TreeView1.Items.Item[s].Text) <> lowercase(cname)) and (s < fmainc.TreeView1.Items.Count-1) do inc(s);
                //ShowMessage(fmainc.TreeView1.Items.Item[s].Text);
                if (lowercase(fmainc.TreeView1.Items.Item[s].Text) <> lowercase(cname)) then begin
                fmainc.txp(num, cname, nick, false, true, false);
                //cname:= inttostr(num) + cname;
                {
                while (cname <> m0[n].chan) do begin
                      //ShowMessage('cname: ' + cname + ' chan: ' + m0[n].chan);
                inc(n);
                end;
                }
                end;
          end;

      //ShowMessage('cname: ' + cname + ' chan: ' + m0[n].chan);

      if (pos('#',cname) = 0) then
         cname:= inttostr(num) + cname;

      // Getting the right memo
      n:= fmainc.cnode(2,0,0, cname);

      delete(cname, 1, 1);
      fmainc.createlog(num, cname);

      //if (pos('Bastian', r) > 0) or (pos('action', lowercase(r)) > 0) then WriteLn(t, r + #13 + mess + #13);

      //rc:= n;
      //if fmainc.srchtree(copy(cname, pos('#',cname), length(cname))) = false then

      //repeat

      //ShowMessage(inttostr(length(chan)));
      //ShowMessage('cname ' + cname + ' chan ' + chan[n]);
      //ShowMessage(copy(r, 1, pos('!', r) -1));
      //if (cname = chan[n]) and (copy(r, 1, pos('!', r) -1) <> nick) then begin

      // /me
      if (pos('action', lowercase(mess)) > 0) then begin
         // McClane: ACTION dances
         delete(mess, pos(':', mess), 1);
         mess:= StringReplace(mess, char(1), '', [rfReplaceAll]);
         mess:= StringReplace(mess, 'ACTION ', '', [rfReplaceAll]);
         //delete(mess, pos(':', mess),1);
         mess:= '* ' + mess;
      end;

      if (pos('*', mess) = 1) then output(clPurple, mess, n) else
      if (pos(nick, mess) = 0) then // and (copy(r, 1, pos(':', r) -1) <> '') then
         output(clNone, mess, n) else output(clred, mess, n);

      //if pos('reinadrama', lowercase(mess)) > 0 then writeln(t, mess);
      CloseFile(t);

      //if (pos(nick,r) > 0) then rc:= n; // Cuidado!!!
      //if (pos(nick,copy(r,1,pos('!',r)-1)) = 0) then rc:= n;
      //until (n = fmainc.TreeView1.Items.Count);
      //end;

    end; // 3

    4: Begin // JOIN PART QUIT
       n:= 0;

       if (pos('QUIT',r) = 0) then
       if cname <> '' then n:= fmainc.cnode(2,0,0, cname);

       if (pos('QUIT', r) = 0) then begin
          fmainc.createlog(num, copy(cname, 2, length(cname)));
          cname:= copy(r, pos('!', r)+1, pos(' ', r)-1);
          delete(cname, pos(' ', cname), length(cname));
       end;

       if pos('JOIN', r) > 0 then begin
          //ShowMessage(inttostr(n) + ' r: ' + r + ' mess: ' + mess + ' cname: ' + cname);
          output(clgreen, copy(r, 1, pos('!', r)-1) + ' (' + cname + ')' + ' has joined ' +
          copy(m0[n].chan, 2, length(m0[n].chan)), n);
       end;

       if (pos('PART', r) > 0) then begin
          if assigned(m0[n]) then
          if mess <> '' then
             output(clmaroon, copy(r, 1, pos('!', r) -1) + ' (' + cname + ') parts. ' + '(' + mess + ')', n) else
             output(clmaroon, copy(r, 1, pos('!', r) -1) + ' (' + cname + ') parts', n);
       end;

       if pos('QUIT', r) = 0 then
          if (pos('JOIN', r) > 0) then fmainc.lbchange(copy(r, 1, pos('!', r)-1), '', 0, n, num+1) else fmainc.lbchange(copy(r, 1, pos('!', r)-1), '', 1, n, num+1);

       {
       if (pos('QUIT', r) > 0) and (mess = '') then begin
          //delete(mess, 1, pos(':', mess));
          delete(mess, 1, pos(':', mess));
       end;
       }
       if (pos('QUIT', r) = 0) then closefile(t);

       //n:= 0;
       if (pos('QUIT', r) > 0) then

          while (n < length(chanod)) do begin

                if (assigned(lb0[n])) then
                if fmainc.srchnick(copy(r, 1, pos('!', r)-1), 0, n) = 'true' then begin

                fmainc.createlog(num, copy(m0[n].chan, 2, length(m0[n].chan)));

                //ShowMessage('quit nor ' + mess);
                if length(mess) > 0 then
                   output(clmaroon, copy(r, 1, pos('!', r) -1) + ' has quit: (' + mess + ')', n) else
                                  output(clmaroon, copy(r, 1, pos('!', r) -1) + ' has quit', n);

                //gnicks(chan[n]);
                //lb0[n].Clear;
                fmainc.lbchange(copy(r, 1, pos('!', r)-1), '', 1, n, num+1);
                closefile(t);
                //m0[n].lines.LoadFromFile(log[n]);
                end;

          inc(n);
          end;
    n:= 1;
    end; // 4

    5: Begin // NOTICE

       // Using cname as sender
       cname:= copy(r, 1, pos('!',r)-1); // Author
       if (pos('::', mess) > 0) then
          while (pos(':', mess) > 0) do delete(mess, 1, pos(':', mess));

       // num is Connection number/name. Searching Parent for connexion in the tree
       n:= 0;
       while (fmainc.TreeView1.Items[n].Index < num) do
             n:= fmainc.TreeView1.items[n].GetNextSibling.AbsoluteIndex;
             if fmainc.TreeView1.Items[n].HasChildren then
                s:= fmainc.TreeView1.Items[n].GetLastChild.AbsoluteIndex else s:= n;

       m:= n;  // Saving node

       // Searching for private message to send notice
       while (fmainc.TreeView1.Items[n].Text <> cname) and (n < s) do begin
             if (fmainc.TreeView1.Items[n].Text = cname) then m:= n;
       inc(n);
       end;

       // Looking for the right memo
       //while (m <> m0[n].node) do inc(n);
       // Getting the right memo
       n:= fmainc.cnode(5, m, 0, '');

       fmainc.createlog(num, fmainc.TreeView1.Items[m].Text);

       //writeln(t, mess);
       output(clgreen, '< ' + cname + ' > ' + mess, n);
       closefile(t);
       //m0[TreeView1.Selected.AbsoluteIndex].lines.Add(log[TreeView1.Selected.AbsoluteIndex]);
    end;

    {
    6: Begin // WHOIS
       while pos('/WHOIS', r) = 0 do begin
       ShowMessage('w');
       r:= conn.RecvString(100);
       for n:= 1 to 3 do
       delete(r, 1, pos(' ', r));
       mess:= copy(r, pos(' ', r) +1, length(r));
       output('[' + copy(r, 1, pos(' ', r)-1) + '] ' + mess, m0[1]);
       end;
    end;
    }

    6: Begin // TOPIC
       n:= fmainc.cnode(2,0,0, cname);
       cname:= copy(cname, pos('#', cname), length(cname));
       r:= copy(r, 1, pos('!', tmp)-1); // User

       //ShowMessage('6: ' + tmp + ' /' + r + ' m: ' + mess + ' n ' + inttostr(n));

       //if (pos('TOPIC', tmp) = 0) then tmp:= r;
       //while (pos(':', r) > 0) do delete(r, 1, pos(':', r));

       //m0[0].Append(r+mess);

       if (pos('331', tmp) > 0) then
          r:= 'Topic for ' + cname + ' is not set' else

       if (pos('332', tmp) > 0) then
          r:= 'Topic for ' + cname + ' is ' + mess;

       if (pos('333', tmp) > 0) then
          r:= gtopic(tmp);
          //r:= 'Topic for ' + cname + ' is ' + mess;

       if (pos('TOPIC', tmp) > 0) then
       r:= r + ' has changed the topic to: ' + mess;

       fmainc.createlog(num, copy(m0[n].chan, 2, length(m0[n].chan)));

       if (pos('332', tmp) > 0) or (pos('333', tmp) > 0) then
          output(clPurple, r, n) else
          output(clnone, r, n);
       closefile(t);
    end;     // TOPIC

    7: Begin // INVITE
       if (pos('#', mess) > 0) then // Spotchat puts the channel after : (colon)
          cname:= copy(mess, pos('#', mess), length(mess));

       // :server sollo mcclane chan

       if (pos('!', r) > 0) then
       mess:= 'You have been invited to ' + cname + ' by ' + copy(r, 1, pos('!', r)-1) + ' (' + server + ')' else begin

              delete(r, 1, pos(' ', r)); delete(r, 1, pos(' ', r)); delete(r, 1, pos(' ', r));

          mess:= 'You have invited ' + copy(r, 1, pos(' ', r)-1) + ' to ' + copy(cname, 2, length(cname)) +
                 ' (' + server + ')';
       end;

       fmainc.createlog(num, copy(m0[n].chan, 2, length(m0[n].chan)));
       output(clGreen, mess ,n);
       closefile(t);
    end;


    8: Begin // MODE
       fmainc.Timer1.Interval:= 50;

       // Getting user
       if r[length(r)] = ' ' then delete(r, length(r), 1);
       tmp:= r;
       while (pos(' ', tmp) > 0) and (pos(' ', tmp) < length(tmp)) do delete(tmp, 1, pos(' ', tmp)); // User

       //if fmainc.TreeView1.Items[n].HasChildren then
       if cname <> '' then n:= fmainc.cnode(2, 0,0, cname);
       fmainc.createlog(num, copy(cname, 2, length(cname)));

       // Kick
       if (pos('KICK',r) > 0) then begin

          tmp:= r;
          delete(tmp, 1, pos('#', tmp));
          delete(tmp, 1, pos(' ', tmp)); // User
          if tmp[length(tmp)] = ' ' then
             delete(tmp, pos(' ', tmp), Length(tmp));


          r:= copy(r, 1, pos('!' ,r)-1); // Kicker

          cname:= tmp + ' has been kicked from ' + copy(cname, 2, length(cname)) + ' by ' + r;
          delete(mess, 1, pos(':', mess));

          cname:= cname + ' (' + mess + ')';
          if (pos(nick, r) = 1) then cname:= StringReplace(cname, r, 'You', [rfReplaceAll]);

          r:= copy(r, 1, pos('!' ,r)-1); // Kicker

          output(clred, cname, n);

          // Updating nick list
          fmainc.lbchange(tmp, tmp, 1, n, num+1);
       end else

       // Channel limit
       if (pos('+l', r) > 0) then begin
          tmp:= r;
          delete(tmp, 1, pos('+l', tmp)+2);
          if tmp[length(tmp)] = ' ' then
             delete(tmp, pos(' ', tmp), Length(tmp));

          r:= copy(r, 1, pos('!' ,r)-1); // Kicker

          mess:= r + ' sets channel limit to ' + tmp;
          output(clMaroon, mess, n);


       end else            // Op / Voice

       if (pos('+o',r) > 0) or (pos('-o', r) > 0) or
          (pos('+v',r) > 0) or (pos('-v', r) > 0) then begin

          if (pos('+', r) > 0) then
             mess:= ' gives ' else mess:= ' removes ';

          if (pos('+o', r) > 0) or (pos('-o', r) > 0) then
             if mess = ' removes ' then
                mess:= mess + 'channel operator status from ' else
                   mess:= mess + 'channel operator status to ';

          if (pos('+v', r) > 0) or (pos('-v', r) > 0) then
             if mess = ' removes ' then
                mess:= mess + 'voice from ' else mess:= mess + 'voice to ';

          r:= copy(r, 1, pos('!' ,r)-1); // Kicker
          mess:= r + mess + tmp;

          output(clgreen, mess, n);

       end else            // Ban

       if (pos('+b',r) > 0) or (pos('-b',r) > 0) then begin

          if (pos('+', r) > 0) then
             mess:= ' sets ' else mess:= ' removes ';
             if mess = ' sets ' then
             mess:= mess + 'ban on ' else mess:= mess + 'ban from ';

             r:= copy(r, 1, pos('!' ,r)-1); // Kicker
             mess:= r + mess + tmp;

             output(clMaroon, mess, n);

       end else               // Any channel mode

       if (pos('+',r) > 0) or (pos('-',r) > 0) then begin

             mess:= ' sets mode ' + tmp;

             r:= copy(r, 1, pos('!' ,r)-1); // Kicker
             mess:= r + mess;

             output(clMaroon, mess, n);
       end;


       // Updating nick list
       //if pos('@',r) = 0 then
       if (pos('gives',mess) > 0) and (pos('voice',mess) > 0) then fmainc.lbchange(tmp, '+', 3, n, num+1);
       //if (pos('gives',mess) > 0) and (pos('voice',mess) > 0) then gnicks(copy(cname, 2, length(cname)));
       if (pos('removes',mess) > 0) and (pos('voice',mess) > 0) then fmainc.lbchange(tmp, '+', 4, n, num+1);

       if (pos('gives',mess) > 0) and (pos('operator',mess) > 0) then fmainc.lbchange(tmp, '@', 3, n, num+1);
       if (pos('removes',mess) > 0) and (pos('operator',mess) > 0) then fmainc.lbchange(tmp, '@', 4, n, num+1);

       CloseFile(t);
       end;

 end; // Case

 //TreeView1.Refresh;
 //end; // R <> ''
end;

function connex.gtopic(r: string): string;
var //r: string;
    d: TDateTime;
    s: string;
begin
     //while r = '' do r:= conn.RecvString(200);
     if (pos('!', r) > 0) then begin
        delete (r, 1, pos('#', r) -1);
        delete (r, 1, pos(' ', r));
     s:= copy(r, 1, pos('!', r)-1);
     end;

     while (pos(' ', r) > 0) do
           delete(r, 1, pos(' ', r));

           d:= UnixToDateTime(StrToInt(r));

     r:= 'Topic set by ' + s + ' at ' +
         FormatDateTime('DDDD DD, MMMM YYYY, hh:mm:ss', d) ;

     result:= r;
end;

procedure connex.output(c: TColor; r: string; o: smallint);
var l:    smallint;
    test: TextFile;
    u:    string;
    u1:   boolean = false;
    a:    string;
begin
     {
     r:= 'Potro-Arg: c2c34[c15c2Silvi-arc15c2c34]c15 c301c312muá c2c30@ c2c34muá c2c38© c2c39muá c2c313® c2c36muá c2c30§c2c312muá c2c30@ c2c34muá c2c38© c2c39muá c2c313® c2c36muá c2c30§c2c312muá c2c30@ c2c34muá c2c38© c2c39muá amor';
     r:= 'Orbita: ' + char(2) + char(3) +'1,0You' + char(3) +'0,4Tube' + char(15) + char(2) + char(3) +'1 Video publicado por :   MoryChristmas  ' +
         char(3) + '12 "Ella quiere su rumba PITBULL" ' + char(3) + '1 --  ' + char(3) +'4  4m';

     r:= 'La_Persa: ' + char(2) + 'A' + char(2) + char(3) + '4Potro-Arg buenos dias nene' + char(15);
     r:= 'Demians: ' + char(2) + char(3) + '4[' + char(15) + char(2) + 'Maca' + char(15) + char(2) + char(3) + '4]' + char(15) + ' jojojo';


     r:= 'Potro-Arg: ' + char(2) + char(3) + '4[' + char(15) + char(2) + 'Silvi-ar' + char(15) + char(2) +
         char(3) + '4] ' +  char(15) + char(3) + '01' + char(2) + char(3) + '12muá ' + char(2) + char(3) + '0@ ' +
         char(3) + '4muá ' + char(2) + char(3) + '8© ' + char(2) + char(3) + '9muá' + char(15);

     r:= 'Potro-Arg: c2c34[c15c2Silvi-arc15c2c34]c15 c301c312muá c2c30@ c2c34muá c2c38© c2c39muá c2c313® c2c36muá c2c30§c2c312muá c2c30@ c2c34muá c2c38© c2c39muá c2c313® c2c36muá c2c30§c2c312muá c2c30@ c2c34muá c2c38© c2c39muá amor';
     r:= 'Orbita: ' + char(2) + char(3) +'1,0You' + char(3) +'0,4Tube' + char(15) + char(2) + char(3) +'1 Video publicado por :   MoryChristmas  ' +
         char(3) + '12 "Ella quiere su rumba Ella quiere su rumba Ella quiere su rumba PITBULL" ' + char(3) + '1 --  ' + char(3) +'4  4m';

     r:= StringReplace(r, 'c2', char(2), [rfReplaceAll]);
     r:= StringReplace(r, 'c3', char(3), [rfReplaceAll]);
     r:= StringReplace(r, 'c15', char(15), [rfReplaceAll]);

     //if (num = 2) and (o = 0) then ShowMessage('puta');


     if m0[o].lc = 5 then
     r:= 'Demians: ' + char(2) + char(3) + '4[' + char(15) + char(2) + 'Maca' + char(15) + char(2) + char(3) + '4]' + char(15) + ' jojojo' + char(3) + '4';
     if m0[o].lc = 5 then
     r:= 'Mpilar ' + char(3) + '5 Reparte un poco de ' + char(2) + 'Café' + char(2) + ' caliente ' + char(3) + '0,5***' + char(3) + '5,0D' + char(3)+ '0,12***' + char(3) + '2,0D ' + char(3)+'0,4***' + char(3) + '4,0D ' + char(3) + '0,3***' + char(3) + '3,0D ' + char(3) + '0,1***' + char(3) + '1,0D ' + char(3) + '5para que nadie se duerma en #azahar para que nadie se duerma en #azahar para que nadie se duerma en #azahar para que nadie se duerma en #azahar para que nadie se duerma en #azahar para que nadie se duerma en #azahar';
     r:= 'bkcol' + char(3) + '4< NickServ > Welcome to SpotChat, MadMaxx! Here on SpotChat, we provide services to enable the registration of nicknames and channels! For details, ' +
         'type /msg NickServ help and /msg ChanServ help.';
     r:= 'mcclane https://duckduckgo.com% and http://duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%) hola';
     r:= 'Bastian: ' + char(15) + 'porque la pongo desde el auto a la radio' + char(15);
     r:= 'CamilaAndreina: ' + char(3) + '01' + char(2) + char(3) + '1Esta transmitiendo <' + char(3) + char(3) + '13CamilaAndreina' + char(3) + ' ' + char(3) + '1en' + char(3) + ' ' + char(3) + '3Radio Lc-Argentina' + char(3)+char(3) + '1>. Escuchala en:' +char(3) + char(15) + char(3) + '12http://radiolcargentina.radiostream123.com ' + char(2) + char(15);
     r:= 'CamilaAndreina: ' + char(3) + '01' + char(2) + char(3) + '1Esta transmitiendo <' + char(3) + char(3) + '13CamilaAndreina' + char(3) + ' ' + char(3) + '1en' + char(3) + ' ' + char(3) + '3Radio Lc-Argentina' + char(3)+char(3) + '1>. Escuchala en:' +char(3) + char(15) + char(3) + '12http://radiolcargentina.radiostream123.com ' + char(2) + char(15);
     r:= char(3) + '3Bastian: ' + char(15) + 'Hola' + char(15);
     r:= 'Digital-Radio: ' + char(2) + char(3) + '7\B7!' + char(3) + '2\A6' + char(3) + '7[' + char(3) + '2\BB\87\AB' + char(3) + '7( ' + char(3) + '7T' + char(3) + '2ransmitiendo' + char(3) + '12: ' + char(3) + '7[' + char(3) + '12 ' + char(3) + '7M' + char(3) + '2usica ' + char(3) + '7C' + char(3) + '2ontinua ' + char(3) + '7]' + char(3) + '2*' + char(3) + '7 S' + char(3) + '2intonizanos ' + char(3) + '7D' + char(3) + '2esde: ' + char(3) + '2[ ' + char(3) + '12 http://Digital-Radio.Mx/ ' + char(3) + '2 ] ' + char(3) + '7)' + char(3) + '2\BB\87\AB' + char(3) + '7' + char(3) + '7]' + char(3) + '2\A6' + char(3) + '7!\B7 ' + char(3) + '2* ' + char(3) + '7S' + char(3) + '2olicitudes ' + char(3) + '2*' + char(3) + '7 Cerradas';
     r:= char(3) + '7M' + char(3) + '2usica ' + char(3) + '7C' + char(3) + '2ontinua ';
     r:= 'Topic is: Official Linux Mint Chat Channel | Channel Rules: https://goo.gl/mP1Rz1 - for support use #linuxmint-help | All languages are welcome. No politics. No religion. Safe For Work conversations only. Safe For Work conversations only. Safe For Work conversations only.';
     r:= 'Topic is: ' + char(2) + char(3) + '1,11 Bienvenidos al canal ' + char(3) +'0,13 #LC-Argentina' + char(15) + char(2) + char(3) + '1 Ahora podes chatear desde ' + char(15) + char(2) + char(3) + '1,3Kiwi ' + char(15) + char(3) + char(2) + char(2) + char(3) + '1en ' + char(2) + char(3) + '12http://canalargentina.net/kiwi' + char(15) + char(3) + char(2) + char(2) + char(3) + char(2) + char(3) + '1y desde ' + char(15) + char(2) + char(3) + '4,14Mibbit' + char(15) + char(3) + char(2) + char(2) + char(3) + char(2) + char(3) + '1 desde ' + char(15) + char(2) + char(3) + '12http://canalargentina.net/mibbit' + char(15);
     r:= 'Topic is: ' + char(3) + '1Bienvenidos a ' + char(3) + '0,13 #LC-Argentina ' + char(3) + '1Chatea desde ' + char(15) +
         char(3) + '2http://canalargentina.net/kiwi' + char(3) + '1 o ' + char(15) +
         char(3) + '2http://canalargentina.net/mibbit ' + char(3) + '1 o con musica en ' +
         char(3) + '2Digital ' + char(3) + '7Radio ' + char(3) + '2https://digital-radio.mx/chat.html';
     r:= 'Orbita ' + char(2) + char(3) +'1,0You' + char(3) +'0,4Tube' + char(15) + char(2) + char(3) +'1 Video publicado por :   MoryChristmas  ' +
         char(3) + '12 "Ella quiere su rumba Ella quiere su rumba Ella quiere su rumba PITBULL" ' + char(3) + '1 --  ' + char(3) +'4  4m';
         r:= 'Topic is: ' + char(2) + char(3) + '1,11 Bienvenidos al canal ' + char(3) +'0,13 #LC-Argentina' + char(15) + char(2) + char(3) + '1 Ahora podes chatear desde ' + char(15) + char(2) + char(3) + '1,3Kiwi ' + char(15) + char(3) + char(2) + char(2) + char(3) + '1en ' + char(2) + char(3) + '12http://canalargentina.net/kiwi' + char(15) + char(3) + char(2) + char(2) + char(3) + char(2) + char(3) + '1y desde ' + char(15) + char(2) + char(3) + '4,14Mibbit' + char(15) + char(3) + char(2) + char(2) + char(3) + char(2) + char(3) + '1 desde ' + char(15) + char(2) + char(3) + '12http://canalargentina.net/mibbit' + char(15);
         r:= 'Brioso: ' + char(2) + char(3) + '01,00You' + char(3) + '00,04Tube' + char(3) + '04,99' + char(15) + char(3) + '14 Sopa_Man-->' + char(3) + '01' + char(2) + 'POR TENER TU AMOR ' + char(3) + '04[' + char(3) +  '016:36' + char(3) + '04] ' + char(15) + '-- 4.994.912 vistas';
         r:= 'Bienvenidos al canal Argentina!! DisfrutÃ¡ mejor de tu estancia en la sala con el nuevo webchat del canal, probalo acÃ¡: https://argentinachatea.com/';
         r:= 'Topic is: Bienvenidos al canal ' + char(3) + '1,11ARG' + char(3) + '1,00ENT' + char(3) +  '1,11INA' + char(15) + '-- Visitanos en www.argentinachatea.com  -- ' + char(3) + '11(Consultas y reclamos únicamente por privado)';
         r:= 'Topic is: ' + char(2) + char(3) + '4Merry xMas friends! :D - If you have anyone that cant join #Chat because of our modes.. please tell him to register his/her nickname and its gonna be fine :D :P For help come to #help';

     // ICQ
        r:= char(3) + '7' + char(3) + '5' + char(2) + char(15) + 'L' + char(15) + char(2) + char(3) + '7aughs ' + char(3) + '5' + char(2) + char(15) + 'O' + char(15) + char(2) + char(3) + '7ut ' + char(3) + '5' + char(2) + char(15) + 'L' + char(15) + char(2) + char(3) + '7oud' + char(3);
        r:= char(3) + '7' + char(3) + '5' + char(2) + char(15) + 'O' + char(15) + char(2) + char(3) + '7h ' + char(3) + '5' + char(2) + char(15) + 'M' + char(15) + char(2) + char(3) + '7y ' + char(3) + '5' + char(2) + char(15) + 'G' + char(15) + char(2) + char(3) + '7awd' + char(3) + ' glad i dont have it';
        r:= 'Devilish: ' + char(3) + '6' + char(3) + '14' + char(2) + 'W' + char(2) + char(3) + '6elcome ' + char(3) + '14' + char(2) + 'B' + char(3) + '6ack ' + char(3) + 'StrangerKev';
        r:= 'Jupiter8: ' + char(3) + '12hey Sherbet - :)' + char(3);
     }
     if (pos('orbita', r) > 0) then begin
     //r:= char(2) + char(3)+'3mcclane https://duckduckgo.com/ and http://duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/';
     //r:= 'mcclane https://duckduckgo.com/ and http://duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/) hola';
     //r:= 'Topic is: Official Linux Mint Chat Channel | Channel Rules: https://goo.gl/mP1Rz1 - for http://support use #linuxmint-help | All languages are welcome. No politics. No religion. Safe For Work conversations only. Safe For Work conversations only. Safe For Work conversations only.';
     //r:= char(3) + '4' + char(2) + '2018 minus 3 days away If you have anyone that cant join #Chat because of our modes.. please tell him to register his/her nickname and its gonna be fine :D :P For help come to #helpcome to #helpcome to #helpcome to #helpcome to #helpcome to #helpcome to #helpcome to #help';
     //r:= char(3) + '4,15L' + char(3) + '3augh';
     //r:= char(3) + '7' + char(3) + '5' + char(2) + char(15) + 'L' + char(15) + char(2) + char(3) + '7aughs ' + char(3) + '5' + char(2) + char(15) + 'O' + char(15) + char(2) + char(3) + '7ut ' + char(3) + '5' + char(2) + char(15) + 'L' + char(15) + char(2) + char(3) + '7oud' + char(3);
     //r:= char(3) + '7 ' + char(3) + '5' + char(2) + char(15) + 'O' + char(15) + char(2) + char(3) + '7h ' + char(3) + '5' + char(2) + char(15) + 'M' + char(15) + char(2) + char(3) + '7y ' + char(3) + '5' + char(2) + char(15) + 'G' + char(15) + char(2) + char(3) + '7awd' + char(3) + ' glad i dont have it';
     //r:= 'Devilish: ' + char(3) + '6' + char(3) + '14' + char(2) + 'W' + char(3) + '6elcome ' + char(3) + '14'  + 'B' + char(3) + '6ack ' + char(3) + '6StrangerKev' + char(3);
     //r:= 'Jupiter8: ' + char(3) + '12,14 ' + char(3) + '4,0hey Sherbet ' + char(3) + '12,14:)' + char(3);
     //r:= 'magic dragon: ' + char(3) + '7' + char(3) + '5' + char(2) + 'R' + char(2) + char(3) + '7olling ' + char(3) + '5' + char(2) + 'O' + char(2) + char(3) + '7n ' + char(3) + '5' + char(2) +  'T' + char(2) + char(3) + '7he ' + char(3) + '5' + char(2) + 'F' + char(2) + char(3) + '7loor' + char(3) + '5' + char(2) + 'L' + char(2) + char(3) + '7aughing ' + char(3) + '5' + char(2) + 'M' + char(2) + char(3) + '7y ' + char(3) + '5' + char(2) + 'A' + char(2) + char(3) + '7scii ' + char(3) + '5 ' + char(2) + 'O' + char(2) + char(3) + '7ff' + char(3) + '155';
     //r:= 'Rita: ' + char(2) + char(3) + '6,0L' + char(2) + char(3) + '12augh ' + char(2) + char(3) + '6,0O' + char(2) + char(3) + '12ut ' + char(2) + char(3) + '6,0L' + char(2) + char(3) + '12oud' + char(3);
     //r:= 'Olives: Hi, ' + char(3)+ '6-' + char(3) + '6,6 ' + char(3)+ '0,0 ' + char(3) + '6,0Sherbet' + char(3) + '0,0 ' + char(3) + '6,6 ' + char(15) + char(3) + '6- ' + char(15) + char(3) + '1';
     r:= 'Rita: irts still there where i put it LadyPaper in the box ' + char(2) + char(3) + '6,0L' + char(2) +  char(3) + '12aughing ' + char(2) + char(3) + '6,0M' + char(2) + char(3) + '12y ' + char(2) + char(3) + '6,0' + char(2) + char(2) + char(3) + '12' + char(3) + '6,0A' + char(2) + char(3) + '12scii ' + char(2) + char(3) + '6,0O' + char(2) + char(3) + '12ff' + char(3) + '155';
     r:= '< Global > ' + char(2) + '[Logon News' + char(2) + ' - Apr 30 20:43:22 2017 BST] We support SSL/TLS connections on ports 6697,9999. Due to complications with getting a 2600.net certificate years ago, we use *.scuttled.net certificate from Comodo until October 2017. Please read https://scuttled.net/content/ssl.php for more information. Thanks for using ~2600net';
     //r:= '< Global > [' + char(2) + 'Logon News' + char(2) + ' - Apr 30 20:20:56 2017 BST] We''ve upgraded to ircd-hybrid.org release v8.2.22 - security updates, and feature updates. Thank you ircd-hybrid team, and Michael for the great support and hosting. ~2600net';
     c:= clpurple;
     end;


     // Sending to test file
     //if (pos('magic', lowercase(r)) > 0) or (pos('Goofus', lowercase(r)) > 0) then begin
        assignfile(test, '/home/nor/Lazarus/n-chat3/enchat synedit.nix/logs/test.txt');
        Append(test);
        writeln(test, r);
        CloseFile(test);
     //end;

     //if assigned(m0[1]) and (pos(char(1), str) > 0) then ShowMessage(r);
     u:= 'Ã¡Ã©Ã­Ã³ÃºÃÃÃÃÃÃ±ÃÃÃ¨Ã¬Ã²Ã¹ÃÃÃÃÃ¤Ã«Ã¯Ã¶Ã¼ÃÃÃÃÃ';
     a:= 'áéíóúÁÉÍÓÚñÑäëïöüÄËÏÖÜàèìòùÀÈÌÒÙ¡';

     // counting lines. When reaches 100, writes all of them
     inc(m0[o].lc);

     while m0[o].Lines.count >= 100 do begin
        //m0[o].Lines.Add('100 !!!');
        m0[o].Lines.Delete(0);
        m0[o].BStrings.Delete(0);
        if m0[o].last > 0 then m0[o].last:= m0[o].last - 1;
     end;

     for l:= 1 to length(a) do if (pos(a[l],r) > 0) then u1:= true;
     if u1 = false then
         //r:= ConvertEncoding(r, 'UTF8', 'ISO8859-1', false);
         r:= ISO_8859_1ToUTF8(r);
     m0[o].Lines.Add(r);

     if c = clnone then m0[o].BStrings.Add(r) else
        m0[o].BStrings.Add('bkcol' + char(3) + inttostr(icolors(c)) + r);


     if m0[o].lines.Count = 100 then begin
        l:= m0[o].TopLine;
        m0[o].unwr;
        m0[o].wr(false);
        m0[o].fcolors(false, clnone, '');
        m0[o].TopLine:= l;
        //m0[o].Append(inttostr(l));
        //ShowMessage('no a');
        m0[o].lc:= 0;
     end else begin
         m0[o].wr(true);
         m0[o].fcolors(true, c, '');
     end;

     // Autoscroll
     with m0[o] do begin
     //if (o > 0) then ShowMessage(inttostr(font.Height));
     l:= lines.count-1 - (m0[o].Height div (LineHeight)) ;
     //if o = 1 then m0[0].Append('Top ' + inttostr(TopLine) + ' L: ' + inttostr(l));
     if (m0[o].TopLine >= l) then TopLine:= lines.Count;

     // Making last line <> 0 to paint the marker line if the page is not visible
     //if (fmainc.Notebook1.Page[fmainc.cnode(8,0,o, '')].visible) then shw:= true;
     if not (fmainc.Notebook1.Page[fmainc.cnode(8,0,o, '')].visible) then begin
        if shw = true then
           //ShowMessage('tre');
           m0[o].last:= m0[o].Lines.Count -1;
        shw:= false;
     end; // else m0[o].last:= 0;
     //if assigned(m0[1]) then (m0[1].Lines.Add(inttostr(m0[1].TopLine)));

     // If it is modified and notebook page is not visible then color the tree item
     m0[o].Modified:= true;
     fmainc.TreeView1.Refresh;

     r:= ConvertEncoding(r, 'UTF8', 'iso8859-1', false);
     m0[o].procstring(r); // To file

     {for l:= 0 to 100 do
     if (pos(char(l),r) > 0) and (pos('=',r) > 0) then ShowMessage(inttostr(l));}

     {
     if pos('hola',r) > 0 then begin
     if lines.Count < 99 then begin
        m0[1].Clear;
        for l:= 1 to 99 do begin
            lines.Add(inttostr(l));
            BStrings.Add(inttostr(l));
        end;
     CaretY:= lines.Count;
     m0[0].Append(inttostr(m0[1].TopLine));
     end;
     end;
     }
     end; // m0[o]
end;

procedure TSyn.wr(app: boolean);
var
   lin:               TStrings;     // Lines to add
   l:                 smallint = 0; // Line number
   l1:                smallint = 0;
   tmp:               string;
   k,k1:              string;       // Color code
   tmp2:              string;
   tmp3:              string;
   c:                 smallint = 1; // Character position
   len:               smallint = 0;
   w:                 integer;
   b:                 boolean = false; // bold
   co:                Boolean = false;
   hy:                boolean = false; // hyperlink
   r1:                boolean = false;
   col:               boolean = false; // Colored line
   nd:                string = ' ,()[]';     // Hypertext end
begin

     if app then l:= Lines.Count-1;

     //w:=   m0[o].Width div (font.Height div 2) -5; // Ubuntu
     w:=   Width div (font.Height div 2) - 25; // Nimbus
     //if lines.Count > 1 then

     while (l < Lines.Count) do begin

           tmp:= lines[l];

     //Searching for the original string
     l1:= BStrings.Count-1;
     while (pos(copy(tmp,6, length(tmp)), BStrings[l1]) = 0) and (l1 > 0) do dec(l1);

           //if l = lines.Count-1 then lines[l]:= lines[l] + char(15);
           //BStrings[BStrings.Count-1]:= BStrings[BStrings.Count-1] + char(15);
           //if pos('topic', lowercase(tmp)) > 0 then ShowMessage('bkcol: ' + tmp);
           if (pos('bkcol', BStrings[l1]) > 0) then begin
              col:= true;

              tmp2:= copy(BStrings[l1], 6, 6);
              k:= copy(tmp2, 1, 1);
              //if assigned(m0[1]) then ShowMessage('col1 ' + k);
              if (pos(char(3), k) = 1) then

                  while ( (tmp2[length(k)+1] in ['0'..'9'])
                        or (copy(BStrings[l1], 6, length(k)+1)[length(k)+1] = ',') )
                        and (length(k)+1 < length(tmp2))
                        do k:= copy(BStrings[l1], 6, length(k)+1);

                        if k[length(k)] = ',' then delete(k, length(k), 1);
                        //if k[2] = ',' then k:= k[1] + '0' + copy(k, 2, length(k));
                  //ShowMessage(k);

                        if (pos(',',k) > 0) then begin
                           tmp3:= copy(k, pos(',',k)+1, length(k));
                           k:= copy(k, 1, pos(',',k)-1);
                        end;

                        if tmp3 <> '' then
                           while (strtoint(tmp3) > 15) do delete(tmp3, length(tmp3), 1);

                        if length(k) > 1 then begin
                           if strtoint(copy(k, 2, length(k))) > 15 then tmp3:= '';
                           while (strtoint(copy(k, 2, length(k))) > 15) do delete(k, length(k), 1);
                           if tmp3 <> '' then
                              k:= k + ',' + tmp3;
                        end;
                  //ShowMessage('col' + k);
              tmp:= k + tmp;
              //if k = '' then ShowMessage('col1 ' + k);
           end;

           // Getting hyperlink
              // hola http://hole.net hey no way http://no.way
           c:= 1;
           //if assigned(m0[1]) and (pos('http', tmp3) > 0) then ShowMessage(tmp3);
           if (pos('http://',tmp) > 0) or (pos('https://', tmp) > 0) then begin
              //hy:= true;
              //ShowMessage(tmp);
              tmp2:= '';
              while (c <= length(tmp)) do begin
                    tmp2:= tmp2 + tmp[c];
                    if (pos('http://',tmp2) > 0) or (pos('https://',tmp2) > 0) then begin
                    tmp2:= '';
                    while (pos(tmp[c],nd) = 0) and (c <= length(tmp)) do inc(c);
                    //ShowMessage(inttostr(c) + ' ' + inttostr(length(tmp)));
                    if (tmp[c-1] <> char(1)) then
                    tmp:= copy(tmp,1, c-1) + char(1) + copy(tmp, c, length(tmp));
                    end;
           inc(c);
           end;
               if (pos(char(1) + 'http', tmp) = 0) then begin
               tmp:= StringReplace(tmp, 'http://', char(1) + 'http://', [rfReplaceAll]);
               tmp:= StringReplace(tmp, 'https://', char(1) + 'https://', [rfReplaceAll]);
               //if tmp[length(tmp)] = char(1) then delete(tmp, length(tmp), 1);
               end;
           lines[l]:= tmp;
           end;

           c:= 1;
           // Counting published characters
           len:= 0;
           while (c < length(tmp)) do begin
                 if (tmp[c] = char(2)) or (tmp[c] = char(3)) or (tmp[c] = char(15)) or (tmp[c] = char(31)) then inc(len);
           inc(c);
           end;
           len:= length(tmp) - len;

           // Starting word wrapping
           if (length(tmp) > w) then begin

           // Word wrapping for lines and hypertext
                 c:= w;
                 while not (tmp[c] = ' ') and not (tmp[c] = '/') and not (tmp[c] = '%') and (c > 1) do dec(c);
                 tmp2:= tmp;

                 {
                 // Removing char(3)
                 tmp2:= tmp;
                 if (pos(char(3), tmp2) = 1) then begin
                    {tmp2:= StringReplace(tmp2, char(3) + char(3), char(3), [rfReplaceAll]);
                    tmp2:= StringReplace(tmp2, char(2) + char(2), char(2), [rfReplaceAll]);
                    tmp2:= StringReplace(tmp2, char(3) + char(2), char(3) + '1' + char(2), [rfReplaceAll]);}
                    k:= copy(tmp2, pos(char(3), tmp2), 6);
                    //if not (k[2] in ['0'..'9']) then k[2]:= '1';
                    while not (k[length(k)] in ['0'..'9']) do delete(k, length(k), 1);
                    delete(tmp2, 1, length(k));
                    //if assigned(m0[1]) then ShowMessage(k);
                 end;
                 }

                 {
                 if pos('bkcol', BStrings[l1]) = 1 then col:= true; // Colored
                 // Getting K
                 if (col = true) then begin
                    len:= 1;
                    while (tmp[len] <> char(3)) and (len < length(tmp)) do inc(len);

                    k:= copy(tmp, len, 6);
                    ShowMessage(tmp + sLineBreak + k);
                    while not (k[length(k)] in ['0'..'9']) do delete(k, length(k), 1);
                 end;
                 }

                 {
                 // Adding color at first
                 if col = true then
                 lines[l]:= k+copy(tmp, 1, c) else
                 lines[l]:= copy(tmp, 1, c);
                 //if col= true then ShowMessage('colx ' +k);
                 }

                 // Cut
                 lines[l]:= copy(tmp, 1, c);
                 //len:= len - length(lines[l]) - length(k);
                 len:= c;

                 if (l < lines.count-1) then begin //and (l+1 < lines.Count) then begin
                    lines.insert(l+1, copy(tmp, c+1, length(tmp)) );
                    //inc(l);
                 end else
                    lines.add(copy(tmp, c+1, length(tmp)) );
                                //ShowMessage(inttostr(len));
                 {
                 // Adding color;
                 if (pos(k, tmp) > 0) then col:= true;
                 if col = true then begin
                    //lines[l+1]:= k + lines[l+1];
                    lines[l+1]:= k + lines[l+1];
                    //lines[l+1]:= lines[l+1];
                    //if (pos(k, lines[l]) > 0) then ShowMessage('col '+k);
                    //lin.Add(copy(tmp, c+1, w));
                 end;
                 }

                 tmp2:= copy(tmp, 1, c);
                 delete(tmp, 1, c);

                 //inc(l);
                 {
                 tmp2:= copy(BStrings[l1], 1, w);
                 c:= l+1;
                 while not (pos(tmp2, BStrings[l1]) = 1) do begin
                       lines.Delete(c);
                 inc(c);
                 end;
                 }
                 //if assigned(m0[1]) then ShowMessage(tmp2);


              // Start formatting
              if (l > 0) then
                 tmp2:= lines[l];
                 //if assigned(m0[1]) then ShowMessage(tmp2);

           // Start dragging attributes
           if tmp2 <> '' then begin
                 // Searching in prior line. Bold and hyperlinks

                 hy:= false;
                 c:= 1;
                 while (c <= length(tmp2)) do begin
                       if (tmp2[c] = char(2)) then
                          if b = false then b:= true else b:= false;
                       if (tmp2[c] = char(15)) then b:= false;

                       //if hy = true then
                       //if (pos(char(1), BStrings[l1]) > 0) then hy:= true;
                       if (tmp2[c] = char(1)) then
                          if hy = false then hy:= true else hy:= false;
                          //if (tmp2[c] = char(1)) and (hy = false) then ShowMessage(tmp2 + ' l ' + inttostr(l));
                 inc(c);
                 end;

                 // Searching in prior line. Color
                 c:= Length(tmp2);
                 //ShowMessage('tmp2: ' + tmp2);
                 while (tmp2[c] <> char(3)) and (tmp2[c] <> char(15)) and (c > 1) do dec(c);

                          //if tmp2[c] = char(2) then if b = false then b:= true else b:= false;

                          if (tmp2[c] = char(3)) then begin
                             if co = false then co:= true else co:= false;
                             if col = true then co:= true;
                             //if col = true then ShowMessage(copy(tmp2, c, 6));

                             {
                             // Deleting color if new color is added
                             tmp3:= lines[l];
                             if (pos(k, tmp3) = 1) then begin
                                delete(tmp3, pos(k,tmp3), length(k));
                                lines[l]:= tmp3;
                                ShowMessage('k ' + k);
                             end;
                             }

                             //while (pos(k, tmp2) > 0) do delete(tmp2, pos(k,tmp2), length(k));
                             k1:= copy(tmp2, c, 1);

                             //if (pos(',', k1) = 0) then delete(k1, 4, 2);
                             //k:= StringReplace(k, char(3) + char(2), char(3) + '1' + char(2), [rfReplaceAll]);
                             if (pos(char(3), k1) = 1) then
                             //try

                             k1:= copy(tmp2, c, 1);
                             while ( (tmp2[c+length(k1 )] in ['0'..'9'] ) or (tmp2[c+length(k1)] = ',') )
                                   and (c+length(k1) < length(tmp2))
                                   do k1:= copy(tmp2, c, length(k1)+1);

                             if (pos(',',k1) > 0) then begin
                                tmp3:= copy(k1, pos(',',k1)+1, length(k1));
                                k1:= copy(k1, 1, pos(',',k1)-1);
                             end;

                             if tmp3 <> '' then
                                while (strtoint(tmp3) > 15) do delete(tmp3, length(tmp3), 1);

                             if length(k1) > 1 then begin
                                if strtoint(copy(k1, 2, length(k1))) > 15 then tmp3:= '';
                                   while (strtoint(copy(k1, 2, length(k1))) > 15) do delete(k1, length(k1), 1);
                                if tmp3 <> '' then
                                   k1:= k1 + ',' + tmp3;
                             end;
                             end;

                             //ShowMessage(k1);
                             //if k[length(k)] = ',' then delete(k, length(k), 1);
                             //except ShowMessage('puta ' + k1); end;


                          if (tmp2[c] = char(15)) then begin
                             co:= false;
                             b:= false;
                          end;

                 //end; // tmp length

                 //if ((l) < lines.Count-1) then begin
                    if (l+1) < lines.Count then begin

                       if b = true then lines[l+1]:= char(2) + lines[l+1];
                       if (hy = true) then lines[l+1]:= char(1) + lines[l+1];
                       if (co = true) then lines[l+1]:= k + k1 +lines[l+1];
                       //if (col = true) then ShowMessage('yay ' + lines[l+1]);
                    end;
                    end;

                    // Removing end of hypertext at the beginning of line
                    if (l+1) < lines.Count then
                    if (pos(char(1) + char(1), lines[l+1]) >0) then begin
                       tmp3:= lines[l+1];
                       //ShowMessage('hey' + tmp3);
                       delete(tmp3, 1,2);
                       lines[l+1]:= tmp3;
                    end;
           end; // Formatting text

           //end; // w length
           // End word wrapping


                    //if (pos(char(1)+char(1), tmp2) > 0) then ShowMessage('wr: ' + lines[l]);
                 //end;

     //if col = true then lines[l]:= lines[l] + char(15);

     // Resetting variables
     if r1 = true then r1:= false;
     co:= false; b:= false; k:= '';

     inc(l);
     end; // Lines count
end;

procedure TSyn.unwr;
var l: smallint = 0;
begin
     Clear;

     while (l < BStrings.Count) do begin
           Lines.add(BStrings[l]);
     inc(l);
     end;
end;

procedure TSyn.fcolors(app: boolean; co: TColor; r: string);
var
  Modi:         Boolean = false;
  Attr1, Attr2, Attr3: TtkTokenKind; // Attr1 = color, Attr2 = bold, Attr3 = Hypertext
  str:          string;
  l:            smallint = 0;
  ch:           smallint = 1;
  chs:          smallint = 0;
  b:            boolean = false; // Is bold
  c:            boolean = false; // Is colored
  b1:           boolean = false;
  c1:           boolean = false;
  hy:           boolean = false; // Is hyperlink
  k,tmp:        string;
  f:            TColor;
  bco:          TColor = clnone;
  fr, bk:       string;
begin
     if first = '' then first:= lines[0];

     if app then
     if lines.Count > 2 then l:= lines.Count -3 else l:= Lines.Count-1;
     //l:= lines.Count-1;

     //if assigned(m0[1]) then ShowMessage(lines[0]);
     if co = clnone then f:= clblack;

     if (co <> clnone) then
        if (pos('bkcol', BStrings[BStrings.Count-1]) = 1) then begin //ShowMessage(BStrings[BStrings.Count-1]);
           l:= Lines.Count-1;
           k:= copy(BStrings[BStrings.Count-1], 6, 3);
           if length(k) > 1 then
           while not (k[length(k)] in ['0'..'9']) do delete(k, length(k), 1) else k:= char(3) + '1';

        //ShowMessage('hey ' + lines[l]);
        {ShowMessage('hey ' + BStrings[BStrings.Count-1]);}
        //while (pos(copy(Lines[l], 1, 10), BStrings[BStrings.Count-1]) = 0) do dec(l);

        lines[l]:= k + lines[l];
        while (pos(copy(lines[l],1, length(lines[l])), BStrings[BStrings.Count-1]) <> 1) and (l > 0) do dec(l);
        if app then l:= lines.Count-1;
     end;

     // Multiline
     //if (assigned(m0[1])) and (BStrings.Count > 1) then ShowMessage(lines[l] + char(13) + BStrings[BStrings.Count-1]);
     if app = true then

     if (BStrings.Count > 1) then
     if (pos('bkcol', BStrings[BStrings.Count-1]) = 1) then
        while (pos(lines[l], copy(BStrings[BStrings.Count-1], 6, length(lines[l]))) <> 1) and (l > 0) do dec(l) else
        while (pos(lines[l], copy(BStrings[BStrings.Count-1], 1, length(lines[l]))) <> 1) and (l > 0) do dec(l);
     //if assigned(m0[1]) then ShowMessage(inttostr(l) + #13 + lines[l]);

     if app = false then hl.ClearAllTokens;

     //if (not app) then hl.ClearAllTokens;
  while (l < Lines.Count) do begin
        if (pos('bkcol',lines[l]) > 0) then lines[l]:= StringReplace(lines[l], 'bkcol','', [rfReplaceAll]);
        str:= Lines[l];
        //if (pos(char(3), str) = 1) then ShowMessage(str);
        //if (co = clnone) and (pos(char(3), str) = 0) then str:= char(3) + '1' + str;
        //if (pos('Out Loud', lines[l]) > 0) then ShowMessage(str);
        //str:= 'hola ' + char(3) + 'no way no way no way';

        //if (str[length(str)] = char(3)) then delete(str, length(str), 1);
        str:= StringReplace(str, char(1)+char(1), char(1), [rfReplaceAll]);
        //str:= StringReplace(str, char(2)+char(2), char(2), [rfReplaceAll]);
        str:= StringReplace(str, char(3)+char(3), char(3), [rfReplaceAll]);
        str:= StringReplace(str, char(15)+char(15), char(15), [rfReplaceAll]);
        str:= StringReplace(str, char(13), '', [rfReplaceAll]);
        //if (co <> clnone) then str:= StringReplace(str, '', '', [rfReplaceAll]);
        //if l < BStrings.Count then if (pos('bkcol', BStrings[l]) = 1) then ShowMessage(BStrings[l]);
        ch:= 1;
        chs:= 0;
        hy:= false;

  while (ch <= length(str)) do begin

        if (str[ch] = char(2)) then begin
           if b = true then b:= false else b:= true;
           if b = true then b1:= true;
        end;

        if (str[ch] = char(3)) then begin
           if c = false then c:= true;
           c1:= true;
        end;

        if (str[ch] = char(15)) or (ch = length(str)) //then begin
        then begin
           if b1 = true then b:= false;
           c:= false;
           //if b = true then b1:= true;
           //if (b1 = false) and (c1 = false) then str[ch]:=;
        end;

        if (str[ch] = char(1)) then begin
           if hy = false then hy:= true else hy:= false;
           //if (ch = length(str)) and (hy = true) then hy:= false;
        end;

  // Processing colors

        //if (str[ch] = char(3)) then
        //   if not (str[ch+1] in ['0'..'9']) then delete(str,ch,1);

        if (str[ch] = char(3)) then begin

           //str:= StringReplace(str, char(3) + ' ', ' ', [rfReplaceAll]);
           k:= copy(str, ch, 1);
           while ( (str[ch+length(k )] in ['0'..'9'] ) or (str[ch+length(k)] = ',') ) and ((ch + length(k)) <= length(str))
                 do k:= copy(str, ch, length(k)+1);
                 if k[length(k)] = ',' then delete(k, length(k), 1);
                 //if k[2] = ',' then k:= k[1] + '0' + copy(k, 2, length(k));

                 if (pos(',',k) > 0) then begin
                    tmp:= copy(k, pos(',',k)+1, length(k));
                    k:= copy(k, 1, pos(',',k)-1);
                 end;

                 if tmp <> '' then
                    while (strtoint(tmp) > 15) do delete(tmp, length(tmp), 1);

                 if length(k) > 1 then begin
                    if strtoint(copy(k, 2, length(k))) > 15 then tmp:= '';
                       while (strtoint(copy(k, 2, length(k))) > 15) do delete(k, length(k), 1);
                    if tmp <> '' then
                       k:= k + ',' + tmp;
                 end;

           if not (k[2] in ['0'..'9']) then begin
              bco:= clnone;
              f:= clBlack;
              fr:= '';
              bk:= '';
           end;

           //if (pos(',', k) = 0) then delete(k, 4, 2) else bk:= copy(k, pos(',', k)+1, 2);
//        r:= 'Orbita ' + char(2) + char(3) +'1,0You' + char(3) +'0,4Tube' + char(15) + char(2) + char(3) +'1 Video publicado por :   MoryChristmas  ' +
//            char(3) + '12 "Ella quiere su rumba Ella quiere su rumba Ella quiere su rumba PITBULL" ' + char(3) + '1 --  ' + char(3) +'4  4m';
//r:= 'Brioso: ' + char(2) + char(3) + '01,00You' + char(3) + '00,04Tube' + char(3) + '04,99' + char(15) + char(3) + '14 Sopa_Man-->' + char(3) + '01' + char(2) + 'POR TENER TU AMOR ' + char(3) + '04[' + char(3) +  '016:36' + char(3) + '04] ' + char(15) + '-- 4.994.912 vistas';

           if (length(k) > 1) then begin

                    if not (k[1] = ',') then
                    if (k[length(k)] = ',') then delete(k, length(k), 1);
                    //if (length(k) = 1) then str[ch]:= char(15); // o.O

           try
              if (pos(',',k) > 0) then begin
                 bk:= copy(k, pos(',',k)+1, length(k));
              end;

              //if (pos('orb', lines[l]) > 0) then ShowMessage('K1: ' + k);
           //if not (k[2] in ['0'..'9']) then k:= char(3) + '1';

              // Back
              if bk <> '' then begin
                 //bk:= copy(k, pos(',',k)+1, length(k));
                 if (length(bk) = 2) and (bk[1] = '0') then bk:= copy(bk, 2, 1);
                 if length(bk) > 2 then
                    if strtoint(bk) > 15 then bk:= copy(k, pos(',', k)+1, 1);
                 bco:= colors(bk);
              end;

              // Fore
              fr:= copy(k, 2, length(k));
              //ShowMessage('f ' + fr);
              if fr <> '' then
              if not (pos(',', fr) = 1) then begin
                 delete(fr, pos(',', fr), length(fr));
                 if (fr[1] = '0') and (length(fr) > 1) then fr:= fr[2];

                 if (length(fr) > 2) then if strtoint(fr) > 15 then delete(k, length(k), 1);
                 f:= colors(fr);
              end;

           k:= copy(k, 2, length(k));
           //if length(k) = 1 then k:= '';
           //ShowMessage('k: ' + k + ' / fr: ' + fr + ' / bk: ' + bk + ' / chr: ' + inttostr(ch));

              except
              ShowMessage('K is invalid: ' + k);
              end;

           delete(str, ch+1, length(k));
           //if ch >= length(lines[l]) then ShowMessage('hola');
           end; // Length > 1

           Lines[l]:= str;
           //ShowMessage('k: ' + k + ' / fr: ' + fr + ' / bk: ' + bk + ' / chr: ' + inttostr(ch));
           Attr1:= hl.CreateTokenID('Attr1', f, bco, []);
        end; // End Processing colors

        if not co = clnone then f:= co;
           Attr3:= hl.CreateTokenID('Attr3', clFuchsia,clnone,[]);
        if //( not b = c ) and
           (b1 = true) and (c1 = true)
           then begin
           Attr1:= hl.CreateTokenID('Attr1', f, bco, [fsBold]);
           Attr2:= Attr1;
        end else begin
            Attr1:=hl.CreateTokenID('Attr1',f, bco,[]);
            Attr2:=hl.CreateTokenID('Attr2',f,clNone,[fsBold]);
        end;

        if (str[ch] = char(1)) or (str[ch] = char(2)) or (str[ch] = char(3)) or (str[ch] = char(15)) or (str[ch] = char(31)) then inc(chs);

           if (co = clnone) then
           if ( (ch > 1 ) and (str[ch] = char(2)) or (str[ch] = char(3)) ) then begin
              if not (modi) then hl.AddToken(l, ch-chs-1, tktext);
           modi:= true;
        end;

        //if (modi = false) then hl.AddToken(l, ch-chs, tkText);
        //if (str[ch] = char(2)) and (co <> clnone) then if (b = false) then hl.AddToken(l, ch-chs-1, Attr1);
        if (c = true) and not (k = '') then if (str[ch+1] = char(2)) then hl.AddToken(l, ch-chs, Attr1);
        if (str[ch] = char(2)) then if (b = false) then hl.AddToken(l, ch-chs, Attr2);
        //if (str[ch] = char(2)) then if (b1 = false) and (c = false) and (co= clnone) then hl.AddToken(l, ch-chs, tkText);

        if (str[ch] = char(15)) then if (b1 = true) and (c1 = false) then hl.AddToken(l, ch-chs, Attr2);
        //if (str[ch] = char(15)) then if (b = true) and (c = true) then hl.AddToken(l, ch-chs, tktext);
        if (str[ch] = char(15)) then if (c = false) and (b1 = false) then hl.AddToken(l, ch-chs, Attr1);
        //if (str[ch] = char(15)) and ( b1 = c1 = true) then hl.AddToken(l, ch-chs, Attr1);
        if (str[ch] = char(15)) and ( b1 = c1 = true) then hl.AddToken(l, ch-chs, Attr1);
        //if (str[ch] = char(15)) and (b1 = false) and (c1 = false) then hl.AddToken(l, ch-chs, tkText);

        if (hy = false) then begin
        if (ch = length(str)) and not (str[ch] = char(1)) then if (b1 = true) and (c1 = false) then hl.AddToken(l, ch-chs, Attr2);
        if (ch = length(str)) and not (str[ch] = char(1)) then if (c1 = true) then hl.AddToken(l, ch-chs, Attr1);
        //if (ch = length(str)) then if (hy = true) then hl.AddToken(l, ch-chs, Attr3);
        end;

  if (str[ch] = char(2)) and (str[ch+1] = char(3)) then begin
     //if b = false then ShowMessage(str[ch]);
     if (b = true) then Attr1:= hl.CreateTokenID('Attr1', f, bco, []);
     //hl.AddToken(l, ch-chs, Attr1);
  end;
        //if (str[ch] = char(3)) then if (c1 = false) then hl.AddToken(l, ch-chs, tktext);
        if (str[ch+1] = char(3)) then hl.AddToken(l, ch-chs, Attr1);                         //if (ch = length(str)) and (b = false) then hl.AddToken(l, ch, tkText);


        // Coloring hyperlinks with purple
        //if (hy = true) and (str[ch] = char(1)) then hl.AddToken(l, ch-chs+1, tkText);
        if (str[ch] = char(1)) then
           //if () then hl.AddToken(l, ch-chs, Attr3) else
           if (hy = false) then hl.AddToken(l, ch-chs+1, Attr3) else
           if (c1 = true) then hl.AddToken(l, ch-chs, Attr1) else
              hl.AddToken(l, ch-chs-1, tkText);

        if (hy = true) and (ch = length(str)) then hl.AddToken(l, ch-chs, Attr3);


        if (str[ch] = char(15)) or (ch = length(str)) then begin
           if b = true then b:= false;
           if c1 = true then c:= false;
           b1:= false;
           c1:= false;
           fr:= ''; bk:= '';
           f:= clnone; bco:= clnone;
        end;
        if (str[ch] = char(2)) then begin
           if b = false then b1:= false;
        end;

        //if hy = true then hy:= false else hy:= true;
        //if (ch = length(str)) then k:= ''; f:= clblack;

  //if not (str[ch] = char(3)) then
  inc(ch);
  //if (pos('Olives', str) > 0) then ShowMessage('end: ' + inttostr(ch));
  end;
  modi:= false;

  str:= StringReplace(str, char(1), '', [rfReplaceAll]);
  str:= StringReplace(str, char(2), '', [rfReplaceAll]);
  str:= StringReplace(str, char(3), '', [rfReplaceAll]);
  str:= StringReplace(str, char(15), '', [rfReplaceAll]);
  str:= StringReplace(str, char(31), '', [rfReplaceAll]);
  str:= StringReplace(str, char(13), '', [rfReplaceAll]);
  //if (pos('Olives',str) > 0) then ShowMessage('k: ' + k + ' / fr: ' + fr + ' / bk: ' + bk + ' / chr: ' + inttostr(ch));

  Lines[l]:= str;

  inc(l);
  end; // Lines count

end;

procedure TSyn.procstring(r: string);
{This procedure deletes char(3) duplicates}
var c:  smallint = 1;
    k:  string;
begin
     r:= StringReplace(r, char(2), '', [rfReplaceAll]);
     r:= StringReplace(r, char(15), '', [rfReplaceAll]);
     r:= StringReplace(r, char(31), '', [rfReplaceAll]);
     r:= StringReplace(r, char(13), '', [rfReplaceAll]);

     // char(3) +'4  4m';
     if (pos(char(3), r) > 0) then
     while (c <= length(r)) do begin

           if (r[c] = char(3)) then begin
               k:= copy(r, c, 1);

               while ( (r[c+length(k )] in ['0'..'9'] ) or (r[c+length(k)] = ',') ) and ((c + length(k)) <= length(r))
                     do k:= copy(r, c, length(k)+1);
                     if k[length(k)] = ',' then delete(k, length(k), 1);
                     //if k[2] = ',' then k:= k[1] + '0' + copy(k, 2, length(k));

               if (pos(',',k) > 2) then
                  while (StrToInt(copy(k, 2, pos(',',k)-2)) > 15) do delete(k, length(k), 1);
               if (pos(',',k) > 0) then
                  while (StrToInt(copy(k, pos(',',k)+1, length(k))) > 15) do (delete(k, length(k), 1)) else
                  if length(k) > 2 then
                  while (strtoint(copy(k, 2, length(k))) > 15) do (delete(k, length(k), 1));

           //if assigned(m0[1]) then ShowMessage(k);
           delete(r, c, length(k)); // Replace
           end;
     if r[c] <> char(3) then inc(c);
     end;

     if (r <> '') and (r <> #13) then
     writeln(t, FormatDateTime('MMM d hh:mm:ss', now) + '  ' + r);
end;

procedure Tfmainc.opmClick(Sender: TObject);
begin
  OpenURL(str);
end;

procedure Tfmainc.clinkClick(Sender: TObject);
begin
     //if cl <> '' then
     Clipboard.AsText:= str;
end;

procedure TFmainc.tsynMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var x1,y1:  integer;
    o:      smallint;
begin
     o:= cnode(5, TreeView1.Selected.AbsoluteIndex,0, '');

     with m0[o] do begin


     x1:= (x div 7);
     y1:= (y div (LineHeight) + TopLine);
     //if x < Width -100 then CaretX:= x1;
     //if (y < Height - LineHeight) then CaretY:= y1;
     //label1.Caption:= 'x: ' + inttostr(x) + ' y: ' + inttostr(y);
     //label2.Caption:= copy(se.Lines[se.CaretY-1], se.CaretX, 1);

     end;
end;


procedure tfmainc.tsynMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var x1:      integer = 0;
    y1:      integer = 0;
    s:       smallint = 0; // Start position
    e:       smallint = 0; // End position
    e1:      smallint = 0;
    o:       smallint;
    chr:     string;   // Characters which can enclose and hyperlink
    tmp:     string;
begin
     chr:= ' ,()[]';

     s:= 1; // start position
     //x1:= x - form1.Left - se.Left;
     //y1:= y - form1.Top -  se.top;

     o:= cnode(5, TreeView1.Selected.AbsoluteIndex,0, '');

     with m0[o] do begin


     if button = mbRight then begin

     x1:= m0[o].CaretX;
     y1:= carety-1;

        //CaretX:= x1;
        //CaretY:= y1;


     x1:= (x div 7);
     y1:= (y div (LineHeight) + TopLine) -1;

     str:= Lines[y1];
     tmp:= str;


     // Getting string
     // Searching backwards from caret position to find a space or bracket
     if not (str = '') then begin

     if (x1 > length(lines[y1])) then x1:= length(lines[y1])-1;
     s:= x1;
     while (pos(str[s], chr) = 0) do begin
           if (pos(str[s],chr ) = 0) and (s = 1) and (y1 >= 0) then begin
              dec(y1);
              str:= lines[y1] + str;
              s:= length(lines[y1]);
           end;
     dec(s);
     end; // s = space
     //ShowMessage(inttostr(x1) + ' ' + inttostr(y1) + ' t ' + str);

     // Getting string
     // Searching forward from caret position to find a space or bracket
     e:= x1+1;
     //y1:= CaretY;
     while (pos(str[e], chr) = 0) and (str[e] <> ':') and (str[e] <> '*') do begin
           if (str[e] = '/') then e1:= s+e;
           //if not (str[e] in ['a'..'z']) and not (str[e] in ['A'..'Z']) then
           if (pos(str[e], chr) = 0) and (e = length(str)) and (str[e] = '/') or (str[e] = '%')
              and (y1 < lines.Count) then begin
              inc(y1);
              str:= str + lines[y1];
           end;
     inc(e);
     end;
     if str[e] = '.' then dec(e);
     //ShowMessage('_'+str[e]+'_');

     str:= copy(str, s+1, e-s); // copying from s+1 to e-1 -> resulting link

     //Removing the next line if necessary
     if (pos('*', str) > 0) or (str[length(str)] = ':') then begin
             e:= length(str);
             while not (str[e] = '/') and not (str[e] = '%') do dec(e);
     delete(str, e+1, length(str)-e);
     end;
     //m0[o].Append(str);


     if (pos('http://',str) = 1) or (pos('https://',str) = 1) then begin
        x1:= x + fmainc.Left + Left;
        y1:= y +20+ fmainc.Top  + top;
        //label1.Caption:= 'x: ' + inttostr(x1) + ' y: ' + inttostr(y1);
        //Clipboard.AsText:= str;
     if Button = mbRight then
        fmainc.poplm.PopUp(x1+100,y1+50) else fmainc.opmClick(nil);
     end;

     //ed0[o].Caption:= str;
     //if (x > s) and (x < e) then se.Cursor:= crHandPoint;

     end;
     end; // Right button
     end; //str = ''
end;

procedure Tfmainc.tsynPaint(Sender: TObject; ACanvas: TCanvas);
var y: smallint = 0;
    l: smallint;
begin
with TSyn(Sender) do begin

     l:= TopLine;
     //Append('l: ' + inttostr(l) + ' T: '+inttostr(l));
     l:= (lines.count - l); // Last visible line
     if (last > 0) then begin
     //if (TSyn(Sender).last div TSyn(Sender).LineHeight - tsyn(sender).TopLine) > TSyn(Sender).TopLine then begin
        Canvas.Pen.Color:= clred;
        y:= (last+1 - TopLine) * LineHeight;
        //Append('y '+ inttostr(y div LineHeight));
        Canvas.Line(0,y,Width,y);
     end;
end;
end;


{
procedure tsyn.crb(posx,posy: integer);
begin
with lin do begin
     lin:=      TBitmap.Create;
     width:=    100;
     height:=  5;
     canvas.Pen.Color:= clred;
     canvas.Line(0,0, width,0);
end;
end;
}
procedure tfmainc.txp(con: smallint; c,nick: string; r, query, go: boolean);
{con = connection, c = text, r is parent, query = isquery, go = get selected}
var n:      ttreenode;
    i:      smallint = 0;    // Notebook Page
    d,tmp:  string;
    p,s:    smallint;        // p = notebook page controls s = notebook pages
    ch:     boolean = false; // Sort algorithm
    t:      TControl;
begin
     //if go = true then
     SetLength(chanod, length(chanod)+1);

     if r = false then
        while (TreeView1.Items[i].Index < con) do i:= TreeView1.Items[i].GetNextSibling.AbsoluteIndex;
      n:= TreeView1.Items[i];

      //p:= cnode(5,i,0, '');
      if (length(chanod) > 1) then
      if (r = true) then begin
         TreeView1.Items.Add(nil, c);
         n.ImageIndex:= 0;
         i:= TreeView1.Items.GetLastNode.AbsoluteIndex;
      end else begin
          TreeView1.Items.AddChild(n, c);
          // Sorting tree nodes
          p:= i+1;
          //ShowMessage('hey' + inttostr(p));
          // Sorting Tree
          if (TreeView1.Items.Count > 1) then
          repeat
           ch:= false;
          while (TreeView1.Items[p].HasAsParent(TreeView1.Items[i])) and (p < TreeView1.Items.Count-1) do begin
                if TreeView1.Items[p+1].HasAsParent(TreeView1.Items[i]) then
                if (TreeView1.Items[p+1].Text < TreeView1.Items[p].Text) then begin
                   tmp:= TreeView1.Items[p].Text;
                   TreeView1.Items[p].Text:= TreeView1.Items[p+1].Text;
                   TreeView1.Items[p+1].Text:= tmp;
                   ch:= true;
                end;
          inc(p);
          end;
          p:= i+1;
          until ch = false;

          inc(i);
          // getting i to insert notebook page
          while (c > TreeView1.Items[i].Text) do inc(i);
                //i:= n.GetLastChild.AbsoluteIndex;
      end;

      if (TreeView1.Items[0].Text = 'Server') then TreeView1.Selected.Text:= c;

      // Assigning icons
      if r = false then
      if (query = false) then
         n.GetLastChild.ImageIndex:= 2 else
      if TreeView1.Items.Count > 1 then
         n.GetLastChild.ImageIndex:= 3;

      // sending c to nbadd2
      if (r = true) and (query = true) then d:= 'Connecting to ' + c + '...' else
      if (r = false) and (query = true) then d:= 'Private chat with ' + c else d:= c;

      if query = false then
         nbadd1(d, nick, con,i) else
         nbadd2(d, nick, con,i);

      {
      // Arranging controls (example m0[1]:= m0[0])
      // Saving node index in Memos
      s:= 0; p:= 0;
      if Notebook1.PageCount > 0 then
      while (assigned(m0[s])) do begin
            p:= m0[s].node;

            if p <> s then begin
            t:= ed0[s];
            ed0[s]:= ed0[p]; ed0[p]:= tedit(t);

            if assigned(lb0[s]) then begin
            t:= lb0[s];
            lb0[s]:= lb0[p]; lb0[p]:= tlistbox(t);
            t:= gb0[s];
            gb0[s]:= gb0[p]; gb0[p]:= TGroupBox(t);
            t:= lab0[s];
            lab0[s]:= lab0[p]; lab0[p]:= tlabel(t);
            t:= splt[s];
            splt[s]:= splt[p]; splt[p]:= tsplitter(t);
            end;

            t:= m0[s];
            m0[s]:= m0[p]; m0[p]:= tsyn(t);
            d:= m0[s].chan;
            m0[s].chan:= m0[p].chan;
            m0[p].chan:= d;
            m0[p].node:= p;
            m0[s].node:= s;
                  //ShowMessage(m0[s].chan + ' pch: ' + m0[p].chan);
            end;
      //p:= 0;
      inc(s);
      while not assigned(m0[s]) do inc(s);
      end;
      }

      {
      s:= 0; p:= 0;
      if Notebook1.PageCount > 0 then
      while (assigned(m0[s])) do begin
            ShowMessage(m0[s].name);
      inc(s);
      end;
      }
                                        //ShowMessage('hey 2');
      // Select created node except when you get a private message
      if TreeView1.Items.Count > 1 then
      if r = true then
      TreeView1.items.GetLastNode.Selected:= true
      else if go = true then
          //if TreeView1.Selected.HasChildren then ShowMessage('ch');
          //if TreeView1.Selected.HasChildren then
          TreeView1.Items[i].Selected:= true;

      //ShowMessage(inttostr(TreeView1.Items.GetLastNode.AbsoluteIndex));

      createlog(con, TreeView1.Selected.Text);

      //if length(com) = 1 then
      //SetLength(com, TreeView1.Items.Count, 20);
      //ed0[TreeView1.Selected.AbsoluteIndex].SetFocus;
end;

procedure tfmainc.nbadd1(c,nick: string; con,i: smallint);
{This procedure creates a widget with a listbox
 c = text, con = connection, i = pageindex}
var a: smallint = 0; // Memo number
begin
     //ShowMessage('nb1 '+inttostr(Notebook1.PageCount));
      if i = Notebook1.PageCount then
         Notebook1.Pages.Add('Page' + inttostr(i))
      else
         Notebook1.Pages.Insert(i, 'Page' + inttostr(i));
      //Notebook1.Pages.Add('Page' + inttostr(i));

     //Notebook1.Page[i].Name:= 'x' + inttostr(i);

     while assigned(m0[a]) do inc(a);

     // Splitter
     splt[a]:= TSplitter.Create(fmainc);
     splt[a].Parent:= Notebook1.Page[i];
     splt[a].Name:= 'sp' + inttostr(a);
     splt[a].Width:= 5;
     splt[a].ResizeAnchor:= akRight;
     splt[a].Align:= alCustom;
     splt[a].Left:= 770;
     splt[a].OnChangeBounds:= @Splitter1Moved;

     splt[a].AnchorToNeighbour(aktop, 0, Notebook1.Page[i]);
     splt[a].AnchorToNeighbour(akBottom, 0, Notebook1.Page[i]);
     splt[a].AnchorSide[aktop].Side:= asrTop;
     splt[a].AnchorSide[aktop].Control:= Notebook1.Page[i];
     splt[a].AnchorSide[akBottom].Side:= asrBottom;
     splt[a].AnchorSide[akBottom].Control:= Notebook1.Page[i];

     splt[a].Anchors:= [aktop] + [akBottom];

     // Edit box
     ed0[a]:= TEdit.Create(fmainc);
     ed0[a].Parent:= Notebook1.Page[i];
     ed0[a].Color:= RGBToColor(255,251,240);

     //ed0[a].Name:= 'edChannel' + inttostr(a);
     ed0[a].Caption:= '';

     ed0[a].Height:= 25;
     ed0[a].Width:= 768;
     //ShowMessage('count ' + inttostr(i));

     ed0[a].OnKeyPress:= @einputkeypress;
     ed0[a].OnKeyDown:= @einputKeyDown;

     //ed1.OnKeyup:= @einputKeyUp;
     //ed0[i].OnChange:= @einputChange;

     // Listbox
     lb0[a]:= TListBox.Create(fmainc);
     //lb0[a].Name:= 'lbChannel' + inttostr(a);
     lb0[a].Parent:= Notebook1.Page[i];
     //lb0[a].Left:= 783;
     lb0[a].Width:= 190;
     //m0[a].Color:= RGBToColor(255,251,240);
     lb0[a].Font.Size:= 8;
     lb0[a].Style:= lbOwnerDrawFixed;
     lb0[a].OnMouseUp:=  @lbmouseup;
     lb0[a].OnDrawItem:= @LbxDrawItem;

     {
     // Making room to insert a memo
     while assigned(m0[p]) do inc(p); // Getting the last memo
     //ShowMessage('i:' + inttostr(i) + ' p:' + inttostr(p));
           while (p > i) do begin
                 ShowMessage(inttostr(p));
                 m0[p+1]:= m0[p];
                 //m0[p+1].Parent:= Notebook1.Page[p];
                 //m0[p].free;
           dec(p);
           end;
           m0[i].free;                 // Deleteting memo
                   ShowMessage('epa'+inttostr(i));
     }
     // Memo
     m0[a]:= TSyn.Create(fmainc);
     m0[a].Parent:= Notebook1.Page[i];
     //m0[a].Name:= 'm0_' + inttostr(a);
     m0[a].Text:= '';
     m0[a].lc:= 0; // Counting lines;
     m0[a].node:= a;
     m0[a].Cursor:= crHandPoint;
     //m0[a].Color:= RGBToColor(243,243,243);
     m0[a].Color:= RGBToColor(255,251,240);
     m0[a].Gutter.Visible:= false;
     m0[a].RightGutter.Visible:= false;
     m0[a].Options:= [eoHideRightMargin] + [eoScrollPastEol] + [eoNoCaret] + [eoRightMouseMovesCursor];
     m0[a].Height:= 509;
     m0[a].Width:= 550;
     m0[a].lines.Add('Now chatting on ' + c);
     m0[a].ScrollBars:= ssVertical;
     m0[a].ReadOnly:= true;
     m0[a].ScrollBars:= ssAutoVertical;
     m0[a].Modified:= false;
     //m0[a].OnChange:= @mstatusChange;
     m0[a].OnKeyUp:= @Memo1KeyUp;
     m0[a].OnMouseMove:= @tsynMouseMove;
     m0[a].OnMouseUp:= @tsynMouseUp; //(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
     m0[a].OnPaint:= @tsynPaint;


     // RichMemo Font Attribues
     // adobe-courier-medium-r-normal-*-*-100-*-*-m-*-iso10646-1
     // spanish iso8859-1
     with m0[a].Font do begin

       {DejaVu Sans Mono
        Droid Sans Mono
        Free Mono
        Liberation Mono
        Nimbus Mono L
        MonoSpace
        Ubuntu Mono}

          //Name:= 'Ubuntu Mono';
          name:= 'Nimbus Mono L';
          CanUTF8;
          height:= 12;
          Color:= clBlack;
          Style:= [];
          //BkColor:= clWhite;
          //HasBkClr:= false;
     end;

     while (pos(' ',c) > 0) do delete(c, 1, pos(' ' ,c));
     m0[a].chan:= inttostr(con) + c;
     m0[a].nnick:= nick;

     // Adding chan and node to chanode
     cnode(0, i, a, inttostr(con) + c);


     m0[a].AnchorToNeighbour(akTop,0, Notebook1.Page[i]);
     m0[a].AnchorToNeighbour(akBottom,5, ed0[a]);
     m0[a].AnchorToNeighbour(akLeft,0, Notebook1.Page[i]);
     m0[a].AnchorToNeighbour(akRight,0, splt[a]);

     m0[a].AnchorSide[aktop].Side:= asrtop;
     m0[a].AnchorSide[aktop].Control:= Notebook1.Page[i];
     m0[a].AnchorSide[akBottom].Side:= asrTop;
     m0[a].AnchorSide[akBottom].Control:= ed0[a];
     m0[a].AnchorSide[akLeft].Side:= asrLeft;
     m0[a].AnchorSide[akLeft].Control:= Notebook1.Page[i];
     m0[a].AnchorSide[akRight].Side:= asrLeft;
     m0[a].AnchorSide[akRight].Control:= splt[a];

     m0[a].Anchors:= [aktop] + [akBottom] + [akLeft] + [akRight];

     // TEdit
     ed0[a].AnchorToNeighbour(akRight, 0, m0[a]);
     ed0[a].AnchorToNeighbour(akLeft, 0, m0[a]);

     ed0[a].AnchorSide[akLeft].Side := asrLeft;
     ed0[a].AnchorSide[akLeft].Control := m0[a];
     ed0[a].AnchorSide[akBottom].Side := asrBottom;
     ed0[a].AnchorSide[akBottom].Control := Notebook1.Page[i];
     ed0[a].AnchorSide[akRight].Side := asrRight;
     ed0[a].AnchorSide[akRight].Control := m0[a];

     ed0[a].Anchors := [akBottom] + [akleft] + [akRight];

     // Group (label)
     gb0[a]:= TGroupBox.Create(fmainc);
     gb0[a].Height:= 20;
     gb0[a].Width:= 170;
     gb0[a].Parent:= Notebook1.Page[i];
     //gb0[a].Name:= 'gbox' + inttostr(a);
     gb0[a].Caption:= '';
     gb0[a].Font.Size:= 7;

     gb0[a].AnchorToNeighbour(akTop,0, Notebook1.Page[i]);
     gb0[a].AnchorToNeighbour(akLeft,5, splt[a]);
     gb0[a].AnchorToNeighbour(akRight,0, Notebook1.Page[i]);

     gb0[a].AnchorSide[akTop].Side:= asrTop;
     gb0[a].AnchorSide[akTop].Control:= Notebook1.Page[i];
     gb0[a].AnchorSide[akLeft].Side:= asrLeft;
     gb0[a].AnchorSide[akLeft].Control:= splt[a];
     gb0[a].AnchorSide[akRight].Side:= asrRight;
     gb0[a].AnchorSide[akRight].Control:= Notebook1.Page[i];


     // List box
     lb0[a].AnchorToNeighbour(akBottom,10, gb0[a]);
     lb0[a].AnchorToNeighbour(akBottom,0, Notebook1.Page[i]);
     lb0[a].AnchorToNeighbour(akRight,0, splt[a]);
     lb0[a].AnchorToNeighbour(akLeft,0, Notebook1.Page[i]);

     lb0[a].AnchorSide[akTop].side:= asrBottom;
     lb0[a].AnchorSide[aktop].Control:= gb0[a];
     lb0[a].AnchorSide[akBottom].Side:= asrBottom;
     lb0[a].AnchorSide[akBottom].Control:= Notebook1.Page[i];
     lb0[a].AnchorSide[akright].Side:= asrRight;
     lb0[a].AnchorSide[akright].Control:= Notebook1.Page[i];
     lb0[a].AnchorSide[akleft].Side:= asrRight;
     lb0[a].AnchorSide[akleft].Control:= splt[a];


     // Counter label
     lab0[a]:= TLabel.Create(gb0[a]);
     lab0[a].Parent:= gb0[a];
     //lab0[a].Name:= 'countl' + inttostr(a);
     lab0[a].Caption:= 'Users: ';

     lab0[a].BorderSpacing.Bottom:= 10;
     lab0[a].AnchorToNeighbour(akTop,0, gb0[a]);
     lab0[a].AnchorToNeighbour(akRight,0, gb0[a]);


     lab0[a].AnchorSide[akTop].Side:= asrCenter;
     lab0[a].AnchorSide[akTop].Control:= gb0[a];
     lab0[a].AnchorSide[akRight].Side:= asrRight;
     lab0[a].AnchorSide[akRight].Control:= gb0[a];
     lab0[a].Anchors:= [aktop] + [akRight];

     gb0[a].Anchors:= [aktop] + [akLeft] + [akRight];
     lb0[a].Anchors:= [aktop] + [akBottom] + [akRight] + [akLeft];

     if (Notebook1.Page[i].Visible) then ed0[a].SetFocus;
end;

procedure tfmainc.nbadd2(c,nick: string; con,i: smallint);
{This procedure creates a widget without a listbox}
var a: smallint = 0;      // Memo number
    p: smallint = 0; // Array of tsyn position
begin
     //ShowMessage('nb2 '+inttostr(Notebook1.PageCount));

     //if i > Notebook1.PageCount -1 then Carefull!!!
     if (i > 0) then
     if i = Notebook1.PageCount then
        Notebook1.Pages.Add('Page' + inttostr(i))
     else
         Notebook1.Pages.Insert(i, 'Page' + inttostr(i));
         //Notebook1.Pages.Add('Page' + inttostr(i+1));


     //Notebook1.Page[i].Name:= 'x' + inttostr(i);
     while assigned(m0[a]) do inc(a);

     //if (pos('(', TreeView1.Items[0].Text) = 1) then dec(i);
     //if i = 1 then a:= 3;
     //if a = 0 then a:= 1;
     //if assigned(m0[0]) then inc(a);
     //ShowMessage('con: ' + inttostr(con));

     // Edit box
     ed0[a]:= TEdit.Create(fmainc);
     //ShowMessage('p ' + inttostr(Notebook1.PageCount));
     ed0[a].Parent:= Notebook1.Page[i];
     ed0[a].Name:= 'edqry_' + inttostr(a);
     ed0[a].Caption:= '';
     ed0[a].Color:= RGBToColor(255,251,240);

     ed0[a].Height:= 25;
     ed0[a].Width:= 768;

     ed0[a].AnchorSide[akLeft].Side := asrLeft;
     ed0[a].AnchorSide[akLeft].Control := Notebook1.Page[i];
     ed0[a].AnchorSide[akBottom].Side := asrBottom;
     ed0[a].AnchorSide[akBottom].Control := Notebook1.Page[i];
     ed0[a].AnchorToNeighbour(akright, 0, Notebook1.Page[i]);
     ed0[a].Anchors := [akBottom];

     ed0[a].OnKeyPress:= @einputKeyPress;
     ed0[a].OnKeyDown:= @einputKeyDown;
     //ed1.OnKeyup:= @einputKeyUp;
     //ed0[a].OnChange:= @einputChange;

     // Memo
     m0[a]:= TSyn.Create(fmainc);
     m0[a].Parent:= Notebook1.Page[i];
     m0[a].Name:= 'mq_' + inttostr(a);
     m0[a].Text:= '';
     m0[a].lc:= 0; // Counting lines;
     m0[a].node:= a;
     //m0[a].Color:= RGBToColor(243,243,243);
     m0[a].Color:= RGBToColor(255,251,240);
     m0[a].Gutter.Visible:= false;
     m0[a].RightGutter.Visible:= false;
     m0[a].Options:= [eoHideRightMargin] + [eoScrollPastEol] + [eoNoCaret] + [eoRightMouseMovesCursor];
     m0[a].Height:= 509;
     m0[a].Width:= 750;
     m0[a].lines.Add(c);
     m0[a].ScrollBars:= ssVertical;
     m0[a].ReadOnly:= true;
     m0[a].Modified:= false;
     //m0[a].OnChange:= @mstatusChange;
     m0[a].OnKeyUp:= @Memo1KeyUp;
     m0[a].OnMouseMove:= @tsynMouseMove;
     m0[a].OnMouseUp:= @tsynMouseUp; //(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

     // RichMemo Font Attribues
     //      // spanish iso8859-1
     // adobe-courier-medium-r-normal-*-*-100-*-*-m-*-iso10646-1
     with m0[a].Font do begin
          //Name:= 'Ubuntu Mono';
          name:= 'Nimbus Mono L';
          CanUTF8;
          Height:= 12;
          Color:= clBlack;
          Style:= [];
     end;

     delete(c, pos('...',c), length(c));
     while (pos(' ',c) > 0) do delete(c, 1, pos(' ',c));
     m0[a].chan:= inttostr(con) + c;
     m0[a].nnick:= nick;

     // Adding chan and node to chanode
     cnode(0, i, a, inttostr(con) + c);

     m0[a].AnchorToNeighbour(akTop,0, Notebook1.Page[i]);
     m0[a].AnchorToNeighbour(akBottom,5, ed0[a]);
     m0[a].AnchorToNeighbour(akLeft,0, Notebook1.Page[i]);
     m0[a].AnchorToNeighbour(akRight,5, Notebook1.Page[i]);

     m0[a].AnchorSide[aktop].Side:= asrtop;
     m0[a].AnchorSide[aktop].Control:= Notebook1.Page[i];
     m0[a].AnchorSide[akBottom].Side:= asrTop;
     m0[a].AnchorSide[akBottom].Control:= ed0[a];
     m0[a].AnchorSide[akLeft].Side:= asrLeft;
     m0[a].AnchorSide[akLeft].Control:= Notebook1.Page[i];
     m0[a].AnchorSide[akRight].Side:= asrRight;
     m0[a].AnchorSide[akRight].Control:= Notebook1.Page[i];

     m0[a].Anchors:= [aktop] + [akBottom] + [akLeft] + [akRight];

     // TEdit
     ed0[a].AnchorToNeighbour(akRight, 5, Notebook1.Page[i]);
     ed0[a].AnchorToNeighbour(akLeft, 0, m0[a]);

     ed0[a].AnchorSide[akLeft].Side := asrLeft;
     ed0[a].AnchorSide[akLeft].Control := m0[a];
     ed0[a].AnchorSide[akRight].Side := asrRight;
     ed0[a].AnchorSide[akRight].Control := Notebook1.Page[i];
     ed0[a].AnchorSide[akBottom].Side := asrBottom;
     ed0[a].AnchorSide[akBottom].Control := Notebook1.Page[i];
     ed0[a].Anchors := [akBottom] + [akleft] + [akRight];

     if (Notebook1.Page[i].Visible) then ed0[a].SetFocus;
     //ShowMessage('end');
end;

procedure Tfmainc.Splitter1Moved(Sender: TObject);
var c:  smallint = 0;
    tl: smallint = 0;
begin

     while (c < length(chanod)) do begin
           tl:= m0[cnode(3,0,c,'')].TopLine;
           m0[cnode(3,0,c,'')].unwr;
           m0[cnode(3,0,c,'')].wr(false);
           m0[cnode(3,0,c,'')].fcolors(false, clnone, '');

           m0[cnode(3,0,c,'')].TopLine:= tl;
     //m0[c].CaretY:= m0[c].Lines.Count;
     inc(c);
     end;
end;


function  Tfmainc.cnode(task,nod,ord: smallint; chan: string) :smallint;
{This function updates the tchan array which stores channels and nodes
 Task 0 = add channel
 Task 1 = remove channel
 Task 2 = srch the right memo (Tsynedit)
 If task = 2 given a channel, return the Memo number
 If task = 3 or 4, returns array and node from array position
 If task = 5 given a node, then return the array
 Tasks 6 and 7 are called from closen (delete network)
 If task = 8 then return the node from a given array}

var
   n:     smallint = 0;
   c:     smallint = 0;
   maxn:  SmallInt = 0; // Max Node
   conn:  string;
begin
     case task of
          0: Begin // Append
          for n:= 0 to length(chanod)-1 do begin
                if chanod[n].node >= nod then begin
                   chanod[n].node:= chanod[n].node+1;
                   //chanod[n].arr:= chanod[n].arr+1;
                end;
          end;

          //SetLength(chanod, length(chanod)+1);
          chanod[length(chanod)-1].chan:= chan;
          chanod[length(chanod)-1].node:= nod;
          chanod[length(chanod)-1].arr:= ord;
          //for n:= 0 to length(chanod)-1 do ShowMessage(inttostr(chanod[n].arr) + ' ' + chanod[n].chan);
          end; // Add

          1: Begin // Delete
          while (n < length(chanod)) do begin
                if chanod[n].arr = cnode(5,nod,0,'') then chanod[n]:= chanod[n+1];
                if chanod[n].node > nod then chanod[n].node:= chanod[n].node-1;
                   {com[n]:= com[n+1];
                   length(com):= length(com)-1;}
          inc(n);
          end;
          SetLength(chanod, length(chanod)-1);
          //for n:= 0 to length(chanod)-1 do if chanod[n].node > nod then chanod[n].node:= chanod[n].node-1;
          //for n:= 0 to length(chanod)-1 do ShowMessage(inttostr(chanod[n].arr) + ' ' + chanod[n].chan);
          end; // Delete

          2: begin // Search channel by name
          while (n < length(chanod)) do begin
                //chanod[n].chan:= lowercase(chanod[n].chan);
                if (lowercase(chanod[n].chan) = lowercase(chan)) then result:= chanod[n].arr;
          inc(n); end;
          //ShowMessage('chan: ' + inttostr(result));
          end; // Search

          3: begin // array-array
          //for n:= 0 to length(chanod)-1 do begin
              //if (chanod[n].arr = ord) then
              result:= chanod[ord].arr;
          //end;
          end; // Search

          4: begin // Search node from array index
          //for n:= 0 to length(chanod)-1 do begin
              //if (chanod[n].node = nod) then
              result:= chanod[ord].node;
          //end;
          end; // Search

          5: begin // Returns array from node
          for n:= 0 to length(chanod)-1 do begin
              if (chanod[n].node = nod) then
              result:= chanod[n].arr;
          end;
          end; // Search

          6: Begin // Delete a connection. Delete nodes and update channels

          while n < length(chanod) do begin
              //ShowMessage('nod ' + inttostr(chanod[n+1].node));
              //if (n+1) < length(chanod) then
              if (chanod[n].node >= nod) and (chanod[n].node <= ord) then begin
                                  //ShowMessage('epa ' + inttostr(chanod[n].node) + ' ' + chanod[n].chan);
                 for maxn:= n to length(chanod)-2 do begin
                     chanod[maxn]:= chanod[maxn+1];
                     //ShowMessage(chanod[maxn].chan);
                     {com[n]:= com[n+1];
                     length(com):= length(com)-1;}
                 end;
              dec(n);
              setlength(chanod, length(chanod)-1);
              end;
          //ShowMessage('length: ' + inttostr(length(chanod)) + ' n: ' + inttostr(n) + ' '  + (chanod[n].chan));
          inc(n);
          end;

          // Deleting last
          c:= nod;
          while c <= ord do begin
          inc(c);
          end;

          // Updating connection in channel names
          for n:= 0 to length(chanod)-1 do begin
              chanod[n].node:= chanod[n].node - ((ord - nod) +1);
              c:= 1;
              conn:= chanod[n].chan;
              //ShowMessage('u ' + conn);
              while (conn[c+1] in ['0'..'9']) and (c < length(chanod[n].chan)) do inc(c);
              conn:= copy(conn, 1, c);

          if strtoint(conn) > 0 then
              if conn <> '' then begin
                 delete(chanod[n].chan, 1, c);
                 chanod[n].chan:= inttostr(strtoint(conn)-1) + chanod[n].chan;
                 //ShowMessage('las ' + chanod[n].chan);
              end;
          end; // for

          //Delete last
          //ShowMessage('node: ' + inttostr(nod) + ' ' + inttostr(ord));
          //for n:= 0 to length(chanod) -1 do ShowMessage('Node: ' + inttostr(chanod[n].node) + ' chan: ' + chanod[n].chan);

          end; // 6

          7: begin // After update connection in channels (6), b becomes false.
             //b:= false;
             //for n:= 0 to length(chanod)-1 do ShowMessage(inttostr(chanod[n].arr) + ' ' + inttostr(chanod[n].node));
          end;

          8: begin // Returns the node from an array
             for n:= 0 to length(chanod)-1 do
                 if (chanod[n].arr = ord) then result:= chanod[n].node;
          end;

end; // task
end;

procedure Tfmainc.lbmouseup(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     if Button = mbRight then begin
      rc:= TListBox(sender).GetIndexAtXY(x, y);
      if rc > -1 then begin
         nickinfo(TListBox(sender).Items[rc]);
         nickpop.PopUp;
         end;
      end;
end;

function Tfmainc.nickinfo(nick: string): string;
var
    a:      string;
    ident:  string;
    ip:     string;
    p:      smallint;
    s:      smallint = 0;
    m:      TMenuItem;
    l:      string;
    tmp:    string = '';
begin
     a:= '~@%+';

     // Processing nick. Removing ~@%+
     while (s < length(nick)) do begin
           for p:= 1 to 4 do
               if (pos(a[p], nick) > 0) then delete(nick, 1, 1);
     inc(s);
     end;
     p:= 0; s:= 0; a:= '';

     // Getting connection
     if (TreeView1.Selected.Parent <> nil) then  s:= TreeView1.Selected.Parent.Index +1 else
        s:= TreeView1.Selected.Index +1;
        // s = connection. Parent.index +1


     // Querying who
     net[s].conn.SendString('WHO ' + nick + #13#10);

     while a = '' do a:= net[s].conn.RecvString(100);
     while tmp = '' do tmp:= net[s].conn.RecvString(200);
     //m0[1].Append(a);

     if a <> '' then
     for p:= 1 to 4 do delete(a, 1, pos(' ', a)); // Ident

     ident:= copy(a, 1, pos(' ', a)-1);
     delete(a, 1, pos(' ', a));
     ip:= copy(a, 1, pos(' ', a)-1);

     result:= nick + '!' + ident + '@' + ip;

     // Sending to PopUp menu
     nickpop.Items[0].Caption:= nick;
     //nickpop.Items[0].Items[0].Caption:= result;

     {
     Sollo ~Sollo 181.31.118.135 * John McClane
     Sollo @#nvx
     Sollo weber.freenode.net US
     Sollo is connecting from *@181.31.118.135 181.31.118.135
     Sollo 13 1500687836 seconds idle, signon time
     sollo End of /WHOIS list.
     :server code sollo sollo 13
     }
     m:= nickpop.Items[0].Items[0];

     // Querying whois
     net[s].conn.SendString('WHOIS ' + nick + #13#10);
     //a:= ''; while (a = '') do a:= net[s].conn.RecvString(100);
     a:= ''; tmp:= '';
     while (pos('whois', lowercase(a))) = 0 do begin
         a:= ''; tmp:= '';
         while a = '' do a:= net[s].conn.RecvString(100); //while(tmp = '') do tmp:= net[s].conn.RecvString(50); tmp:= '';
         //m0[1].Append(a);
     if pos('whois', lowercase(a)) = 0 then begin
           //if (pos('whois', lowercase(a)) > 0) then ShowMessage(a);

         delete(a, 1, pos(' ', a));

//ShowMessage(a);
         if (pos('311', a) > 0) then begin
            //ShowMessage(a);
            delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a));
            a[pos(' ', a)]:= '!';
            a[pos(' ', a)]:= '@';
            a:= StringReplace(a, ':', 'Real name: ', [rfReplaceAll]);
         end else
         if (pos('#', a) > 0) then begin
            delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a));
            a:= 'Channels:' + char(9) + copy(a, pos(':', a)+1, length(a));
         end else
         if pos('312', a) > 0 then begin
            delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a));
            a:= StringReplace(a, ':', '', [rfReplaceAll]);
            a:= 'Server:' + char(9) + char(9) + a;
         end else

         if (pos('378', a) > 0) then begin
            delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a));
            a:= StringReplace(a, ':', '', [rfReplaceAll]);
         end else


         if (pos('signon', lowercase(a)) > 0) then begin
            //ShowMessage(a);
            delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a));
            ident:= copy(a, 1, pos(' ', a)-1);
            delete(a, 1, pos(' ', a)); ip:= copy(a, 1, pos(' ', a)-1);
            //ShowMessage(ip);
            a:= 'seconds idle: ' + ident + ' signon: ' + DateTimeToStr(UnixToDateTime(strtoint(ip)));
         end else

         if (pos('logged', lowercase(a)) > 0) then begin
         delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a));
            a:= a + ' ' + copy(a, 1, pos(' ', a));
            a:= StringReplace(a, ':', '', [rfReplaceAll]);
                //net[s].conn.RecvString(400);
         end else
         begin
              delete(a, 1, pos(' ', a)); delete(a, 1, pos(' ', a));
              a:= StringReplace(a, ':', '', [rfReplaceAll]);
         end;

         inc(p);
         if l = '' then l:= a else if a <> '' then l:= l + sLineBreak + a;
     end;
     p:= 0;
     end;
     m.Caption:= l;
end;

procedure tfmainc.nickrclick(sender: TMenuItem);
var con:   smallint = 0;
    p:     smallint = 0; // menus
    chan:  string;
    e:     char = #13;
    mess:  string;
begin
     // Getting connection / n:= connection
        if (TreeView1.Selected.Parent = nil) then con:= TreeView1.Selected.Index+1 else con:= TreeView1.Selected.Parent.Index+1;

     // Getting channel
        chan:= TreeView1.Selected.Text;

     // Getting message
     for p:= 5 to 8 do if nickpop.Items[2].Items[p] = sender then fkickmess.ShowModal;
     mess:= ' :' + fkickmess.Edit1.Caption;

     // Voice
     if sender = gvm then net[con].conn.SendString('MODE ' + chan + ' +v ' + nickpop.items[0].caption + e);
     if sender = tvm then net[con].conn.SendString('MODE ' + chan + ' -v ' + nickpop.items[0].caption + e);

     // Op
     if sender = gopm then net[con].conn.SendString('MODE ' + chan + ' +o ' + nickpop.items[0].caption + e);
     if sender = topm then net[con].conn.SendString('MODE ' + chan + ' -o ' + nickpop.items[0].caption + e);

     // Ban
     if (sender = bnickm) then bans('/ban 1 ' + nickpop.items[0].caption,chan,con);
     if (sender = banidm) then bans('/ban 2 ' + nickpop.items[0].caption,chan,con);
     if (sender = banipm) then bans('/ban 3 ' + nickpop.items[0].caption,chan,con);

     // Kick
     if sender = kickm then net[con].conn.SendString('KICK ' + chan + ' ' + nickpop.items[0].caption + mess + e);

     // Kickban
        if (sender = kbnm)  then bans('/kb 1 ' + nickpop.items[0].caption + mess,chan,con);
        if (sender = kbim)  then bans('/kb 2 ' + nickpop.items[0].caption + mess,chan,con);
        if (sender = kbipm) then bans('/kb 3 ' + nickpop.items[0].caption + mess,chan,con);

     // Clear message
     fkickmess.Edit1.Clear;
end;

procedure Tfmainc.lbxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
var n:    smallint = 0;
    m:    smallint;
    a:    smallint = 0;
    s,ni: string;
    l:    smallint = 1;  // s position
    p:    smallint = 1;  // Copy starting position
begin
     s:= '~@%+';
     for m:= 0 to length(chanod)-1 do begin
                 n:= cnode(3,0,m, '');
                 //if (Assigned(lb0[n])) then lb0[n].Parent:= Notebook1.Page[m];
           if (Assigned(lb0[n])) then lb0[n].Color:= RGBToColor(255,251,240);

           if (Assigned(lb0[n])) then
           while (a < lb0[n].items.Count) do begin
                 ni:= lb0[n].Items[a];
                 if (pos(ni[p], s) > 0) then begin
                    while (pos(ni[p], s) > 0) do inc(p);
                    ni:= ni[1] + copy(ni, p, length(ni));
                 end;

     //m0[1].append(lb0[n].Items[a]);

                 while (ni[1] <> s[l]) and (l <= length(s)) do inc(l);
                 if (ni[1] <> s[l]) then l:= 0;

                 if l=1 then
                 lb0[n].Canvas.Draw(0, lb0[n].ItemRect(a).Top+3, gr[1]);

                 if l=2 then
                 lb0[n].Canvas.Draw(0, lb0[n].ItemRect(a).Top+3, gr[2]);

                 if l=3 then
                 lb0[n].Canvas.Draw(0, lb0[n].ItemRect(a).Top+3, gr[3]);

                 if l=4 then
                 lb0[n].Canvas.Draw(0, lb0[n].ItemRect(a).Top+3, gr[4]);

           if (l > 0) then
           lb0[n].Canvas.TextOut(15, lb0[n].ItemRect(a).Top+3, copy(ni, 2, length(ni))) else
           lb0[n].Canvas.TextOut(15, lb0[n].ItemRect(a).Top+3, ni);
           //lb0[n].Canvas.TextOut(15, lb0[n].ItemRect(a).Top+3, lb0[n].Items[a]);
           inc(a);
           p:= 1;
           l:= 1;
           end;
     a:= 0;
     end;
end;

procedure tfmainc.bans(com, chan: string; con: smallint);
{If typ = 1 then ban nick. If typ = 2 then ban ident. If typ = 3 then ban IP}
var
   comm,typ, mess:   string;
   nick, ident, ip:  string;
   tmp:              string;
   n:              smallint = 0;
   p:              smallint = 0;
   // user types /ban 1 nick :mess
begin
     // Processing commands

        delete(com, 1, 1);
        tmp:= com;
        delete(com, pos(' ', com), length(com));   // Command

        delete(tmp, 1, pos(' ', tmp));
        typ:= copy(tmp, 1, pos(' ', tmp)-1);       // Ban Type

        delete(tmp, 1, pos(' ', tmp));
        if (pos(' ', tmp) > 0) then
        nick:= copy(tmp, 1, pos(' ', tmp)-1) else  // Nick
        nick:= copy(tmp, 1, length(tmp));

        if pos(' ', tmp) > 0 then begin
        delete(tmp, 1, pos(' ', tmp));
        mess:= copy(tmp, 1, length(tmp));          // Message
        end;

     // Querying who
        net[con].conn.SendString('WHO ' + nick + #13#10);
        tmp:= '';
        while (tmp='') do tmp:= net[con].conn.RecvString(300); net[con].conn.RecvString(400);
        // :barjavel.freenode.net 352 Sollo * ~JMcClane 181.31.118.135 tolkien.freenode.net McClane H :0 John McClane
//ShowMessage(tmp);
      if (pos('#', tmp) > 0) then
        delete(tmp, 1, pos('#', tmp)) else delete(tmp, 1, pos('*', tmp));
        delete(tmp, 1, pos(' ', tmp));
        ident:= copy(tmp, 1, pos(' ', tmp)-1);
        delete(tmp, 1, pos(' ', tmp));
        ip:= copy(tmp, 1, pos(' ', tmp)-1);
//ShowMessage(ident + ' ' + ip);
        if (com = 'ban') or (com = 'kb') then begin

           if typ = '1' then net[con].conn.SendString('MODE ' + chan + ' +b ' + nick + '!*@*' + #13#10);
           if typ = '2' then net[con].conn.SendString('MODE ' + chan + ' +b ' + '*!' + ident + '@*' + #13#10);
           if typ = '3' then net[con].conn.SendString('MODE ' + chan + ' +b ' + '*!*@' + ip + #13#10);

        end;
//ShowMessage(mess);
        if (com = 'kb') then net[con].conn.SendString('KICK ' + chan + ' ' + nick  + ' :' + mess + #13#10);

end;


procedure Tfmainc.TrayIcon1Click(Sender: TObject);
begin
     if fmainc.Visible then fmainc.hide else fmainc.Show;
end;


procedure Tfmainc.tclosemClick(Sender: TObject);
begin
     close;
end;

procedure Tfmainc.infmClick(Sender: TObject);
begin
     Clipboard.AsText:= nickpop.Items[0].Items[0].Caption;
end;

procedure Tfmainc.privmClick(Sender: TObject);
var c,nick:    string;
    p:         smallint = 0;
    n:         smallint = 0;
    tl:        TListBox;
begin
     // Getting nick list from Notebook Page index
     while not (Notebook1.Page[Notebook1.PageIndex].Controls[p] is TListBox) do inc(p);

     c:= TListBox(Notebook1.Page[Notebook1.PageIndex].Controls[p]).Items[rc];
     //c:= 'mcclane';
     if (pos('~', c) > 0) or
     (pos('@', c) > 0) or
     (pos('%', c) > 0) or
     (pos('+', c) > 0)
     then c:= copy(c, 2, length(c));

     while not (Notebook1.Page[Notebook1.PageIndex].Controls[p] is tsyn) do inc(p);
     nick:= tsyn(Notebook1.Page[Notebook1.PageIndex].Controls[p]).nnick;

     txp(TreeView1.Selected.Parent.Index, c,nick, false, true, true);
     //TreeView1.Selected.Items[TreeView1.Items.Count-2].Selected:= true;
end;

function connex.gnicks(ch: string): string;
var r: string;
begin
     conn.SendString('NAMES ' + ch + #13#10);
     while (pos('=',r) = 0) do begin
     r:= conn.RecvString(200);
     end;
     {
     if (pos('JOIN',r) > 0) or (pos('PART',r) > 0) or (pos('PRIVMSG',r) > 0) or
        (pos('QUIT',r) > 0) or (pos('NICK',r) > 0) or (pos('ACTION',r) > 0) then
     }

     while (pos('/NAMES', r) = 0) do begin
     {
     while ( (pos('=', r ) > 0) or (pos('@', r) > 0) ) and (pos('JOIN', r) = 0) and (pos('PART', r) = 0)
            and (pos('QUIT', r) = 0) and (pos('PRIVMSG', r) = 0)
     do begin
     }

     {
     if (pos('registered', r) > 0) then begin
        delete(r, 1, pos(':', r));
        delete(r, 1, pos(':', r));
        //mstatus.Append(r);
        end;
     }

         if (pos('=', r) > 0) then
         //fmainc.fillnames(r, ch);
         r:= '';
         while (r = '') do r:= conn.RecvString(100);
     end;

     //while (pos('/NAMES', r) = 0) do r:= conn.RecvString(200);

     {
     while (r = '') //or ('NICK') or (pos('JOIN', r) > 0) or (pos('PART', r) > 0) //and (pos('PRIVMSG', r) > 0)
     do r:= conn.RecvString(200);
     }
      {
     if pos('nick', r) > 0 then begin
        recstatus(r);
        r:= conn.RecvString(200);
        recstatus(r);
        r:= conn.RecvString(200);
     end else
           result:= r;
      }
      //while pos('/NAMES', r) = 0 do r:= conn.RecvString(200);
end;

procedure Tfmainc.fillnames(r: string; ch: smallint);
var
   s,nm:  string;
   names: array[0..150] of string;
   n:     smallint = 0; // Array items
   p:     smallint = 1; // nick position
   l:     smallint = 1; // s position
begin
     timer1.Enabled:= false;
     s:= '~@%+';

     {
     //l:= TreeView1.Selected.AbsoluteIndex;
     while (assigned(m0[l])) do begin

     if (ch = m0[l].chan) then begin
     //l:= n;
     n:= 0;
     }
     //while pos(#13, r) > 0 do begin
     while (pos(':', r) > 0 ) do delete(r, 1, pos(':', r));

     {
     if r = '' then
        repeat r:= conn.RecvString(200);
        //while (r = '') and (pos('JOIN', r) > 0) or (pos('PART', r) > 0) and (pos('PRIVMSG', r) = 0)
        //do r:= conn.RecvString(200);
        until (pos('/NAMES', s) > 0);
     }

     while (pos(' ', r) > 0) and (pos('/NAMES', r) = 0) do begin
           names[n]:= copy(r, 1, pos(' ', r) -1);;
           delete(r, 1, pos(' ', r));
     inc(n);
     end;
     names[n]:= copy(r, pos(' ', r), length(r));
     n:= 0;

     while names[n] <> '' do begin
     lb0[ch].Items.Append(names[n]);
     inc(n);
     end;

     lab0[ch].Caption:= 'users: ' + inttostr(lb0[ch].Items.Count);
     fmainc.timer1.Enabled:= true;
end;



procedure tfmainc.lbchange(nick1, newnick: string; task, a, con: smallint);
var
   s:    string = '1';
   it:   string;
   p:    smallint = 0;  // Position from srchnick function
   e:    string = '~@%+';
   stat: boolean = false;
begin
     {Tasks
      0 = add nick
      1 = remove nick
      2 = change nick
      3 = add status
      4 = remove status
     }

     p:= strtoint(srchnick(nick1, 1, a)); // a is lb0 array number

Case task of
     0: Begin // append
        lb0[a].items.Insert(p, nick1);
     end; // 0 Append

     1: begin // Remove
        lb0[a].Items.Delete(p);
     end;     // 1 Remove

     2: Begin // Change
              lb0[a].Items.Insert(p+1, arstat(newnick));
              lb0[a].Items.Delete(p);

     end;     // Change

     3: Begin // Add status
              lb0[a].Items[p]:= arstat(newnick + lb0[a].Items[p]);
     end;     // Add Status

     4: begin // Remove status
              //ShowMessage('rs: ' + lb0[a].Items[p]);
              lb0[a].Items[p]:= StringReplace(lb0[a].Items[p], newnick, '', [rfReplaceAll]);
     end;     // Remove status
end; // Task

//lab0[a].Caption:= 'users: ' + inttostr(lb0[a].Items.Count);
lbsort(a);
end;

procedure tfmainc.lbsort(a: smallint);
var
   n:              smallint;
   op:             smallint = 0;  // Operators counter
   p:              smallint = 1; // Char position
   c,d,e:          string;
   item1,item2:    string;
   ch:             boolean = true;
   s:              integer = 1000;
   t:              integer = 1000;
begin
     e:= '~@%+';

     // If there's only one user
     item1:= lowercase(lb0[a].Items[0]);
     if (pos(item1[1], e) > 0) and (pos(item1[1], e) < 4) then inc(op);

     // Sorting all
     repeat
     n:= 0;
     ch:= false;
     while (n < lb0[a].Items.Count -1) do begin
           item1:= lowercase(lb0[a].Items[n]);
           while (pos(item1[p], e) > 0) do inc(p);
           if (p > 0) and (p < 4) then inc(op);
           item1:= copy(item1, p, length(item1));
           p:= 1;
//ShowMessage('sort: ' + item1);

           item2:= lowercase(lb0[a].Items[n+1]);
           while (pos(item2[p], e) > 0) do inc(p);
           item2:= copy(item2, p, length(item2));
           p:= 1;

           if (item2 < item1) then begin
              ch:= true;
              d:= lb0[a].Items[n];
              lb0[a].Items[n]:= lb0[a].Items[n+1];
              lb0[a].Items[n+1]:= d;
           end;
     inc(n);
     end;
     until ch= false;

     // Sorting Ops
     if lb0[a].Items.Count > 1 then // Avoid deleting ops count
     repeat
     n:= 0;
     ch:= false;
     op:= 0;
      while (n < lb0[a].Items.Count -1) do begin
            //if (pos(lb0[a].Items[n],e) > 0) then begin
               s:= pos(lb0[a].Items[n][1], e);   if s=0 then s:= 1000;
               t:= pos(lb0[a].Items[n+1][1], e); if t=0 then t:= 1000;
               if (s > 0) and (s < 4) then inc(op);
            //end;
                if (t < s ) then begin
                ch:= true;
                d:= lb0[a].Items[n];
                lb0[a].Items[n]:= lb0[a].Items[n+1];
                lb0[a].Items[n+1]:= d;
            end;
      inc(n);
      end;
      until ch= false;

      // Filling label
      lab0[a].Caption:= 'Ops: ' + inttostr(op) + ', users: ' + inttostr(lb0[a].Items.Count - op) +
                        ' - Total: ' + inttostr(lb0[a].Items.Count);
end;

function tfmainc.srchnick(nick: string; task, ch: smallint): string;
var n:    smallint = 0;
    tmp:  string;
    stat: string = '~@%+';
    p:    smallint = 1;
    f:    boolean = false;
begin
     while (n < lb0[ch].Count) do begin

           tmp:= lowercase(lb0[ch].Items[n]);
           while (pos(tmp[p], stat) > 0) do inc(p);
           tmp:= copy(tmp, p, length(tmp));

           if (lowercase(nick) = tmp) then begin
              f:= true;
              p:= n;
              n:= lb0[ch].Count-1;
           end;

        inc(n);
        if f = false then p:= 1;
        end;

     case task of
          0: Begin    // Boolean
             if f = true then result:= 'true' else result:= 'false';
          end;

          1: Begin    // Position
             result:= inttostr(p);
          end;
     end;
end;

function tfmainc.nicktab(ch: smallint; test: String):string;
const f:     boolean = false;
      last:  string = '';
      i:     smallint = 0;
      stat:  string = '~@%+';
      p:     smallint = 1;
begin
     if (last <> test) or (i >= lb0[ch].Items.Count) then begin
        i:= 0;
        f:= false;
     end;

     if (assigned(lb0[ch])) then
     repeat
           last:= lb0[ch].Items[i];
           while (pos(last[p], stat) > 0) do inc(p);
                 if (pos(last[p], stat) > 0) then
                    last:= copy(last, p+1, length(last)) else last:= copy(last, p, length(last));

           if (pos(lowercase(test), lowercase(last)) = 1) then begin
              if last <> '' then result:= last + ' ';
              f:= true;
           end;
           inc(i);
           p:= 1;
           if f = true then if i = lb0[ch].Items.Count then i:= 0;
     until
          (pos(lowercase(test), lowercase(last)) = 1) or (i = lb0[ch].Items.Count);
     if i = lb0[ch].Items.Count then begin
        i:= 0;
        f:= false;
     end;
     last:= test;
end;

procedure Tfmainc.TreeView1Change(Sender: TObject; Node: TTreeNode);
var
   n: smallint = 0;
begin
     Notebook1.PageIndex:= TreeView1.Selected.AbsoluteIndex;
     {
     if assigned(m0[1]) then
     if (Notebook1.Page[0].Visible) then
        TreeView1CustomDrawItem(TreeView1, TreeView1.Items.Item[0], [cdsIndeterminate], b);
        //TreeView1.Refresh;
     }
     //ShowMessage(inttostr(Notebook1.PageIndex));
end;

procedure Tfmainc.TreeView1CustomCreateItem(Sender: TCustomTreeView;
  var ATreeNode: TTreenode);
begin
     TreeView1.BackgroundColor:= clDefault;
     //TreeView1.SelectionFontColor:= clWhite;
     TreeView1.Color:= clWhite;
     TreeView1.Font.Color:= clBlack;
     TreeView1.BackgroundColor:= clDefault;
end;


procedure Tfmainc.TreeView1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var n: smallint;
begin
      if Button = mbRight then
         if TreeView1.GetNodeAt(x, y) <> nil then begin
         rc:= (TreeView1.GetNodeAt(x, y).AbsoluteIndex);
         treepop.PopUp;
      end;
end;

procedure Tfmainc.closemClick(Sender: TObject);
{This procedure comes from right click on the tree. It provides RC which is the
node selected for deletion.
1. Delete Notebook page.
2. Copy Next Notebook page to deleted page.
3. Delete tree node.
4. Leave the room
}
var
   conn:    smallint;
   room:    string;
   c:       smallint = 0;
   count:   smallint = 0;

begin
     if TreeView1.Items[rc].Parent = nil then closenclick(rc, TreeView1.Items[rc].Text) else

     with Notebook1 do begin
     timer1.Enabled:= false;
     TreeView1.Items[rc-1].Selected:= true;

     // Getting connection from TTreeView
     conn:= TreeView1.Items[rc].Parent.Index +1;
     // Room = Node name
     room:= TreeView1.Items[rc].Text;

     if (pos('#', room) > 0) then
     net[conn].conn.SendString('PART ' + room + ' Leaving' + #13#10);
     //timer1.Enabled:= false;

     // Deleting components on deleted page
     conn:= cnode(5,rc,0, '');
     //ShowMessage(inttostr(conn));
     freeandnil(lab0[conn]); freeandnil(gb0[conn]);
     freeandnil(lb0[conn]);
     freeandnil(ed0[conn]);freeandnil(m0[conn]);
     freeandnil(splt[conn]);

     // Deleting chan and node
     cnode(1, rc, 0, '');

     {
     // Testing
     for c:= 0 to length(chanod)-1 do begin
         m0[0].Append(chanod[c].chan + ' a: ' + inttostr(chanod[c].arr) + ' n: ' + inttostr(chanod[c].node));
     end;
     }

     // Arranging Notebook pages?
     count:= rc;
     while (count < PageCount-1) do begin
        // Deleting items. Finding item array from m0[x].node
        if count < pages.Count-1 then
           Pages[count]:= pages[count +1];
     inc(count);
     end; pages.Delete(rc);


     // Deleting Tree Node
     TreeView1.Items[rc].Delete;
     //TreeView1.Refresh;
     //Notebook1.PageIndex:= TreeView1.Selected.AbsoluteIndex;

     timer1.Enabled:= true;
     end; // Notebook
end;

procedure Tfmainc.closenClick(rc: smallint; c: string); // Delete Tree Items and TNotebook pages and close network
{The purpose of this procedure is
 1. delete tree subnodes and TNoteboook pages and their content
 2. delete tree parent
 3. close networks
 4. copy network
 5. Updating TSyn.nodes
    rc = Selected node}
var
    maxnode: smallint = 0; // Max node to delete
    n:       smallint = 0; // Node
    p:       smallint = 0; // Controls
    num:     smallint = 1; // Connection number Starting with 0
begin
     fmainc.Timer1.Enabled:= false;

     with TreeView1 do begin
     //items[0].Selected:= true;

     // Getting max node to delete
     if (items[rc].HasChildren) then maxnode:= Items[rc].GetLastChild.AbsoluteIndex else maxnode:= rc;


     //ShowMessage('mx ' +inttostr(maxnode));
     {
     n:= 0;
     while (n < Notebook1.PageCount-1) do  begin
     if assigned(Notebook1.Page[n]) then
     ShowMessage(inttostr(n));
     inc(n);
     end;
     }

     {
     // Moving controls. This is achived substracting (rc+1) - rc as well as notebook pages
     while assigned(m0[p]) do inc(p); // Last control (next control = rc +1)
     p:= p-maxnode;
     n:= 0;
     while (n < p-1) do begin
           if TreeView1.Items[rc].HasChildren then
           if assigned(lb0[n]) then begin
              gb0[rc+n]:=        gb0[maxnode+n+1];
              lab0[rc+n]:=       lab0[maxnode+n+1];
              lb0[rc+n]:=        lb0[maxnode+n+1];
           end;

           m0[rc+n]:=        m0[maxnode+n+1];
           m0[rc+n].node:=   rc+n;
           ed0[rc+n]:=       ed0[maxnode+n+1];
              ShowMessage(inttostr(n));
     {
     // Moving command history
     if Assigned(com[rc+n]) then com[rc+n]:= com[maxnode+n];
     com[maxnode+n]:= nil;
     }
     inc(n);
     end;


     {
     n:= 0;
     while (n < Notebook1.PageCount) do begin
           Notebook1.PageIndex:= n;
           ShowMessage(inttostr(n) + '=');
     inc(n);
     end;
     }
     }

     if (TreeView1.Items.Item[rc].GetNextSibling <> nil) then TreeView1.Items.Item[rc].GetNextSibling.Selected:= true;


     // Deleting controls.
     n:= rc;
     while (n <= maxnode) do begin // OjO
           p:= cnode(5,n,0, '');
           //ShowMessage('p ' + inttostr(p));
              if assigned(lb0[p]) then begin
              FreeAndNil(splt[p]);
              FreeAndNil(lab0[p]);
              FreeAndNil(gb0[p]);
              FreeAndNil(lb0[p]);
           end;

           freeandnil(m0[p]);
           freeandnil(ed0[p]);
           //ShowMessage('d ' + inttostr(n));
     inc(n);
     end;


     // Updating tchan array
     cnode(6, rc, maxnode, ''); // nod: rc, maxnode: ord
     //cnode(7, 0, 0, '');

     // Deleting NoteBook pages
     p:= Notebook1.PageCount;
     n:= rc;
     while (n <= maxnode) do begin
           Notebook1.Pages.Delete(rc);
           Notebook1.PageIndex:= Notebook1.PageIndex +1;
           Notebook1.PageIndex:= Notebook1.PageIndex -1;
     inc(n);
     end;

     {
     p:= 0;
     while (p < Notebook1.PageCount) do begin
           c:= Notebook1.Page[p].name;
           ShowMessage(inttostr(p));
           Notebook1.PageIndex:= p;
           m0[p+1].Visible:= true;
           inc(p);
     end;
     }
     {Notebook1.PageIndex:= 1;
     if assigned(items[rc+1]) then items[rc].Selected:= true;}

     // Deleting Tree Nodes
     n:= rc;
     if Items[rc].GetNextSibling <> nil then Items[rc].GetNextSibling.Selected:= true;
     num:= Items.Item[n].Index; // Saving index to get the connection
     TreeView1.Items.Item[n].Delete;

     end; // TreeView

     // Making num match the connection
     inc(num);

     // 3. Close network
     net[num].conn.CloseSocket; // Disconnect
     //items[rc].Text:= '(' + items[rc].text + ')';

     // net:      array[1..10] of connex;
     FreeAndNil(net[num]);

     // 4. Copy Network
     p:= num; //2
     //ShowMessage('ppp ' + inttostr(p));
     while (assigned(net[p+1])) do begin
     //ShowMessage('net: ' + inttostr(p+1));
           net[p]:= net[p+1];
           net[p].num:= p-1;
           net[p].server:= net[p+1].server;
           //net[p+1].conn.CloseSocket;
     p:= p+1;
     end;

     //net[2].destroy;
     //FreeAndNil(net[2]);
     //if assigned(net[1]) then ShowMessage('puta' + inttostr(rc+2));
     //net[1].conn.CloseSocket;

     fmainc.Timer1.Enabled:= true;
end;

procedure Tfmainc.TreeView1CustomDraw(Sender: TCustomTreeView;
  const ARect: TRect; var DefaultDraw: Boolean);
begin
     TreeView1.SelectionFontColor:= clWhite;
     TreeView1.SelectionColor:= clBlack;
     //TreeView1.Color:= clWhite;
     TreeView1.Font.Color:= clBlack;
     TreeView1.BackgroundColor:= $EBEBEB;
end;

procedure Tfmainc.TreeView1CustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
const mess: array of boolean = nil;
      blue: array of boolean = nil;
      r: array of boolean = nil;
var arr:  smallint = 0; // tmemos assigned
    m:    smallint = 0; // tmemos assigned
    n:    smallint = 0;
    i:    TIcon;
    s:    string;
begin
     SetLength(mess, TreeView1.Items.Count);
     SetLength(blue, TreeView1.Items.Count);
     SetLength(r, TreeView1.Items.Count);
     //SetLength(blue, TreeView1.Items.Count);
     //SetLength(mess, TreeView1.Items.Count);

     i:= TIcon.Create;
     //i.LoadFromFile('/home/nor/Lazarus/n-chat/Accessories/images/trayblue.ico');
     i.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'trayblue.ico');

     {
     if Notebook1.PageCount = 1 then begin
     Notebook1.PageIndex:= TreeView1.Selected.AbsoluteIndex;

     if node.AbsoluteIndex = 0 then begin

        if (m0[0].Modified) and not (Notebook1.Page[0].Visible) then
           sender.Canvas.Font.Color:= clMaroon;
        if m0[n].Parent.Visible then m0[0].Modified:= false;

     end; // Node 0

     end;
     }

     if Notebook1.PageCount > 0 then
        for arr:= 0 to length(chanod)-1 do begin

        n:= cnode(3,0,arr, '');
        m:= cnode(4,0,arr, '');

        //if m = 3 then m0[0].Append(inttostr(m));

        if assigned(m0[n]) then
           if (m0[n].Lines <> nil) then
           s:= m0[n].Lines[m0[n].Lines.Count -1];
           //s:= tr.Lines[tr.Lines.Count -1];

           if assigned(m0[n]) then

              if (m0[n].Modified) and not (m = Notebook1.PageIndex) then
                 //ShowMessage(TNotebook(m0[n].Parent.Parent).Name);
              //then

              if node.AbsoluteIndex = m then

              if (pos(lowercase(m0[n].nnick), lowercase(s)) > 0)
                 // or (blue[m] = true)
                 then begin
                 sender.Canvas.Font.Color:= clBlue;
                 blue[m]:= true;
                 r[m]:= true;
                 TrayIcon1.Icon:= i;
              end else

              if (pos('quit', lowercase(s)) = 0) and (pos('quit:', lowercase(s)) = 0)
                 and (pos('part', lowercase(s)) = 0)
                 and (pos('has joined #', lowercase(s)) = 0)
                 and (pos(':', s) > 0)
                 or mess[m] = true

              then begin
                   mess[m]:= true;
                   sender.Canvas.Font.Color:= clred;
                   if blue[m] = false then
                      i.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'trayred.ico');
                   TrayIcon1.Icon:= i;
              end else

                  if (mess[m] = false) then
                  sender.Canvas.Font.Color:= clMaroon;

              if (m = Notebook1.PageIndex) then begin
                 blue[m]:= false;
                 mess[m]:= false;
                 m0[n].Modified:= false;
                 r[m]:= false;
              end;
     end;

     //TreeView1.Refresh;
{
case modi of
     false: Begin {
            if Assigned(m0[1]) then
            while (assigned(m0[n])) do begin
                  if (m0[n].Modified) and (Notebook1.Page[n].Visible = false) then
                     if Node.AbsoluteIndex = n then
                        sender.Canvas.Font.Color:= clRed;
                  //if Notebook1.Page[n].Visible then modd:= true;
            inc(n);
            end;
            n:= 1;
            }
            if Assigned(m0[1]) then
            //if modi = 1 then m0[1].Append('1');
            //if mstatus.Modified then
               if Node.AbsoluteIndex = 0 then
                  sender.Canvas.Font.Color:= clRed;

            //if Notebook1.PageIndex = 0 then modd:= true;
     end;
     //end;


     true: Begin                                                                  {
           n:= 0;
           if assigned(m0[1]) then
           while (n < Notebook1.PageCount -1) do begin
                 //if not (Notebook1.Page[n].Visible) then modd:= false;
                 if (Notebook1.Page[n].Visible) then //or (Node.AbsoluteIndex = n) then
                    if Node.AbsoluteIndex = n then
                    sender.Canvas.Font.Color:= clBlack;
           inc(n);
           end;
           }

           if Assigned(m0[1]) then
              //if modi = true then m0[1].Append('t');
              if node.AbsoluteIndex = 0 then
                 sender.Canvas.Font.Color:= clblack;
                      //if mstatus.Modified then ShowMessage('t');
     end;

end; // Case
}
end;

procedure Tfmainc.TreeView1SelectionChanged(Sender: TObject);
{On change tree selection, the synedit is set to modified = false and
TEdit get the focus
Besides, the last line number is deleted}
var
   b: boolean = true;
   n: smallint = 0;
   i: TIcon;
   p: smallint = 0;
   c: string;
begin
     i:= TIcon.Create;
     i.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'tray.ico');

     //showmessage(inttostr(TreeView1.Selected.AbsoluteIndex));
     if not assigned(TreeView1.Selected) then TreeView1.items[0].Selected:= true;
     //if (Notebook1.PageCount > 0) then Notebook1.PageIndex:= 2;
     Notebook1.PageIndex:= TreeView1.Selected.AbsoluteIndex;


     //ShowMessage('count: ' + inttostr(Notebook1.PageCount));
     if TreeView1.Items.Count > 0 then
     for p:= 0 to length(chanod)-1 do begin
         n:= cnode(3,0,p,'');
         if assigned(m0[n]) then
         //if m0[n].Visible then ShowMessage(inttostr(m0[n].node));
         if (cnode(4,0,p,'') = Notebook1.PageIndex) then begin
            //Notebook1.PageIndex:= n;
         m0[n].Modified:= false;
         m0[n].shw:= true;
         b:= false;
           //ShowMessage(inttostr(cnode(4,0,p,'')));
         end;
         //ShowMessage(inttostr(m0[n].node));
     end;

     if (b = false) then TrayIcon1.Icon:= i;
     //TreeView1.Refresh;


     // Getting Tedit to set focus
     n:= 0;
     //ShowMessage(inttostr(Notebook1.PageIndex));
     if Notebook1.Page[Notebook1.PageIndex].ControlCount > 1 then
        //ShowMessage(inttostr(Notebook1.Page[TreeView1.Selected.AbsoluteIndex].ControlCount));
     while (n < Notebook1.Page[Notebook1.PageIndex].ControlCount) do begin
           if Notebook1.Page[Notebook1.PageIndex].Controls[n] is tedit then
              //if assigned(Notebook1.page[Notebook1.PageIndex].Controls[n]) then
              tedit(Notebook1.page[Notebook1.PageIndex].Controls[n]).setfocus;
           //ShowMessage('count ' + inttostr(Notebook1.PageCount));
     inc(n);
     end;

end;

procedure Tfmainc.mstatusChange(Sender: TObject);
var
   arr:    smallint = 0;
   n:      smallint = 0;
   i:      TIcon;
   b:      boolean = false;
begin
     i:= ticon.Create;
     i.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'trayred.ico');
     ShowMessage('changed ');

     if TreeView1.Items.Count > 1 then
     for arr:= 0 to length(chanod)-1 do begin
         n:= cnode(4,0,arr,'');
     if (assigned(m0[n])) then begin
           if m0[n].Modified then
           if not (TreeView1.Items[chanod[n].node].HasChildren) and
             (pos('#', TreeView1.Items[chanod[n].node].Text) = 0) then b:= true;
           //if m0[n].Modified then if (Notebook1.PageIndex = cnode(4,0,arr,'')) then m0[n].Modified:= false;
           {
           if Notebook1.PageIndex = m0[n].node then begin
              m0[n].crb(0, m0[n].CaretY);
              //m0[n].Canvas.line(0,m0[n].CaretY, m0[n].lin);
           end;
           }
     end;
     end;
     //TreeView1.Refresh;

     if b = true then begin
        i.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'trayblue.ico');
        TrayIcon1.Icon:= i;
     end;
end;


procedure tfmainc.TimerOnTimer(sender: TObject);
const ping: integer = 0;
var
      n:    smallint = 1;
begin
     {
     if timer1.Interval = 50 then begin
        while assigned(net[n]) do inc(n);
        n:= n-1;
        //net[n].loop;

     n:= 1
     end else begin
     }

     while not assigned(net[n]) do inc(n);

     while assigned(net[n]) do begin
     //ShowMessage('t ' + inttostr(n));

     if (timer1.Interval = 50) then begin
        while (Assigned(net[n])) do inc(n);
        dec(n);
     end;

     net[n].loop;
     //if assigned(net[2]) then ShowMessage(inttostr(n));
     if timer1.Interval = 2000 then
     ping:= ping + 2000;
     if (ping = 100000) then begin
        net[n].conn.SendString('PONG ' + net[n].server + #13#10);
        ping:= 0;
     end;

     inc(n);
     end;
end;


//initialization
//m1:= nil;

end.


