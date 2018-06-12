unit mainc;

{$mode objfpc}{$H+}{$m+}

interface

uses
    {{$ifdef unix}
    cthreads,
    cmem, // the c memory manager is on some systems much faster for multi-threading
    {$endif}}
    Interfaces, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
    StdCtrls, ExtCtrls, ComCtrls, Menus, ActnList, LCLIntf, LConvEncoding, blcksock, ssl_openssl, ssl_openssl_lib,
    SynEdit, SynHighlighterPosition, crt,
    dateutils, IniFiles, abform, setf, logf, servf, chanlist, joinf, functions, Types, Clipbrd, kmessf, banlist;
    //LMessages; //, LType;

Type


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
    MenuItem1: TMenuItem;
    Kbm: TMenuItem;
    MenuItem2: TMenuItem;
    nickm: TMenuItem;
    opm: TMenuItem;
    optm: TMenuItem;
    poplm: TPopupMenu;
    topm: TMenuItem;
    tvm: TMenuItem;
    opam: TMenuItem;
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

    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);

    procedure openmClick(Sender: TObject);
    procedure optmClick(Sender: TObject);
    procedure abmClick(Sender: TObject);
    procedure quitmClick(Sender: TObject);
    procedure servm1Click(Sender: TObject);
    procedure clistmClick(Sender: TObject);
    procedure banlmClick(Sender: TObject);

    procedure joinmClick(Sender: TObject);
    function dconmClick(Sender: TObject): smallint;
    procedure rconmClick(Sender: TObject);
    procedure TimerOnTimer(sender: TObject);

    function srchtree(nod: string):boolean; // Function which search duplicates rooms
    procedure mstatusChange(Sender: TObject);

    procedure LeaveRoom(task: smallint);
    procedure closeRMClick(Sender: TObject); // Delete Tree Item and leave a channel
    procedure closenClick(rc: smallint; c: string); // Delete Tree Items and TNotebook pages and close network

    procedure einputKeyPress(Sender: TObject; var Key: char);
    procedure einputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SynEdit1KeyPress(Sender: TObject; var Key: char);


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

    function nickinfo(task: boolean; nick: string): string;
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
  active:  boolean;          // Connection is active
  fast:    boolean;          // Connection fast (MOTD)
  nick:    string;

  public
  server:  string;
  servadd: string;
  constructor create;
  destructor destroy;
  procedure connect(co: smallint; createnode: boolean);
  procedure reconn;
  procedure join;
  procedure send(t: string);

  procedure loop;
  procedure recstatus(r: string);

  procedure output(c: tcolor; r: string; o: smallint);
  function gtopic(r: string): string;
  function gnicks(ch: string): string;

  end;

  TSyn = class(csynedit)
  //property Cursor: TCursor write SetCursor default crNo;
  public
  var
     nnick,chan:   string;
     node:         smallint;
     first:        smallint;
     last:         smallint;        // The last line. Used to set the marker line
     shw:          boolean;         // If it is not visible, saves the last line for the marker line
     lc:           integer;        // When reach 100 lines becomes true. It's a lines counter.
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
  ini:      TIniFile;
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
  gr:       array[1..6] of TPortableNetworkGraphic;
  str:      string; // Hyperlink in clipboard

implementation

{$R *.lfm}

{ Tfmainc }


constructor connex.create;
begin
     conn:= TTCPBlockSocket.Create;
     conn.SocksTimeout:= 6000;
end;

destructor connex.destroy;
begin
     FreeAndNil(conn);
end;


procedure connex.connect(co: smallint; createnode: boolean);
var
   n:    smallint = 0; // Node absolute index to get the memo for MOTD
   m:    smallint = 0;
   r:    string;
   tmp:  string;
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

     // Getting TreeNode and Getting MOTD

        while (fmainc.TreeView1.Items[n].Index < num) do begin
              n:= fmainc.TreeView1.Items[n].GetNextSibling.AbsoluteIndex;
        end;
        //if fmainc.TreeView1.Items.Count = 2 then n:= 1;
        fmainc.TreeView1.Items[n].Selected:= true;

        n:= fmainc.cnode(5,n,0,'');

     if fserv.nick1.Caption <> '' then
        if not fserv.globalc.Checked then
           nick:= fserv.nick1.Caption else
           nick:= fserv.gnick1.Caption else
           nick:= 'Lemon1';

     //TTCBlockSocket.Create;
     //Tloop.Create(true); // Connecting
     //Tloop.Start;
     conn.SetRemoteSin('','');

     if (conn.GetRemoteSinIP = '') then begin
        conn.Connect(servadd, fserv.Port.Caption);
           if (fserv.Port.Caption = '6697') or (fserv.Port.Caption = '7000') or (fserv.Port.Caption = '7070') then
           conn.SSLDoConnect;
           while not (conn.CanRead(2000)) and (m < 5) do begin
           //ShowMessage('connex: ' + inttostr(m));
              if m = 5 then begin
              conn.CloseSocket;
              //conn:= TTCPBlockSocket.Create;
              //if conn.LastErrorDesc <> '' then
           end;
           inc(m);
           end;
     if m = 5 then m0[n].Append(server + ' is unreachable');
     end;
     //if conn.GetRemoteSinIP <> '' then ShowMessage(conn.GetRemoteSinIP);
     fmainc.timer1.Interval:= 50;
     fast:= true;

     if conn.GetRemoteSinIP <> '' then

     try
        fmainc.timer1.Interval:= 50;
        //conn.SendString('PASS oasis ' + #13#10);
        conn.SendString('NICK ' + nick + #13#10);

        if fserv.globalc.Checked then
        conn.sendstring('USER ' + fserv.guser.caption + ' 0 * :' + fserv.grname.Caption + #13#10) else
           conn.sendstring('USER ' + fserv.userm.caption + ' 0 * :' + fserv.rname.Caption + #13#10);

        //conn.SendString('USER McClane 0 * :John McClane' + #13#10);// You want to use SendStream or SendStreamRaw for binary.

        //conn.SendString('SERVICE dict * *.fr 0 0 :French Dictionary %x0D%x0A');
        //conn.SendString('MOTD ' + #13#10);

        //conn.SendString('JOIN #nvz ' + #13#10);
        //conn.SendString('TOPIC #nvz ' + #13#10);

        // Deleting parenthesis
        if createnode = false then begin
            while (fmainc.TreeView1.Items[m].Index < num) do
                  m:= fmainc.TreeView1.Items[m].GetNextSibling.AbsoluteIndex;

              fmainc.TreeView1.Items[m].Text:= StringReplace(fmainc.TreeView1.Items[m].Text, '(', '', [rfReplaceAll]);
              fmainc.TreeView1.Items[m].Text:= StringReplace(fmainc.TreeView1.Items[m].Text, ')', '', [rfReplaceAll]);
        server:= fmainc.TreeView1.Items[m].Text;
        end;

   //m0[n].chan:= inttostr(num) + fmainc.TreeView1.Items[n].Text;
   //fmainc.createlog(co, server);

   {
   // Connecting until /MOTD

   repeat
   r:= '';
   tmp:= '';
   mess:= '';

   //if fmainc.Timer1.Enabled then
     r:= conn.RecvString(1000);

   // Processing r
   if (pos(':', r) = 1) then delete(r, 1, 1);

         if (pos('already in use',lowercase(r)) > 0 ) then begin
            //fmainc.Timer1.Enabled:= false;
            //break;
            ShowMessage(r);
            //output(clnone, copy(r, pos(':', r)+1, length(r)), n);
            //r:= '';
            if (pos('/nick', ed0[n].Caption) = 1) then begin
               //Continue;
               mess:= copy(ed0[n].caption, pos(' ', ed0[n].caption)+1, length(ed0[n].caption));
               //ShowMessage(mess);
               //conn.SendString('NICK ' +  mess  + #13#10);
               nick:= mess;
               //fmainc.Timer1.Enabled:= true;
            end;
         end;

         if (pos('PING ', r) > 0) then begin
            conn.SendString('PONG ' + copy(r, pos(':', r)+1, length(r) - pos(':', r)) +#13#10);
            //ShowMessage('PONG ' + copy(r, pos(':', r)+1, length(r) - pos(':', r)) +#13#10);
            r:= '';
         end;
         //ShowMessage(r);
   if (r <> '') then tmp:= r;

   if (pos('NOTICE', r) > 0) and (pos('!', r) = 0) and (pos('NOTICE:', r) = 0) then delete(r, 1, pos('NOTICE',r) + length('NOTICE')) else
   //if (pos(nick + ' ', r) > 0) and ( (pos('!', r) > (pos(':', r))) ) then

      for m:= 0 to 2 do delete(r, 1, pos(' ', r));
      //if (r <> '') then ShowMessage('bak ' + bak);
   if pos(':', r) > 0 then begin
      //delete(r, 1, pos(nick, r) + length(nick));
      //if (pos(':', tmp) > 0) then mess:= tmp else
      mess:= copy(r, pos(':', r)+1, length(r));
   end;

   // Deleting message from r to make it clean
   if ( (pos('m:', r) = 0) and (pos('m:', r) < (pos(':', r))) ) then
   delete(r, pos(':' + mess, r), length(mess)+1);
   r:= r + mess;

   recstatus(r);

   until (pos('/MOTD', r) > 0);
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

     if conn.CanRead(2000) then begin
        //output(clnone, 'Connected... now logging in', n);
        fmainc.clistm.Enabled:= true;
        fmainc.joinm.Enabled:= true;
          fmainc.ToolButton2.Enabled:= true;
        fmainc.dconm.Enabled:= true;
        fmainc.chanm.Enabled:= true;
        active:= true;
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
     conn.CloseSocket;
     conn.SetRemoteSin('','');
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
   conn: smallint = 0; // Connection
   n:    smallint = 0; // Parent
   m:    smallint = 0; // Last child
   no:   smallint = 0; // Object (array)
begin
     if (TreeView1.Selected.Parent = nil) then n:= TreeView1.Selected.AbsoluteIndex else
        n:= TreeView1.Selected.Parent.AbsoluteIndex;
        if TreeView1.Items[n].HasChildren then m:= TreeView1.Items[n].GetLastChild.AbsoluteIndex;

        //net[n+1].conn.SendString('KILL' + #13#10);
        //net[s+1].conn.SendString('KILL ' + net[s+1].nick + #13#10);
        conn:= TreeView1.Items[n].Index +1;
        net[conn].conn.CloseSocket;
        net[conn].active:= false;

        result:= conn;

     while (n <= m) do begin
           no:= cnode(5,n,0,'');
           if (pos('(', TreeView1.Items[n].Text) = 0) then
           TreeView1.Items[n].Text:= '(' + TreeView1.Items[n].Text + ')';
           m0[no].Append('Disconnected');

           if assigned(lb0[no]) then begin
              lb0[no].Clear;
              lab0[no].Caption:= '';
           end;
     inc(n);
     end;
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

procedure Tfmainc.SynEdit1KeyPress(Sender: TObject; var Key: char);
var n: smallint = 0;
begin
     with fmainc do begin
          if Notebook1.Page[Notebook1.PageIndex].ControlCount > 1 then
             while not (Notebook1.Page[Notebook1.PageIndex].Controls[n] is TEdit) do inc(n);
             tedit(Notebook1.Page[Notebook1.PageIndex].Controls[n]).SetFocus;
     end;
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
var n:     smallint = 0;
    iniv:  TStrings;
begin
     caption:= 'n-chat';
     //einput.SetFocus;
     TrayIcon1.Show;
     if not assigned(m0[0]) then begin
     fserv.Show;

        for n:= 1 to 6 do begin
            gr[n]:= TPortableNetworkGraphic.Create;
        end;

        gr[1].LoadFromFile( ExtractFilePath(ParamStr(0)) + 'ircop.png' );
        gr[2].LoadFromFile( ExtractFilePath(ParamStr(0)) + 'vio.png' );   //owner
        gr[3].LoadFromFile( ExtractFilePath(ParamStr(0)) + 'admin.png' ); // &
        gr[4].LoadFromFile( ExtractFilePath(ParamStr(0)) + 'blue.png' );  // op
        gr[5].LoadFromFile( ExtractFilePath(ParamStr(0)) + 'green.png' ); // half op
        gr[6].LoadFromFile( ExtractFilePath(ParamStr(0)) + 'voice.png' );
     end;
     {red    = IRCop
      Violet = owner
      blue   = op
      green  = half op
      voice  = orange}

      // ini.file
      iniv:= TStringList.Create;
      if FileExists(GetEnvironmentVariable('HOME') + DirectorySeparator + '.config' + DirectorySeparator + 'LemonChat' + DirectorySeparator + 'Lemon.ini') then begin
      ini:= TIniFile.Create(GetEnvironmentVariable('HOME') + DirectorySeparator + '.config' + DirectorySeparator + 'LemonChat' + DirectorySeparator + 'Lemon.ini');
      ini.ReadSectionValues('Settings', iniv);
      for n:= 0 to iniv.Count-1 do begin
          //ShowMessage(iniv[n]);
          if iniv[0] = 'Traffic=yes' then fsett.chg1.Checked[0]:= true;
          if iniv[1] = 'Log=yes' then fsett.chg1.Checked[1]:= true;
      end;
      iniv.Clear;

      ini.ReadSectionValues('Path', iniv);
      if iniv[0] <> '' then fsett.pathl.Caption:= copy(iniv[0], pos('=', iniv[0])+1, length(iniv[0]));
      end;

      if (fsett.pathl.Caption = '') then begin

      {$ifdef Windows}
      fsett.pathl.Caption:= GetEnvironmentVariable('MyDocs') + DirectorySeparator + 'LemonChat Logs';
      mkdir(fsett.pathl.Caption);
      {$endif}

      {$ifdef unix}
      fsett.pathl.Caption:= GetEnvironmentVariable('HOME') + DirectorySeparator + '.config' + DirectorySeparator + 'LemonChat/Logs';
      mkdir(fsett.pathl.Caption);
      {$endif}
      end;

iniv.Free;
end;

procedure Tfmainc.abmClick(Sender: TObject);
begin
     abf.ShowModal;
end;


procedure Tfmainc.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var i: smallint = 0;
    path: string;
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
     for i:= 1 to 6 do gr[i].Free;

     fsett.Close;
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

procedure Tfmainc.openmClick(Sender: TObject);
begin
     flogr.openmClick(fmainc);
end;

procedure Tfmainc.optmClick(Sender: TObject);
begin
  fsett.show;
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
     path:= fsett.pathl.Caption + DirectorySeparator;
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
           n:= cnode(5,trm,0,'');
           //if pos('#', chan) = 0 then chan:= '';
           //ShowMessage(chan);

     if key = #13 then begin

        //while (m0[n].node <> TreeView1.Selected.AbsoluteIndex) do inc(n); trm:= n; // Getting memo
        SetLength(m0[n].com, length(m0[n].com)+1);
        //SetLength(com, TreeView1.Items.Count, l[trm]+2);

        if (pos('(', TreeView1.Selected.Text) = 0) then
        createlog(ne-1, TreeView1.Selected.Text);

        if TEdit(sender).Caption <> '' then begin

           s:= TEdit(sender).Caption;

               {
               // Nick Change
               if not (TreeView1.Items[ne-1].HasChildren) then
               if (pos('/nick ', s) = 1) then
                  if (pos(':',s) = 0)  then net[ne].nick:= copy(s, pos(' ',s)+1, length(s)) else
                  net[ne].nick:= copy(s, pos(' ',s)+1, pos(':',s) - pos(' ',s)-1);
               }

           //if (pos('/topic', s) = 1) then ShowMessage(replce(s + ' :' + chan) + '_') else
           if (pos(lowercase('/list'), lowercase(s)) = 1) then fclist.getchannels(ne, net[ne].nick) else

           if (pos('/query', lowercase(s)) = 1) then begin
              if (pos('#', replce(s)) > 0) or (lowercase(replce(s)) = 'noquery') then
                 m0[n].Append('Usage /query <nick>, opens a private message window for someone') else
                    txp(ne-1,replce(s), net[ne].nick,false,true,true);
                 m0[n].CaretY:= m0[n].Lines.Count;
           end else

           if (pos('/', s) = 1) then begin

              // Banlist
              if (pos('/banlist', s) = 1) then begin
                 if (TreeView1.Items[trm].Parent = nil) then
                    ShowMessage('You need to get the bans list from a channel') else
                    fbanlist.FormActivate(banlm);
              end else

              // Bans
              if (pos('/ban', lowercase(s)) = 1) or (pos('/kb', lowercase(s)) = 1) and (pos(':m', s) = 0) then begin
                 s:= StringReplace(s, '   ', ' ', [rfReplaceAll]);
                 s:= StringReplace(s, '  ', ' ', [rfReplaceAll]);
                 //if (s[length(s)] = ' ') then delete(s, length(s), 1);
                 bans(s, chan, ne);
                 //ShowMessage('hey ' + s);

              end else

              if (pos(lowercase('/nick'), lowercase(s)) = 1) then begin
                 net[ne].conn.SendString(copy(s, 2, length(s)) + #13#10);
                 //m0[n].nnick:= copy(s, pos(' ', s)+1, length(s));
                 //net[ne].nicknew:= copy(s, pos(' ', s)+1, length(s));
                 if (pos('already in use', m0[n].Lines[m0[n].Lines.Count-1]) > 0) then
                    net[ne].nick:= copy(s, pos(' ', s)+1, length(s));
              end else

              if (pos(lowercase('/topic'), lowercase(s)) = 1) or
                 (pos(lowercase('/part'), lowercase(s)) = 1) or
                 (pos(lowercase('/op'),lowercase(s)) = 1) or (pos(lowercase('/deop'),lowercase(s)) = 1) or
                 (pos(lowercase('/h'),lowercase(s)) = 1) or (pos(lowercase('/deh'),lowercase(s)) = 1) or
                 (pos(lowercase('/voice'),lowercase(s)) = 1) or (pos(lowercase('/devoice'),lowercase(s)) = 1) or
                 (pos(lowercase('/ban'),lowercase(s)) = 1) or (pos(lowercase('/unban'),lowercase(s)) = 1) or
                 (pos(lowercase('/kick'),lowercase(s)) = 1) or (pos(lowercase('/invite'),lowercase(s)) = 1)
                 then

              //if (pos('/ban', s) = 0) and (pos('/kb', s) = 0) then s:= s + ':' + chan;
              //if (pos('/ban', s) = 0) and (pos('/kb', s) = 0) then begin

                 net[ne].conn.SendString(replce(s + ' :' + chan))
                 //ShowMessage(replce(s +  ' :' + chan))
              else
                  if (pos('/me', lowercase(s)) = 1) then
                  net[ne].send('PRIVMSG ' + copy(m0[n].chan,2,length(m0[n].chan)) + ' :' + replce(StringReplace(s, '/', '/ ', [rfReplaceAll]))) else
                  net[ne].conn.SendString(replce(s));

              //com[trm, l[trm]]:= s;
              //inc(l[trm]);
              m0[n].com[length(m0[n].com)-1]:= s;
              //inc(m0[n].comn);

              if (pos('/me', lowercase(TEdit(sender).Caption)) = 1) then net[ne].output(clPurple, replce(s + '~'+m0[n].nnick), n);
           end else begin

           rc:= n;

           //ShowMessage(inttostr(n));
           //net[1].conn.SendString('PRIVMSG ' + m0[n] + ' :' + s + #13#10) else
           //if chan[n] <> TreeView1.Selected.Text then chan[n]:= TreeView1.Selected.Text;
           //if assigned(m0[3]) then ShowMessage(copy(m0[n].chan,2,length(m0[n].chan)));

           if (pos('(', TreeView1.Selected.Text) = 0) then
              net[ne].send('PRIVMSG ' + copy(m0[n].chan,2,length(m0[n].chan)) + ' : ' + s + #13#10);

           if (pos('(', TreeView1.Selected.Text) = 0) then
              net[ne].output(clnone, net[ne].nick + ': ' + s, n) else
              m0[n].append('No channel joined, try /join #channel');

           if (pos('(', TreeView1.Selected.Text) = 0) then CloseFile(t);

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
         m0[n].SetFocus;
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


procedure tfmainc.raw(r: string);
var ro: TextFile;
begin
     if (r <> '') then m0[0].Lines.Add(r);
        AssignFile(ro, '/home/nor/raw.txt');
        if not FileExists('/home/nor/raw.txt') then rewrite(ro) else reset(ro);
     append(ro);
     if (r <> '') then writeln(ro, r);
     closefile(ro);
end;

procedure connex.loop;
var r: string = ''; // recvstring
begin      r:= conn.RecvString(200);
           //if (pos('PING', r) > 0) then conn.SendString('PONG ' + copy(r, pos(':', r)+1, length(r)) + #13#10);
           //if (r <> '' ) then
           //result:= r;
           recstatus(r);
           //ShowMessage(r);
           //fmainc.raw(r);
end;

procedure connex.recstatus(r: string);
var
          test:  TextFile;
          room:  boolean = false;
          n:     smallint = 0; // Initial node
          m:     smallint = 0; // Final node
          s:     smallint = 0; // Case
          x1:    smallint = 0; // tmp
          x2:    smallint = 0; // tmp
          cname: string = ''; // Channel name
          mess:  string;      // Message
          bak,tmp:   string;
          i:     TIcon;
begin
        // Getting connection in the tree where num = connection number starting with 0
        //if (num = 0) then ShowMessage('zero');
        //if num > 0 then
        {
        while (fmainc.TreeView1.Items[n].Index < num) do begin
              //ShowMessage(fmainc.TreeView1.Items[n].Text);
              if (fmainc.TreeView1.Items[n].GetNextSibling <> nil) then
              n:= fmainc.TreeView1.Items[n].GetNextSibling.AbsoluteIndex;
              //while (n <> m0[n].node) do inc(n);
        end;
        }
           //if assigned(net[num+1]) then ShowMessage(inttostr(num) + sLineBreak + net[num+1].server);
           //n:= fmainc.cnode(2,0,0,inttostr(num) + server);
           //if (n < 0) and (n > 20) then ShowMessage('0: ' + inttostr(n));
           //ShowMessage(m0[n].nnick);

     //if (assigned(m0[2])) and (pos('PART', r) > 0) then ShowMessage('n: ' + inttostr(n) + ' r: ' + r);

     {
     if (pos(nick, r) > 0) and (pos('PART', r) > 0) then begin
        //ShowMessage(r + ' n ' + inttostr(n) + nick);
        if (pos('enough param', r) = 0) then
        r:= ':PART ' + copy(r, pos('#',r), length(r)) + ':You have left channel ' + copy(r, pos('#',r), length(r));
     end;
     }

     if (pos(':', r) = 1) or (pos(' :', r) = 1) then
     delete(r, 1, pos(':', r)); // First colon

     try
        n:= strtoint(r);
     except
     end;

     if (pos('PING ', r) > 0) or (n <> 0) then begin
        conn.SendString('PONG ' + copy(r, pos(':', r)+1, length(r) - pos(':', r)) +#13#10);
        //ShowMessage('PONG ' + copy (r, pos(':', r)+1, length(r) - pos(':', r)) +#13#10);
        r:= '';
     end;

     //if (assigned(m0[1])) then r:= 'waterbot!water@2001470:67:866:ae81:ca:7413:4111 PRIVMSG #nvz :The duck escapes.     ·°''°-.,žž.·°''' + char(3);


     // Getting Message
     //if (pos('*',r) > 0) then ShowMessage(r + sLineBreak + mess);
     tmp:= r;
     bak:= r;

     if (pos('NOTICE', r) > 0) and (pos('!', r) = 0) and (pos('NOTICE:', r) = 0) then delete(r, 1, pos('NOTICE',r) + length('NOTICE'));
     //if (pos(nick + ' ', r) > 0) and ( (pos('!', r) > (pos(':', r))) ) then
        for m:= 0 to 2 do delete(bak, 1, pos(' ', bak));
        //if (r <> '') then ShowMessage('bak ' + bak);
     if pos(':', r) > 0 then
        //delete(r, 1, pos(nick, r) + length(nick));
        if (pos(':', bak) > 0) then mess:= bak else mess:= r;

     // if IP has :
     if (pos('PRIVMSG #', mess) > 0) and (pos(':', mess) < pos('PRIVMSG #', mess)) then while (pos(':', mess) > 0) do delete(mess, 1, pos(':', mess)) else


     // Cleaning message
        if (pos(':',mess) = 1) then (delete(mess, 1, pos(':', mess))) else
           if (pos('005', r) > 0) then
           //for s:= 0 to 2 do delete(mess, 1, pos(':' , mess)) else (delete(mess, 1, pos(':', mess)));

        {if (pos('PRIVMSG',mess) = 0) or (pos('PRIVMSG:', mess) > 0) or (pos('PART:', mess) > 0) or (pos('QUIT:', mess) > 0) then}
        while (pos(':', mess) > 0) do delete(mess, 1, pos(':', mess)) else if (pos(':', mess) > 0) then (delete(mess, 1, pos(':', mess)));
         // hola :no way
         //if (r <> '') and (assigned(m0[1])) then ShowMessage(tmp + sLineBreak + r + sLineBreak + mess);

     // Deleting message from r to make it clean
     if ( (pos('m:', r) = 0) and (pos('m:', r) < (pos(':', r))) ) then
     delete(r, pos(':' + mess, r), length(mess)+1);

     // Getting Server and Channel
     //if emotd = true then begin
     {
     if pos('McClane', r) > 0 then ShowMessage(r);
     delete(cname, pos(':', cname)-1, length(cname));
     if (pos('PRIVMSG',r) > 0) and (pos('!', r) > 0) then begin
        cname:= copy(r, 1, pos('!',r)-1);
     end else
     }

     //if (pos('JOIN', r) > 0) then ShowMessage(m0[n].nnick);
     //r:= 'irc-can.icq-chat.com MODE StrangerKev -x';

     if (pos(nick + '!', r) > 0) and (pos('JOIN', r) > 0)  then s:= 1;
     //if (pos('328', r) > 0)  then s:= 1;
     if (pos('NICK ', r) > 0) and (pos('!', r) > 0) then s:= 2;
     if (pos('PRIVMSG ', r) > 0) and (pos('@', r) > 0) then s:= 3;
     //if (pos(copy(r, 2, pos('!', r) -1), r) = 0) and
     if (pos(nick, copy(r, 1, pos('!',r)-1)) > 0) and ( (pos('PART ', r) > 0) or (pos('461', r) > 0) ) and (pos('PART:', r) = 0) then s:= 4;
     if (pos(nick, copy(r, 1, pos('!',r)-1)) = 0) and ((pos('JOIN', r) > 0) or (pos('PART', r) > 0) or (pos('QUIT', r) > 0)) and (pos('PART:', r) = 0) then s:= 5;
     if (pos('311 ' + nick, r) > 0) or (pos('352 ' + nick, r) > 0) then s:= 6; // Whois
     if (pos('NOTICE ', r) > 0) and (pos('NOTICE:', r) = 0) and (pos('!', r) > 0) then s:= 7;
     //if (pos('QUERY', r) > 0) and (pos(nick, r) > 0) then s:= 7;
     //if fmainc.TreeView1.Items[n].HasChildren then
     //if (pos('#', r) > 0) and (pos('MODE', r) > 0) and (pos('MODES',r) = 0) then s:= 8;
     //if assigned(m0[1]) then ShowMessage(r);
     if (pos('TOPIC #', tmp) > 0) or (pos('331 ' + nick, tmp) > 0) or (pos('332 ' + nick, tmp) > 0) or (pos('333 ' + nick, tmp) > 0) then s:= 8;
     if (pos('INVITE',r) > 0) or (pos('341', r) > 0) then s:= 9;
     if ( (pos('MODES',r) = 0) and (pos('MODE', r) > 0) ) or ( (pos('KICK ',r) > 0) and (pos('=', r) = 0) ) then s:= 10;
     if (pos('367 ' + nick, r) > 0) then s:= 11;
     //if (pos('#', r) > 0) and (pos(nick, r) > 0) and (pos('=', r) = 0) then s:= 12; // Messages

     //if (assigned(m0[1])) then if s > 0 then ShowMessage(r);

                    // TEST
                    //IF not (r = '') THEN fmainc.Label1.Caption:= inttostr(s);
                    //if s=10 then s:= 0;

                    // Sending to test file
                    //if (pos('magic', lowercase(r)) > 0) or (pos('Goofus', lowercase(r)) > 0) then begin
                    if r <> '' then begin
                       assignfile(test, '/home/nor/Lazarus/n-chat3/enchat synedit.nix/logs/bugs.txt');
                       if not FileExists('/home/nor/Lazarus/n-chat3/enchat synedit.nix/logs/bugs.txt') then Rewrite(t) else Append(test);
                       writeln(test, r + sLineBreak + mess);
                       CloseFile(test);
                    end;

     //if (assigned(m0[2])) and (pos('ART', r) > 0) then ShowMessage('n: ' + inttostr(n) + ' r: ' + r);
     if (pos('#', r) > 0) or (pos('#', mess) > 0) then begin
     //if (pos('#', r) < pos(':', r)) then
        //if (pos(':', r) > 0) then
        //   cname:= copy(r, pos(':', r)+1, length(r)) else
        if pos('#', r) > 0 then cname:= r else cname:= mess;
           cname:= StringReplace(cname, ':', ' ', [rfReplaceAll]);
        while (pos('#', cname) > 1) do delete(cname, 1, pos(' ', cname));

     if cname <> '' then
     delete(cname, pos(' ', cname), length(cname));
     cname:= inttostr(num) + cname;
     end;

     if cname = '' then cname:= inttostr(num) + server;

     // Getting Tree bounds
     n:= 0;
     //fmainc.Label1.Caption:= 'num ' + inttostr(num);
     while (fmainc.TreeView1.Items[n].Index < num) do begin
           //fmainc.label1.Caption:= fmainc.TreeView1.Items[n].Text;
           if (fmainc.TreeView1.Items[n].GetNextSibling <> nil) then
           n:= fmainc.TreeView1.Items[n].GetNextSibling.AbsoluteIndex;
           //while (n <> m0[n].node) do inc(n);
     end;
     m:= -1;

     //if s = 5 then ShowMessage('0 ' + inttostr(n));
     if fmainc.TreeView1.Items[n].HasChildren then m:= fmainc.TreeView1.Items[n].GetLastChild.AbsoluteIndex;

     {m:= fmainc.cnode(5, m, 0, '');
     n:= fmainc.cnode(5,n,0,'');
     }

     {
     // Getting the right memo
     if fmainc.TreeView1.Items[n].HasChildren then
        if (cname <> '') then
        if (pos('JOIN',r) = 0) then
           n:= fmainc.cnode(2,0,0, cname);
      }

     {
     if (pos('PART', r) > 0) then begin
        ShowMessage(r + sLineBreak + mess);
        n:= fmainc.cnode(2,0,0, inttostr(num) + server);
     end;
     }
     //if (mess = 'You left') then ShowMessage(mess);
     //if cname <> '' then while (not assigned(m0[n])) do inc(n);
     //if (assigned(m0[1])) and (pos('MODE', r) > 0) then ShowMessage(r + mess);

case s of
     0: Begin // MOTD

        if (r <> '') or (mess <> '') then begin
           fmainc.Timer1.Interval:= 50;
           fast:= true;
        end else begin
        //if (mess <> '') then fmainc.Timer1.Interval:= 50 else
             fmainc.Timer1.Interval:= 2000;
             fast:= false;
        end;

        if (r <> '') or (mess <> '') then begin

        n:= fmainc.cnode(5,n,0,'');
        //ShowMessage('0 ' + inttostr(n) + sLineBreak + inttostr(m));

        // Searching channel
        if (pos('#', cname) > 0) then begin
           //if (assigned(m0[1])) then ShowMessage(r + sLineBreak + mess);
           m:= fmainc.cnode(2,0,0,cname);
           if (m >= 0) then if (assigned(m0[m])) then n:= m;
           //ShowMessage('0: ' + inttostr(n));
        end;

        // Deleting 1 to nick from r
        for m:= 0 to 2 do delete(r, 1, pos(' ', r));

        fmainc.createlog(num, server); //file open on connect

        if (pos('NOTICE', r) > 0) and ( (pos('*', r) > 0) or (pos('auth', lowercase(r)) > 0) ) then r:= '';

        r:= r + mess;
        if (r <> '') then output(clnone, r, n);

        //if (pos('End of', r) > 0) then begin fmainc.Timer1.Interval:= 2000;
           closefile(t);
        end;
     end;

     1: Begin // Join
       // Create room tab
       if (pos('#', cname) = 0) then cname:= mess;
       //ShowMessage('J: '+ inttostr(n) + sLineBreak + inttostr(m) + sLineBreak + cname);
       x1:= n;

       // Searching for created room
       //n = Initial node
       if (fmainc.TreeView1.Items[n].HasChildren) then
          while (x1 <= m) do begin
                if ('(' + copy(cname, length(inttostr(num))+1, length(cname)) + ')' = fmainc.TreeView1.Items[x1].Text) then begin
                   room:= true;
                   fmainc.TreeView1.Items[x1].Text:= StringReplace(fmainc.TreeView1.Items[x1].Text, '(', '', [rfReplaceAll]);
                   fmainc.TreeView1.Items[x1].Text:= StringReplace(fmainc.TreeView1.Items[x1].Text, ')', '', [rfReplaceAll]);
                end;
       inc(x1);
       end;

       if room = false then
       fmainc.txp(num, copy(cname, pos('#', cname), length(cname)), nick, false, false, true);

       //chan[fmainc.TreeView1.Selected.AbsoluteIndex]:= server + '_' + copy(r, pos('#', r), length(r));

       // Getting the right memo
       //ShowMessage('hoa cname: ' + inttostr(n) + ' cname ' + cname + ' r: ' + r);
       n:= fmainc.cnode(2,0,0, cname);
       //ShowMessage('hoa cname: ' + inttostr(n) + ' ' + cname + ' r: ' + r);

       //m0[n].Canvas.Pen.Color:= clred;
       //m0[n].Canvas.Line(0,m0[n].CaretY, m0[n].Width,m0[n].CaretY);

       fmainc.createlog(num, copy(cname, length(inttostr(num))+1, length(cname)));

       fmainc.Timer1.Enabled:= false;
       repeat
        r:= '';
        r:= conn.recvstring(1000);
        //ShowMessage(r + sLineBreak + mess);
        //ShowMessage('cname: ' + cname + sLineBreak + ' r: ' +r + sLineBreak + mess);
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
        if (pos('353 ' + nick, r) > 0) or (pos('366 ' + nick, r) > 0) then begin // and (pos('/NAMES', r) = 0) do begin
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

        // MODES
        if (pos('MODE', r) > 0) and (pos(nick, r) > 0) then begin
        if (pos('+', r) > 0) then
           mess:= copy(r, pos('+', r), length(r)) else
           mess:= copy(r, pos('-v', r), length(r));

        output(clnone, copy(r, 2, pos('!', r) -2) + ' sets mode ' + mess, n);
        //output(clgreen, r, n);
        if pos('+v',mess) > 0 then fmainc.lbchange(m0[n].nnick, '+', 3, n, num+1);
        if pos('-v',mess) > 0 then fmainc.lbchange(m0[n].nnick, '+', 4, n, num+1);
        end;

        // SERVICES
        if (pos('NOTICE', uppercase(r)) > 0) or (pos('service', lowercase(r)) > 0) then begin
           delete(r, 1, pos(':', r));
           delete(r, 1, pos(':', r));
           output(clgreen, r, n);
        end;

        end; // Empty

        until (pos('/NAMES', r) > 0);
        output(clnone, #13, n);

        fmainc.timer1.Enabled:= true;
        CloseFile(t);

        //m0[n].Lines.LoadFromFile(log[n]);
    n:= 1;
    end; // JOIN

    2: Begin // nick
       // Sollo!~Sollo@181.31.118.135 NICK :collo
       //ShowMessage(cname + sLineBreak + sLineBreak +r + sLineBreak + sLineBreak + mess + sLineBreak + 'no ' + nick);
       //ShowMessage('r: ' + r + sLineBreak + 'mess: ' + mess + sLineBreak + 'old: ' + nick + sLineBreak + 'con: ' + inttostr(num));

             if (pos('nickname already in use', r) > 0) then output(clblack, r, n) else

             if (mess = '') then mess:= copy(r, pos('NICK', r) + length('nick')+1, length(r));

             if (pos(nick, r) > 0) then
                cname:= 'You are now known as ' + mess
             else
                 cname:= copy(r, 1, pos('!', r)-1) + ' is now known as ' + mess;

       if (pos('You', cname) = 1) then begin
          net[fmainc.TreeView1.Items[n].Index +1].nick:= mess;
          //output(clBlack, cname, fmainc.cnode(5,n,0,''));
          //ShowMessage(inttostr(n) + sLineBreak + nick);
       end;

             while (n <= m) do begin
                   s:= fmainc.cnode(5,n,0,'');
                   //while (n <> chanod[s].node) do inc(s);
                   //s:= strtoint(copy(m0[s].Name, pos('_', m0[s].Name)+1, length(m0[s].Name)));
                   // Changing nick in tree

                if fmainc.TreeView1.Items[n].Text = copy(r, 1, pos('!', r)-1) then begin
                   fmainc.TreeView1.Items[n].Text := mess;
                   fmainc.cnode(9,0,0, m0[s].chan + '/' + inttostr(num) + mess);
                   m0[s].chan:= inttostr(num) + mess;
                end;


                   fmainc.createlog(num, copy(m0[s].chan, length(inttostr(num))+1,length(m0[s].chan)));

                    if (pos('You', cname) = 1) then begin
                       m0[s].nnick:= mess;
                       output(clBlack, cname, s);
                    end;

                   if assigned(lb0[s]) then begin

                   if (fmainc.srchnick(copy(r, 1, pos('!', r)-1), 0, s)  = 'true') then begin
                   if mess <> '' then
                   //fmainc.lbchange(copy(r, 1, pos('!', r)-1), copy(r, pos('NICK', r)+6, length(r)), 2, n, num+1) else
                   //fmainc.lbchange(copy(r, 1, pos('!', r)-1), copy(r, pos('NICK', r)+5, length(r)), 2, n, num+1);

                   fmainc.lbchange(copy(r, 1, pos('!', r)-1), mess, 2, s, num+1) else
                   fmainc.lbchange(copy(r, 1, pos('!', r)-1), copy(r, pos('NICK', r) + Length('nick ')+1, length(r)), 2, s, num+1);

                   //ShowMessage(gnicks(fmainc.TreeView1.Items[1].Text));

                   if pos('You',cname) = 0 then
                      output(clBlack, cname, s);
                   //m0[n].lines.LoadFromFile(log[n]);
                   end;

             end;
             CloseFile(t);
             inc(n);
             end; // lb0[n]
    n:= 1;
    end; // 2

    3: Begin // PRIVMSG
       //r:= tmp;
       // priv McClane!~JMcClane@17-122-17-190.fibertel.com.ar PRIVMSG #nvz :hola
       //ShowMessage(lb0[1].Items[0]);

    // Getting channel
       cname:= r;
       if (pos('#', cname) > 0) then begin
          cname:= copy(cname, pos('#', cname), length(cname));
          delete(cname, pos(' ',cname), length(cname));
       end;


    // Getting channel
          if (pos('#', r) = 0) or (pos('#', r) < pos('!', r)) then
             cname:= copy(r, 1, pos('!', r)-1); // else

          //ShowMessage('3 ' + inttostr(n) + sLineBreak + inttostr(m));
          //if cname = '' then ShowMessage('WARNING cname is null ' + cname + '_');
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
          //ShowMessage('cname: ' + cname + ' chan: ' + m0[n].chan + sLineBreak + inttostr(n) + ' ' + inttostr(m));

          if (pos('#', cname) = 0) then begin
          if fmainc.TreeView1.Items.Count > 1 then
          while (lowercase(fmainc.TreeView1.Items.Item[n].Text) <> lowercase(cname)) and (n < m) do inc(n);
                //ShowMessage(fmainc.TreeView1.Items.Item[s].Text);
                if (lowercase(fmainc.TreeView1.Items.Item[n].Text) <> lowercase(cname)) then begin
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

      //if (pos('#',cname) = 0) then
      //cname:= inttostr(num) + cname;

      // Getting the right memo
      n:= fmainc.cnode(2,0,0, inttostr(num) + cname);
      //ShowMessage(inttostr(num) + cname);

      //delete(cname, 1, 1);
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
      if (pos(lowercase(nick), lowercase(mess)) = 0) then // and (copy(r, 1, pos(':', r) -1) <> '') then
         output(clNone, mess, n) else output(clred, mess, n);

      //if pos('reinadrama', lowercase(mess)) > 0 then writeln(t, mess);
      CloseFile(t);

      //if (pos(nick,r) > 0) then rc:= n; // Cuidado!!!
      //if (pos(nick,copy(r,1,pos('!',r)-1)) = 0) then rc:= n;
      //until (n = fmainc.TreeView1.Items.Count);
      //end;

    end; // 3

    4: Begin // I PART
       //Searching Parent
       //m:= strtoint( copy(cname, 1, pos('#', cname)-1) );
                         //ShowMessage(nick + sLineBreak+ r);
       n:= 0;
       while (fmainc.TreeView1.Items[n].Index < num) do begin
             //ShowMessage(fmainc.TreeView1.Items[n].Text);
             if (fmainc.TreeView1.Items[n].GetNextSibling <> nil) then
             n:= fmainc.TreeView1.Items[n].GetNextSibling.AbsoluteIndex;
             //while (n <> m0[n].node) do inc(n);
       end;
       //n:= fmainc.TreeView1.Items[n].Index;
       m:= -1;

       //n:= fmainc.cnode(2,0,0, inttostr(num) + fmainc.TreeView1.Selected.Text);
       //ShowMessage('n' + inttostr(n));

       if fmainc.TreeView1.Items[n].HasChildren then
       for s:= n to fmainc.TreeView1.Items[n].GetLastChild.AbsoluteIndex do begin
             if (fmainc.TreeView1.Items[s].Text = copy(cname, length(inttostr((num)))+1, length(cname))) then begin
             fmainc.TreeView1.Items[s].Text:= '(' + fmainc.TreeView1.Items[s].Text + ')';
             m:= s;
             end;
       end;
       if m = s then m:= fmainc.cnode(5, m, 0, '');
       n:= fmainc.cnode(5,n,0,'');

       //ShowMessage('4: ' + inttostr(n) + sLineBreak + inttostr(num) + server);
       //if assigned(m0[m]) then ShowMessage('m2: ' + inttostr(m));

       if (m >= 0) then n:= m;
       //ShowMessage('n' + inttostr(n)); // ?

       fmainc.createlog(num, copy(cname, length(inttostr(num))+1, length(cname)));
       if mess = '' then mess:= 'Leaving';
       output(clnone, 'You have left ' + copy(cname,length(inttostr(num))+1,length(cname)) + ' :' + mess, n);

       //if (assigned(m0[2])) or (assigned(m0[3])) then ShowMessage('s ' + inttostr(m));


       if (m >= 0) then begin
          lb0[m].Clear;
          lab0[m].Caption:= '';
       end else
               fmainc.LeaveRoom(1);

    end;

    5: Begin // JOIN PART QUIT
       //5 Solloo!Sollo@AN-6BC70F2B.fibertel.com.ar PART #nvz

       if (pos('QUIT',r) = 0) then
       if cname <> '' then n:= fmainc.cnode(2,0,0, cname);
       //ShowMessage('5 ' + r + sLineBreak + cname + sLineBreak + inttostr(n));

       if (pos('QUIT', r) = 0) then begin
          fmainc.createlog(num, copy(cname, pos('#', cname), length(cname)));
          cname:= copy(r, pos('!', r)+1, pos(' ', r)-pos('!', r)); // ident + IP
          delete(cname, pos(' ', cname), length(cname));
       end;

       cname:= r;
       delete(cname, 1, pos('!', cname));
       delete(cname,  pos(' ', cname), length(cname));

       if pos('JOIN', r) > 0 then begin
          //ShowMessage('JOIN ?' + inttostr(n) + ' r: ' + r + ' mess: ' + mess + ' cname: ' + cname);
          if fsett.chg1.Checked[0] then
          output(clgreen, copy(r, 1, pos('!', r)-1) + ' (' + cname + ')' + ' has joined ' +
          copy(m0[n].chan, 2, length(m0[n].chan)), n);
       end;

       if (pos('PART', r) > 0) then begin
       if fsett.chg1.Checked[0] then
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

          while (n <= m) do begin
                s:= fmainc.cnode(5, n, 0, '');

                if (fmainc.TreeView1.Items[n].Text = copy(r, 1, pos('!', r)-1)) or
                   ( (assigned(lb0[s])) and
                   (fmainc.srchnick(copy(r, 1, pos('!', r)-1), 0, s) = 'true') ) then begin

                //ShowMessage('true ' + inttostr(s));
                fmainc.createlog(num, copy(m0[s].chan, pos('#', m0[s].chan), length(m0[s].chan)));

                //ShowMessage('quit nor_' + mess);
                if fsett.chg1.Checked[0] then

                if length(mess) > 0 then
                   output(clmaroon, copy(r, 1, pos('!', r) -1) + ' (' + cname + ') has quit (' + mess + ')', s) else
                                  output(clmaroon, copy(r, 1, pos('!', r) -1) + ' (' + cname + ') has quit', s);

                //gnicks(chan[n]);
                //lb0[n].Clear;
                if (assigned(lb0[n])) then
                fmainc.lbchange(copy(r, 1, pos('!', r)-1), '', 1, s, num+1);
                closefile(t);
                //m0[n].lines.LoadFromFile(log[n]);
                end;

          inc(n);
          end;

    n:= 1;
    end; // 4

    6: Begin // WHOIS
       n:= fmainc.cnode(5, n, 0, '');

       if (pos('352',r) > 0) then // who
       repeat
       {
             cname:= r + mess;
             for m:= 1 to 4 do delete(cname, 1, pos(' ' , cname));

             for m:= 1 to 5 do begin
                 if (m = 5) then begin
                    delete(cname, 1, pos(' ' , cname));
                    delete(cname, 1, pos(' ' , cname));
                 end;
                 tmp:= cname;

                 if m=1 then tmp:= 'Ident: ' + copy(cname, 1, pos(' ' , cname)-1);
                 if m=2 then tmp:= 'IP: ' + copy(cname, 1, pos(' ' , cname)-1);
                 if m=3 then tmp:= 'Server: ' + copy(cname, 1, pos(' ' , cname)-1);
                 if m=4 then tmp:= 'Nick: ' + copy(cname, 1, pos(' ' , cname)-1);
                 if m=5 then tmp:= 'Real name: ' + copy(cname, 1, length(cname));

                 // File and output
                 fmainc.createlog(num, fmainc.TreeView1.Items[n].Text);
                 //if (tmp <> '') then output(clnone, tmp, n);
                 tmp:= '';
                 closefile(t);
             delete(cname, 1, pos(' ' , cname));

             r:= conn.RecvString(100);
             end;
             }

             if r <> '' then begin
                //ShowMessage(r + sLineBreak + mess);
                delete(r, 1, pos('*', r)-1);
                if (pos(':', r) = 0) then r:= r + mess;
                r:= StringReplace(r, ':', '', [rfReplaceAll]);
             // File and output
                fmainc.createlog(num, fmainc.TreeView1.Items[n].Text);
                output(clnone, r, n);
                closefile(t);
             end;
             r:= conn.RecvString(100);
             until (pos('WHO', r) > 0);

       if (pos('311',r) > 0) then
       while (pos('WHOIS',r) = 0) and (r <> '') do begin
             cname:= r;

             for m:= 0 to 2 do delete(cname, 1, pos(' ',cname));
             tmp:= '[' + copy(cname, 1, pos(' ', cname)-1) + '] ';
             if (pos(':', cname) > 0) then delete(cname, pos(':', cname), length(cname));
             if (pos('330', r) = 0) then delete(cname, 1, pos(' ', cname));

             if (pos('311',r) > 0) then
                cname:= tmp + cname + 'Real name: ' + mess else
             if (pos('319',r) > 0) then
                cname:= tmp + 'channels: ' + mess;
             if (pos('312',r) > 0) then
                cname:= tmp + 'server: ' + cname + mess;
             if (pos('378',r) > 0) then
                cname:= tmp + mess;
             if (pos('317',r) > 0) and (cname <> '') then begin
                //delete(cname, 1, pos(' ' ,cname));
                delete(cname, pos(':',cname)-1, length(cname));
                cname:= tmp + 'seconds idle: ' + copy(cname, 1, pos(' ',cname)) + 'signon time: ' + DateTimeToStr( UnixToDateTime( StrToInt( copy(cname, pos(' ',cname)+1, length(cname)-pos(' ',cname)-1) )));
             end;
             if (pos('330',r) > 0) then
                cname:= tmp + mess + ' ' + copy(cname, pos(' ',cname)+1, length(cname));

             // File and output
             fmainc.createlog(num, fmainc.TreeView1.Items[n].Text);
             if (cname <> '') then output(clnone, cname, n);
             closefile(t);

             cname:= ''; r:= '';
             while (r = '') do r:= conn.RecvString(100); if r <> '' then delete(r, 1, 1);
             mess:= copy(r, pos(':', r)+1, length(r));
       end;
    end;


    7: Begin // NOTICE

       i:= ticon.Create;
       i.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'trayblue.ico');

       // Using cname as sender
       cname:= copy(r, 1, pos('!',r)-1); // Author
       if (pos('::', mess) > 0) then
          while (pos(':', mess) > 0) do delete(mess, 1, pos(' ', mess));

       // num is Connection number/name. Searching Parent for connexion in the tree
       n:= 0;
       while (fmainc.TreeView1.Items[n].Index < num) do
             n:= fmainc.TreeView1.items[n].GetNextSibling.AbsoluteIndex;
             if fmainc.TreeView1.Items[n].HasChildren then
                s:= fmainc.TreeView1.Items[n].GetLastChild.AbsoluteIndex else s:= n;
       m:= n;  // Saving node

       // If the active room belongs to the connection then send the notice there
       if (fmainc.TreeView1.Selected.Parent <> nil) then
       if (fmainc.TreeView1.Selected.Parent.AbsoluteIndex = n) then m:= fmainc.TreeView1.Selected.AbsoluteIndex else
       if (fmainc.TreeView1.Selected.AbsoluteIndex = n) then m:= fmainc.TreeView1.Selected.AbsoluteIndex;

       // Searching for private message to send notice
       while (n <= s) do begin
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
       //if not (fmainc.Notebook1.page[m].IsVisible) then
       fmainc.TrayIcon1.Icon:= i;
       //m0[TreeView1.Selected.AbsoluteIndex].lines.Add(log[TreeView1.Selected.AbsoluteIndex]);
    end;


    8: Begin // TOPIC
       n:= fmainc.cnode(2,0,0, cname);
       cname:= copy(cname, pos('#', cname), length(cname));
       r:= copy(r, 1, pos('!', tmp)-1); // User

       //ShowMessage('8 Topic: ' + tmp + ' /' + r + ' m: ' + mess + ' n ' + inttostr(n));

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
       if mess = '' then
       r:= 'The topic has been removed' else
       r:= r + ' has changed the topic to: ' + mess;

       fmainc.createlog(num, copy(m0[n].chan, pos('#', m0[n].chan), length(m0[n].chan)));

       if (pos('332', tmp) > 0) or (pos('333', tmp) > 0) then
          output(clPurple, r, n) else
          output(clnone, r, n);
       closefile(t);
    end;     // TOPIC

    9: Begin // INVITE
       if (pos('#', r) > 0) then // Spotchat puts the channel after : (colon)
          cname:= copy(r, pos('#', r), length(r)) else cname:= copy(mess, pos('#', mess), length(mess));

       // :server sollo mcclane chan
       //ShowMessage(cname + sLineBreak + r + sLineBreak + mess);

       if (pos('!', r) > 0) then
       mess:= 'You have been invited to ' + cname + ' by ' + copy(r, 1, pos('!', r)-1) + ' (' + server + ')' else begin

              delete(r, 1, pos(' ', r)); delete(r, 1, pos(' ', r)); delete(r, 1, pos(' ', r));

          mess:= 'You have invited ' + copy(r, 1, pos(' ', r)-1) + ' to ' + cname +
                 ' (' + server + ')';
       end;

       fmainc.createlog(num, copy(m0[n].chan, pos('#', m0[n].chan), length(m0[n].chan)));
       output(clGreen, mess ,n);
       closefile(t);
    end;


    10: Begin // MODE
       fmainc.Timer1.Interval:= 50;
       //ShowMessage('mess ' + r);
       // Getting user
          // mcclane!* MODE user +i
          //irc-can.icq-chat.com MODE StrangerKev -x

       tmp:= r;

          bak:= r;
          while (pos(' ', bak) > 0) do delete(bak, 1, pos(' ', bak));
       delete(r, length(r) - length(bak), length(bak)+1);
       //ShowMessage(r + '_' + sLineBreak + bak);

       if r[length(r)] = ' ' then delete(r, length(r), 1);
       while (tmp[length(tmp)] = ' ') do delete(tmp, length(tmp), 1);
       delete(tmp, 1, pos('MODE', tmp) + 4);
       while (pos(' ', tmp) > 0) do delete(tmp, 1, pos(' ', tmp));

       //if fmainc.TreeView1.Items[n].HasChildren then
       tmp:= bak;

       if cname <> '' then n:= fmainc.cnode(2, 0,0, cname);
       fmainc.createlog(num, copy(m0[n].chan, length(inttostr(num))+1, length(m0[n].chan)));

       // Kick
       if (pos('KICK',r) > 0) then begin

          tmp:= r;
          delete(tmp, 1, pos('#', tmp));
          delete(tmp, 1, pos(' ', tmp)); // User
          if tmp[length(tmp)] = ' ' then
             delete(tmp, pos(' ', tmp), Length(tmp));
          delete(tmp, pos(':',tmp)-1, length(tmp));

          r:= copy(r, 1, pos('!' ,r)-1); // Kicker

          mess:= tmp + ' has been kicked from ' + copy(cname, 2, length(cname)) + ' by ' + r + ' (' + mess + ')';

          if (pos(nick, tmp) = 1) then begin
             mess:= StringReplace(mess, tmp, 'You', [rfReplaceAll]);
             //if (pos('#', r) > 0) then
             while (m < fmainc.TreeView1.Items.Count) do begin
                   if (fmainc.TreeView1.Items[m].Text = copy(cname, 2, length(cname))) then fmainc.TreeView1.Items[m].Text:=
                      '(' + fmainc.TreeView1.Items[m].Text + ')';
             inc(m);
             end;
          end;

          r:= copy(r, 1, pos('!' ,r)-1); // Kicker

          output(clred, mess, n);

          // Updating nick list
          if not (tmp = nick) then
             fmainc.lbchange(tmp, tmp, 1, n, num+1) else
             if assigned(lb0[n]) then lb0[n].Clear;
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
          (pos('+v',r) > 0) or (pos('-v', r) > 0) or
          (pos('+h',r) > 0) or (pos('-h', r) > 0) or
          (pos('+q',r) > 0) or (pos('-q', r) > 0) or
          (pos('+a',r) > 0) or (pos('-a', r) > 0)

          then begin

          if (pos('+', r) > 0) then
             mess:= ' gives ' else mess:= ' removes ';

          if (pos('+o', r) > 0) or (pos('-o', r) > 0) then
             if mess = ' removes ' then
                mess:= mess + 'channel operator status from ' else
                   mess:= mess + 'channel operator status to ';

          if (pos('+h', r) > 0) or (pos('-h', r) > 0) then
             if mess = ' removes ' then
                mess:= mess + 'channel half-operator status from ' else
                      mess:= mess + 'channel half-operator status to ';

          if (pos('+q', r) > 0) or (pos('-q', r) > 0) then
             if mess = ' removes ' then
                mess:= mess + 'channel owner status from ' else
                       mess:= mess + 'channel owner status to ';

          if (pos('+a', r) > 0) or (pos('-a', r) > 0) then
             if mess = ' removes ' then
                mess:= mess + 'channel admin operator status from ' else
                       mess:= mess + 'channel admin operator status to ';

          if (pos('+v', r) > 0) or (pos('-v', r) > 0) then
             if mess = ' removes ' then
                mess:= mess + 'voice from ' else mess:= mess + 'voice to ';

          r:= copy(r, 1, pos('!' ,r)-1); // Kicker
          mess:= r + mess + tmp;

          output(clgreen, mess, n);

       end else            // Ban

       if (pos('+b',r) > 0) or (pos('-b',r) > 0) then begin
                    //ShowMessage(r + sLineBreak + mess);
          if (pos('+', r) > 0) then
             mess:= ' sets ' else mess:= ' removes ';
             if mess = ' sets ' then
             mess:= mess + 'ban on ' else mess:= mess + 'ban from ';

             r:= copy(r, 1, pos('!' ,r)-1); // Kicker
             mess:= r + mess + tmp;

             output(clMaroon, mess, n);

       end else begin // Any channel mode or user mode

       //ShowMessage(r +sLineBreak + 'tmp: ' + tmp + sLineBreak + 'mess: ' + mess + sLineBreak + 'cname: ' + cname);
       //irc-can.icq-chat.com MODE StrangerKev -x
       //ShowMessage(r + sLineBreak + mess);
       //r:= r + ' ' + mess;

       {
       //tmp:= r;
       // Making tmp = nick
       if (pos('!', r) > 0) then
       tmp:= copy(r, 1, pos('!', r)-1) else begin
                                               tmp:= r;
                                               delete(tmp, 1, pos('MODE ', tmp)+4);
                                               delete(tmp, pos(' ', tmp), length(tmp));
                                               end;
       }
       //ShowMessage('r: ' + r);

       if (pos('+',r) > 0) or (pos('-',r) > 0) or (pos('mode', lowercase(r)) > 0) then begin
          if (pos('+',mess) = 0) and (pos('-',mess) = 0) then mess:= tmp;
          while (mess[length(mess)] = ' ') do delete(mess, length(mess), 1);
          while (pos(' ', mess) > 0) do delete(mess, 1, pos(' ', mess));
          //ShowMessage(r +sLineBreak+ mess);
          if (pos('+', mess) = 0) and (pos('-', mess) = 0) then begin
          delete(mess, 1, pos('#',mess));
          delete(mess, 1, pos(' ',mess));
          delete(mess, pos(' ',mess), length(mess));
          end;

          if (pos('!', r) = 0) then tmp:= copy(r, pos('mode', lowercase(r))+5, length(r)) else
             tmp:= copy(r, 1, pos('!', r)-1);

          if (pos('#', r) > 0) then
             mess:= tmp + ' sets mode ' + mess + ' to ' + copy(cname, 2, length(cname)) else
             mess:= tmp + ' sets mode ' + mess + ' to ' + tmp;
                                              //ShowMessage(r +sLineBreak+ mess);
             //r:= copy(r, 1, pos('!' ,r)-1); // Kicker

             output(clMaroon, mess, n);
       end;
       end;

       // Updating nick list
       if (pos('gives',mess) > 0) or (pos('removes',mess) > 0) then begin
                               //ShowMessage('lb ' + r + sLineBreak + tmp);
       if (pos('gives',mess) > 0) and (pos('voice',mess) > 0) then fmainc.lbchange(tmp, '+', 3, n, num+1);
       //if (pos('gives',mess) > 0) and (pos('voice',mess) > 0) then gnicks(copy(cname, 2, length(cname)));
       if (pos('removes',mess) > 0) and (pos('voice',mess) > 0) then fmainc.lbchange(tmp, '+', 4, n, num+1);

       if (pos('gives',mess) > 0) and (pos('half', mess) = 0) and (pos('operator',mess) > 0) then fmainc.lbchange(tmp, '@', 3, n, num+1);
       if (pos('removes',mess) > 0) and (pos('half', mess) = 0) and (pos('operator',mess) > 0) then fmainc.lbchange(tmp, '@', 4, n, num+1);

       if (pos('gives',mess) > 0) and (pos('half-operator',mess) > 0) then fmainc.lbchange(tmp, '%', 3, n, num+1);
       if (pos('removes',mess) > 0) and (pos('half-operator',mess) > 0) then fmainc.lbchange(tmp, '%', 4, n, num+1);

       // Channel owner
       if (pos('+q',mess) > 0) then fmainc.lbchange(tmp, '~', 3, n, num+1);
       if (pos('-q',mess) > 0) then fmainc.lbchange(tmp, '~', 4, n, num+1);

       // Half operator
       if (pos('+h',mess) > 0) then fmainc.lbchange(tmp, '%', 3, n, num+1);
       if (pos('-h',mess) > 0) then fmainc.lbchange(tmp, '%', 4, n, num+1);

       // Channel Admin
       if (pos('+a',mess) > 0) then fmainc.lbchange(tmp, '&', 3, n, num+1);
       if (pos('-a',mess) > 0) then fmainc.lbchange(tmp, '&', 4, n, num+1);
       end;

       CloseFile(t);
       end;

    11: Begin // Banlist
        output(clnone, copy(cname, 2, length(cname)) + ' Banlist' ,n);
        repeat
         if not (r = '') then begin
            while (pos(copy(cname, 2, length(cname)), r) > 0) do delete(r, 1, pos(' ', r));
            tmp:= r; while (pos(' ', tmp) > 0) do delete(tmp, 1, pos(' ', tmp));
            delete(r, pos(tmp, r), length(tmp));
            tmp:= FormatDateTime('mmm ddd d YYYY hh:mm:ss', UnixToDateTime(strtoint(tmp)) );
            output(clnone, tmp + ' ' + r ,n);
         end;

        r:= '';
        r:= conn.recvstring(500);
        until pos('368',r) > 0;
        output(clnone, 'End of ' + copy(cname, 2, length(cname)) + ' Banlist' ,n);
    end;

    12: Begin // Messages to channel
        //ShowMessage(r + ' ' + mess);
        n:= fmainc.cnode(2,0,0, copy(cname, length(inttostr(num))+1, length(cname)));
            output(clnone, mess ,n);
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
     //orwell.freenode.net 333 Sollo #nvz McClane!~JMcClane@17-122-17-190.fibertel.com.ar 1521126049


        delete (r, 1, pos('#', r)-1);
        delete (r, 1, pos(' ', r));
     if (pos('!', r) = 0) then
        s:= copy(r, 1, pos(' ', r)-1) else s:= copy(r, 1, pos('!', r)-1);

     while (r[length(r)] = ' ') do delete(r, length(r), 1);
     while (pos(' ', r) > 0) do delete(r, 1, pos(' ', r));

           d:= UnixToDateTime(StrToInt(r));

     r:= 'Topic set by ' + s + ' at ' +
         FormatDateTime('DDDD DD, MMMM YYYY, hh:mm:ss', d) ;

     result:= r;
end;

procedure connex.output(c: TColor; r: string; o: smallint);
var l:    smallint;
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
        r:= 'Jupiter8: ' + char(3) + '12hey Sherbet - :)' + char(3)+1;
        r:= char(3) + '4' + char(2) + '2018 minus 3 days away If you have anyone that cant join #Chat because of our modes.. please tell him to register his/her nickname and its gonna be fine :D :P For help come to #helpcome to #helpcome to #helpcome to #helpcome to #helpcome to #helpcome to #helpcome to #help';
        //r:= 'magic dragon: ' + char(3) + '7' + char(3) + '5' + char(2) + 'R' + char(2) + char(3) + '7olling ' + char(3) + '5' + char(2) + 'O' + char(2) + char(3) + '7n ' + char(3) + '5' + char(2) +  'T' + char(2) + char(3) + '7he ' + char(3) + '5' + char(2) + 'F' + char(2) + char(3) + '7loor' + char(3) + '5' + char(2) + 'L' + char(2) + char(3) + '7aughing ' + char(3) + '5' + char(2) + 'M' + char(2) + char(3) + '7y ' + char(3) + '5' + char(2) + 'A' + char(2) + char(3) + '7scii ' + char(3) + '5 ' + char(2) + 'O' + char(2) + char(3) + '7ff' + char(3) + '155';
        //r:= 'Rita: ' + char(2) + char(3) + '6,0L' + char(2) + char(3) + '12augh ' + char(2) + char(3) + '6,0O' + char(2) + char(3) + '12ut ' + char(2) + char(3) + '6,0L' + char(2) + char(3) + '12oud' + char(3);
        r:= 'Olives: Hi, ' + char(3)+ '6-' + char(3) + '6,6 ' + char(3)+ '0,0 ' + char(3) + '6,0Sherbet' + char(3) + '0,0 ' + char(3) + '6,6 ' + char(15) + char(3) + '6- ' + char(15) + char(3) + '1';
        r:= 'DJ_Tease: Now playing on #Radio: ' + char(3) + '14,1[' + char(3) + '15DJ_Tease is playing C+C Music Factory - Things That Make You Go Hmmm..' + char(3) + '14]';
        r:= 'Diane: hands colin-carpenter an ice cold ' + char(3) + '15,15' + char(3) + '14,14' + char(3)+'2,14BUD LIGHT' + char(3) + '14,14' + char(3)+ '15,15, sorry that''s all we got!';
        r:= 'TNTease: *•♪ღ♪*•.¸¸¸.•*¨¨*•.¸¸¸.•*•♪¸.•*¨¨*•.¸¸¸.•*•♪ღ♪•«';
        r:= 'TNTease: ♪ღ♪░H░A░P░P░Y░ B░I░R░T░H░D░A░Y░░♪ღ♪';
        r:= 'JustAKiss: 😀☺';
        r:= 'JustaKiss: ⛄';
        r:= char(3) + '12throws confetti & balloons all over' + char(3)+ '1 Everly ' + char(3) + '4`;~''' + char(3) + '3O' + char(3) + '8~~~*`;.' + char(3) + '12O' + char(3) + '9~~~~*`' + char(3)+ '1 Everly ' + char(3)+ '8.`~;`~`' + char(3) + '4O' + char(3) + '13~~~~*`;.' + char(3) + '6O' + char(3) + '11~~~~*`;.`~;`~`' + char(3) + '1O' + char(3) + '14~~~*`;~' + char(3) + '13O' + char(3)+ '2~~~*`;.' + char(3)+ '3O' + char(3) + '5~~~~*`'+ char(3)+ '1 Everly ' + char(3) + '9.`~;`~`' + char(3) + '12O' + char(3) + '4~~~~*`;.' + char(3) + '8O' + char(3) + '10~~~~*`;.`~;`~`' + char(3) + '11O' + char(3) + '13~~~*`;~' + char(3) + '1O' + char(3) + '4~~~*`;.' + char(3)+ '9O' + char(3)+ '2~~~~*`' + char(3) + '1 Everly ' + char(3) + '6.`~;`~`' + char(3) + '12O' + char(3)+ '13~~~~*`;.' + char(3) + '4O' + char(3) + '3~~~~*`;.`~;`~`' + char(3) + '1O' + char(3) + '13~~~*`';
        r:= char(2) + char(3) + '16,5[_]' + char(2) + char(3) + '1,16D~~ ' +char(2) + char(3) + '16,5[_]' + char(2) + char(3) + '16,5[_]' +char(2) + char(3) + '1,16D~~ ' + char(2) + char(3) + '8,5Coffee Anyone??' + char(3) + '16,16';
        r:= char(3) + '4 hangs' +char(3) + '10 a' +char(3) + '13 string' + char(3) + '2 of' +char(3) + '5 party' +char(3) + '10 lights' +char(3) + '9 out' +char(3) + '7 for' +char(3) + '9Ai.*A*.' +char(3) + '8Ai. *A*.' +char(3) + '10Ai.*A*' +char(3) + '1Capt^Goodvib es *A*.' +char(3) + '12Ai.*A*.' +char(3) + '13Ai.*A*.' +char(3) + '7Ai.*A*.' +char(3) + '4Ai.*A*.' +char(3) + '2Ai.*A*.' +char(3) + '8Ai.*A*' +char(3) + '1 Capt^Goodvibes *A*.' +char(3) + '9Ai.*A*.' +char(3) + '10Ai.*A*.' +char(3) + '13Ai.*A*.' +char(3) + '14Ai.*' +char(3) + '1 Capt^Goodvibes *.' +char(3) + '2Ai.*A*.' +char(3) + '4Ai.*A*.' +char(3) + '10Ai.*A*.' +char(3) + '7Ai.*A*.' +char(3) + '9Ai.*A*.' +char(3) + '13Ai.*A*.' +char(3) + '8Ai.*A*.' +char(3) + '2Ai.*A*.' +char(3) + '10Ai.*A*.' +char(3) + '4Ai.*A*.' +char(3) + '5Ai.*A*.' +char(3) + '8Ai.' +char(1);

     if (pos('h1', r) > 0) then begin
     //r:= char(3) + 'Hola ' + char(3) + '00,01Hola este es un texto de prueba este es un texto de prueba este es un texto de prueba este es un texto de prueba este es un texto de prueba este es un texto de prueba este es un texto de prueba';
     //r:= '< Autobot > ' + char(3) + '4Tune in via our Website: ' + char(3) + '4' + char(15) + 'http://ChanOps.com/radio.html ' + char(15) + char(3) + '3 or using a Program (Winamp, WM-Player or VLC): ' + char(3) +'4' + char(15) + 'http://salt-lake-server.myautodj.com:8164/listen.pls/stream';
     //r:= '(http://salt-lake-server.myautodj.com:8164/listen.pls/stream)';
     //r:= char(3) + '00,01Hola  este es un texto de ' + char(3) + '6prueba este es un texto de prueba este es un texto de prueba este es un texto de prueba este es un texto de prueba este es un texto de prueba este es un texto de prueba';
     //r:= 'http://hola.net';
     //r:= 'Chrissy: ' + char(2) +char(3) + '00,06L' + char(2) +char(3) + '00,06augh ' +char(2) +char(3) + '00,06O' + char(2) +char(3) + '00,06t ' +char(2) +char(3) + '00,06L' + char(2) +char(3) + '00,06oud'+char(3) + ' if it was alcohol it would  ' + char(2) +char(3) + '00,06L ' +char(2) +char(3) + '00,06augh ' + char(2) +char(3) + '00,06O' + char(2) +char(3) + '00,06ut ' +char(2) +char(3) + '00,06L' + char(2) +char(3) + '00,06oud' + char(3);
     //r:= 'twinklingbean: ever type something random to try to pretend you understand the conversation?';
     //r:= 'McClane: https://www.google.com.au/search?q=riviera+75+boat&newwindow=1&client=firefox-b&dcr=0&source=lnms&tbm=isch&sa=X&ved=0ahUKEwif-oKBk57aAhXCJpQKHdByAg0Q_AUICigB&biw=1450&bih=697';
     //r:= 'DH-BLOWFISH and DH-AES is no longer supported. If you are using any of these, please switch to either PLAIN or ECDSA-NIST256p-CHALLENGEDH-BLOWFISH and DH-AES is no longer supported. If you are using any of these, please switch to either PLAIN or ECDSA-NIST256p-CHALLENGEDH-BLOWFISH and DH-AES is no longer supported. If you are using any of these, please switch to either PLAIN or ECDSA-NIST256p-CHALLENGE';
     //r:= 'ot!water@2001470:67:866:ae81:ca:7413:4111 PRIVMSG #pastaspalace :The duck escapes.     ·°''°-.,žž.·°''' + char(3);
     //r:= char(3) +'4This a test text This a test text This a test text This a test text This a test text This a test text This a test text This a test text This a test text This a test text This a test text ';
     //r:= char(3) + '2 did ' + char(3) + '6â' + char(8)+char(9)+char(3)+'6,6 ' + char(3) + '0,0 ' + char(3)+'6,1Kevster'+ char(3) + '0,0 '+ char(3)+ '6,6 ' + char(15) + char(3) + '6â' + char(8)+char(9) + char(15)+char(3) + '2 go out smoking?';
     //r:= 'Topic for #moon is: ' + char(15) + char(2) + char(29) + char(3) + '7~~~Very good May Day weekend to all~~~';
     //r:= char(3) + '4,14<' + char(3) + '5,15H' + char(3) + '4,14>' + char(3) + '9,14<' + char(3) + '3,15A'  + char(3) + '9,14>' + char(3) + '12,14<' + char(3) + '2,15P' + char(3) + '12,14>' + char(3) + '13,14<' + char(3) + '6,15P' + char(3) + '13,14>' + char(3) + '8,14<' + char(3) + '7,15Y' + char(3) + '8,14>' + char(3) + '4,14<' + char(3) + '5,15B' + char(3) + '4,14>' + char(3) + '9<' + char(3) + '3,15I' + char(3) + '9,14>' + char(3) + '12<' + char(3) + '2,15R' + char(3) + '12,14>' + char(3) + '13<' + char(3) + '6,15T' + char(3) + '13,14>' + char(3) + '8<' + char(3) + '7,15H' + char(3) + '8,14>' + char(3) + '4<' + char(3) + '5,15D' + char(3) + '4,14>' + char(3) + '9<' + char(3) + '3,15A' + char(3) + '9,14>' + char(3) + '12<' + char(3) + '2,15Y' + char(3) + '12,14> ' + char(3) + '13<' + char(3) + '6,15 to colin-carpenter ' + char(3) + '13,14>';
     //r:= char(3) + '4*`' + char(3) + '3_' + char(3) + '`~' + char(3) + '6;.' + char(3) + '8`,' + char(3) + '9*,<' + char(3) + '11+''.' + char(3) + '12".*' + char(3) + '13,''.*';
     //r:= char(3) + '2.*'':' + char(3) + '3.;~' + char(3) +'4+,''' + char(3) + '5*`.''' + char(3) + '6.*~`''.' + char(3) + '7,;''' + char(3) + '8*.';
     //r:= gtopic(r);
     //r:= 'Olives: Hi, ' + char(3)+ '6-' + char(3) + '6,6 ' + char(3)+ '0,0 ' + char(3) + '6,0Sherbet' + char(3) + '0,0 ' + char(3) + '6,6 ' + char(15) + char(3) + '6- ' + char(15) + char(3);
     //r:= 'CamilaAndreina: ' + char(3) + '01' + char(2) + char(3) + '1Esta transmitiendo <' + char(3) + char(3) + '13CamilaAndreina' + char(3) + ' ' + char(3) + '1en' + char(3) + ' ' + char(3) + '3Radio Lc-Argentina' + char(3)+char(3) + '1>. Escuchala en: ' +char(3) + char(15) + char(3) + '12http://radiolcargentina.radiostream123.com' + char(2) + char(15);
     //r:= 'mcclane https://duckduckgo.com% and http://duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%) hola';
     //r:= 'mcclane https://duckduckgo.com% and http://duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com/duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%duckduckgo.com%) hola';
     //r:= 'Olives: Hi, ' + char(3)+ '6-' + char(3) + '6,6 ' + char(3)+ '0,0 ' + char(3) + '6,0Sherbet' + char(3) + '0,0 ' + char(3) + '6,6 ' + char(15) + char(3) + '6- ' + char(15) + char(3) + '1';
     //r:= 'llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll';
     //c:= clgreen;
     end;

     if (pos('h2', r) > 0) then begin
     r:= char(3) + '0,1Your behaviour is inapropiate, please change your way of chattingYour behaviour is inapropiate, please change your way of chattingYour behaviour is inapropiate, please change your way of chatting';
     //c:= clGreen;
     end;
     }

     u:= 'Ã¡Ã©Ã­Ã³ÃºÃÃÃÃÃÃ±ÃÃÃ¨Ã¬Ã²Ã¹ÃÃÃÃÃ¤Ã«Ã¯Ã¶Ã¼ÃÃÃÃÃ';
     a:= 'áéíóúÁÉÍÓÚñÑäëïöüÄËÏÖÜàèìòùÀÈÌÒÙ¡';

     // counting lines. When reaches 100, writes all of them
     inc(m0[o].lc); // Lines counter

     while m0[o].Lines.count >= 100 do begin
        //m0[o].Lines.Add('100 !!!');
        m0[o].Lines.Delete(0);
        m0[o].BStrings.Delete(0);
        if m0[o].last > 0 then m0[o].last:= m0[o].last - 1;
     end;

     for l:= 1 to length(a) do if (pos(a[l],r) > 0) then u1:= true;
     if u1 = false then
        r:= ConvertEncoding(r, 'ISO8859-1', 'UTF8', false);
        //r:= ISO_8859_1ToUTF8(r);
        //r:= ISO_8859_15ToUTF8(r);
        //r:= ConvertEncoding(r, 'UTF8', 'ISO8859-1', false);

     // Getting first line before adding
     l:= m0[o].lines.count - m0[o].LinesInWindow;

     m0[o].Lines.Add(r);

     if c = clnone then m0[o].BStrings.Add(r) else
        m0[o].BStrings.Add('bkcol' + char(3) + inttostr(icolors(c)) + '-' + r);


     if m0[o].lines.Count >= 100 then begin
        m0[o].first:= m0[o].TopLine;
        m0[o].unwr;
        m0[o].wr(false);
        m0[o].fcolors(false, clnone, '');
        m0[o].TopLine:= m0[o].first;
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
     //if o = 1 then m0[0].Append('Top ' + inttostr(TopLine) + ' L: ' + inttostr(l));
     if (TopLine >= l) then TopLine:= lines.Count-1;

     // Making last line <> 0 to paint the marker line if the page is not visible
     //if (fmainc.Notebook1.Page[fmainc.cnode(8,0,o, '')].visible) then shw:= true;

     if not (fmainc.Notebook1.Page[fmainc.cnode(8,0,o, '')].IsVisible) then begin
        if shw = true then
           //ShowMessage('tre');
           m0[o].last:= m0[o].Lines.Count -1;
        shw:= false;
        m0[o].Modified:= true;
        fmainc.TreeView1.Refresh;
     end; // else m0[o].last:= 0;
     //if assigned(m0[1]) then (m0[1].Lines.Add(inttostr(m0[1].TopLine)));


     // If it is modified and notebook page is not visible then color the tree item

     r:= ConvertEncoding(r, 'UTF8', 'iso8859-1', false);
     m0[o].procstring(r); // To file

     {for l:= 0 to 100 do
     if (pos(char(l),r) > 0) and (pos('=',r) > 0) then ShowMessage(inttostr(l));}

     {
     //if (pos('hola', r) > 0) then begin
     if (assigned(m0[1])) and (lines.Count < 99) then begin
        m0[1].Clear;
        for l:= 1 to 99 do begin
            lines.Add(inttostr(l));
            BStrings.Add(inttostr(l));
        end;
     end;
     //end;
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
   chc:               string = ' <>/\&%=+';     // Cut the line
   nd:                string = ' ,()[]';     // Hypertext end
   ec:                string = char(1) + char(2) + char(3) + char(15) + char(31);     // Empty Characters
   cc:                smallint = 0;    // Counting empty characters
begin

     l1:= BStrings.Count-1;
     l:= Lines.Count-1;

     //w:=   m0[o].Width div (font.Height div 2) -5; // Ubuntu
     //w:=   Width div (font.Height div 2) - 25; // Nimbus
     w:=   Width div (font.Height div 2) - 36; // Monospace
     //if lines.Count > 1 then

     //Searching for the original string to not process all the lines
           if (app) then
           if l1 > 0 then begin
           tmp2:= StringReplace(lines[l], char(1), '', [rfReplaceAll]);
              if (pos('bkcol', BStrings[l1]) = 1) then
                 k:= copy(BStrings[l1], 6, pos('-', BStrings[l1])-6);
              if (pos('bkcol', BStrings[l1]) = 1) then
              while (pos(tmp2, copy(BStrings[l1], pos('-', BStrings[l1])+1, length(tmp2))) <>1) and (l > 0) do dec(l) else
                 while (pos(tmp2, BStrings[l1]) <> 1) and (l > 0) do dec(l);
                 //if (pos('CHALLENGE', BStrings[l1]) > 0) then ShowMessage(BStrings[l1]);
           end;

     if app=false then l:= 0;

     if lines.Count > 0 then
     while (l < Lines.Count) do begin
           tmp:= lines[l];
           w:=   Width div (font.Height div 2) - 36; // Monospace
     {
     tmp2:= StringReplace(lines[l], char(1), '', [rfReplaceAll]);
     if (pos('bkcol', BStrings[l1]) = 1) then
     k:= copy(BStrings[l1], 6, pos('-', BStrings[l1])-6);
     if (pos('bkcol', BStrings[l1]) = 1) then
     while (pos(tmp2, copy(BStrings[l1], pos('-', BStrings[l1])+1, length(tmp2))) <> 1) and
           (l1 > 0) do dec(l1) else
           while (pos(tmp2, BStrings[l1]) <> 1) and
                 (l1 > 0) do dec(l1);
     }
     //if assigned(m0[1]) then ShowMessage(k);

     if app then
        if (pos('bkcol', BStrings[l1]) > 0) then begin
              col:= true;

              tmp2:= copy(BStrings[l1], 6, pos('-', BStrings[l1])-6);
              k:= tmp2;

              if (pos(char(3), k) = 1) then

                 while( k[length(k)] = ',' ) do delete(k, length(k), 1);
                 while(pos(',,', k) > 0) do k:= StringReplace(k, ',,',',',[rfReplaceAll]);
                 //if k[2] = ',' then k:= k[1] + '0' + copy(k, 2, length(k));

                        if (pos(',',k) > 0) then begin
                           tmp3:= copy(k, pos(',',k)+1, length(k));
                           k:= copy(k, 1, pos(',',k)-1);
                        end;

                        if tmp3 <> '' then
                           while (strtoint(tmp3) > 16) do delete(tmp3, length(tmp3), 1);

                        if length(k) > 1 then begin
                           if strtoint(copy(k, 2, length(k))) > 16 then tmp3:= '';
                           while (strtoint(copy(k, 2, length(k))) > 16) do delete(k, length(k), 1);
                           if tmp3 <> '' then
                              k:= k + ',' + tmp3; tmp3:= '';
                        end;
                  //ShowMessage('col' + k);
              tmp:= k + tmp;
              //if k <> '' then ShowMessage('col1 ' + k);
           end;

           // Getting hyperlink
              // hola http://hole.net hey no way http://no.way
           c:= 1;

           if (pos(char(1) + 'http:', lines[l]) = 0) then
           if (pos('http://',tmp) > 0) or (pos('https://', tmp) > 0) then begin
              //hy:= true;
              //ShowMessage(tmp);
              tmp2:= '';
              while (c < length(tmp)) do begin
                    tmp2:= tmp2 + tmp[c];
                    if (pos('http://',tmp2) > 0) or (pos('https://',tmp2) > 0) then begin
                    tmp2:= '';
                    while (pos(tmp[c],nd) = 0) and (c <= length(tmp)) do inc(c);
                    //ShowMessage(inttostr(c) + ' ' + inttostr(length(tmp)));
                    if tmp[c] <> ' ' then dec(c);
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
           //BStrings[l1]:= tmp;
           //ShowMessage(BStrings[l1] + sLineBreak + lines[l])
           end;


        // Starting word wrapping
        // Cleaning text
        c:= 0;
        cc:= 0;
        tmp2:= tmp;
        while (c <= length(tmp2)) do begin

              k:= ''; tmp3:= '';
              if (tmp2[c] = char(3)) then begin
              //Getting colors
              k:= tmp2[c];
                  while (tmp2[c+length(k)] in ['0'..'9']) or (tmp2[c+length(k)] = ',')
                        and (c+length(k) <= length(tmp2)) do k:= copy(tmp2, c, length(k)+1);
                  //while (k[length(k)] = ',') do delete(k, 1, length(k));
              end;
              //if k <> '' then ShowMessage(k);
              if (pos(',', k) > 0) then begin
                 tmp3:= copy(k, pos(',', k)+1, length(k));
                 try
                 while ( strtoint (tmp3) > 16 ) do delete(tmp3, length(tmp3),1);
                 except
                 end;
              end;
              delete(k, pos(',', k)+1, length(k)); k:= k + tmp3;
              if (k <> '') then begin
                 try
                 while ( strtoint ( copy(k, 2, length(k)) ) > 16 ) do delete(k, length(k), 1);
                 except
                 end;
                 delete(tmp2, c, length(k));
                 c:= c - length(k)+1;
              end;
              cc:= cc + length(k);

              if (pos(tmp2[c], ec) > 0) and not (tmp2[c] = char(3)) then begin
                 inc(cc);
                 delete(tmp2, c, 1);
                 dec(c);
              end;
        inc(c);
        end;
        if (cc > 0) then w:= w + cc;
        len:= length(tmp);

        // Word wrapping for lines and hypertext
        c:= length(tmp);
            while (c > w) do begin
                 while (c > 1) and ( pos(tmp[c], chc) = 0 ) do dec(c);
            dec(c);
            end;
            inc(c);
            if not (tmp[c] = ' ') then if (tmp[c+1] = '/') or (tmp[c+1] = '%') then inc(c);

           //if (assigned(m0[1])) then ShowMessage(copy(tmp, 1, c));
           if c = 1 then c:= w;

           //len:= length(tmp) - len;
           if (len > w) then begin
              tmp2:= tmp;
              //c:= c - len;
              //ShowMessage(inttostr(c));
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

                 // Append
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
                 while (c < length(tmp2)) do begin
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
                             while ( (tmp2[c+length(k1)] in ['0'..'9'] ) or (tmp2[c+length(k1)] = ',') )
                                   and (c+length(k1) < length(tmp2))
                                   do k1:= copy(tmp2, c, length(k1)+1);

                             while( k1[length(k1)] = ',' ) do delete(k1, length(k1), 1);
                             while(pos(',,', k1) > 0) do k1:= StringReplace(k1, ',,',',',[rfReplaceAll]);

                             if (pos(',',k1) > 0) then begin
                                tmp3:= copy(k1, pos(',',k1)+1, length(k1));
                                k1:= copy(k1, 1, pos(',',k1)-1);
                             end;

                             if tmp3 <> '' then
                                while (strtoint(tmp3) > 16) do delete(tmp3, length(tmp3), 1);

                             if length(k1) > 1 then begin
                                if strtoint(copy(k1, 2, length(k1))) > 16 then tmp3:= '';
                                   while (strtoint(copy(k1, 2, length(k1))) > 16) do delete(k1, length(k1), 1);
                                if tmp3 <> '' then
                                   k1:= k1 + ',' + tmp3;
                                tmp3:= '';
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
     co:= false; b:= false; k:= ''; k1:= ''; tmp3:= '';

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
  bl:           smallint = 0;
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
     l:= Lines.Count-1; // Last line
     bl:= BStrings.count-1;

     if co = clnone then f:= clblack else

        if app then
        if (pos('bkcol', BStrings[BStrings.Count-1]) = 1) then begin //ShowMessage(BStrings[BStrings.Count-1]);
           k:= copy(BStrings[BStrings.Count-1], 6, pos('-', BStrings[BStrings.Count-1])-6);
           lines[l]:= k + lines[l];
           //ShowMessage(k);
        end;

     // Multiline (decreases l to not process all the lines)
     if (app) and (lines.Count > 1) then begin
        //ShowMessage(lines[l] + '_');

        if (pos('bkcol', BStrings[bl]) = 1) then
        while (pos(copy(tmp, length(k)+1, length(tmp)-length(k)+1),
              copy(BStrings[bl], pos('-', BStrings[bl])+1, length(tmp)-length(k)+1) ) <> 1 ) do begin
        //ShowMessage(tmp);
        dec(l);
        tmp:= lines[l];
        tmp:= StringReplace(tmp, char(1), '', [rfReplaceAll])
        end else
           while (pos(tmp, BStrings[bl]) <> 1) do begin
           tmp:= lines[l];
           tmp:= StringReplace(tmp, char(1), '', [rfReplaceAll]);

           dec(l);
           end;
           //ShowMessage(lines[l] + sLineBreak + BStrings[bl]);
     end;

     if app = false then hl.ClearAllTokens;
     if app = false then l:= 0;

  if lines.Count > 0 then
  while (l < Lines.Count) do begin
        //if l = lines.Count-1 then ShowMessage(lines[l]);

        //if app then ShowMessage(inttostr(l));
        //if not app then
        if (pos('bkcol',lines[l]) > 0) then begin
           lines[l]:= StringReplace(lines[l], 'bkcol','', [rfReplaceAll]);
           str:= lines[l];
           delete(str, pos('-', str), 1);
           lines[l]:= str;
        end;

  str:= lines[l];

        bco:= clnone; bk:= '';

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
           tmp:= '';

           //str:= StringReplace(str, char(3) + ' ', ' ', [rfReplaceAll]);
           k:= copy(str, ch, 1);
           while ( (str[ch+length(k )] in ['0'..'9'] ) or (str[ch+length(k)] = ',') ) and ((ch + length(k)) <= length(str))
                 do k:= copy(str, ch, length(k)+1);
                 while( k[length(k)] = ',' ) do delete(k, length(k), 1);
                 while(pos(',,', k) > 0) do k:= StringReplace(k, ',,',',',[rfReplaceAll]);
                 //if k[2] = ',' then k:= k[1] + '0' + copy(k, 2, length(k));

                 if (pos(',',k) > 0) then begin
                    tmp:= copy(k, pos(',',k)+1, length(k));
                    k:= copy(k, 1, pos(',',k)-1);
                 end;

                 if tmp <> '' then
                    while (strtoint(tmp) > 16) do delete(tmp, length(tmp), 1);

                 if length(k) > 1 then begin
                    if strtoint(copy(k, 2, length(k))) > 16 then tmp:= '';
                       while (strtoint(copy(k, 2, length(k))) > 16) do delete(k, length(k), 1);
                    if tmp <> '' then
                       k:= k + ',' + tmp;
                 end;
           //if (pos('6,15', k) > 0) then ShowMessage(k);


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
                    if strtoint(bk) > 16 then bk:= copy(k, pos(',', k)+1, 1);
                 bco:= colors(bk);
              end;

              // Fore
              fr:= copy(k, 2, length(k));
              //ShowMessage('f ' + fr);
              if fr <> '' then
              if not (pos(',', fr) = 1) then begin
                 delete(fr, pos(',', fr), length(fr));
                 if (fr[1] = '0') and (length(fr) > 1) then fr:= fr[2];

                 if (length(fr) > 2) then if strtoint(fr) > 16 then delete(k, length(k), 1);
                 f:= colors(fr);
              end;

           k:= copy(k, 2, length(k));
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

           Attr3:= hl.CreateTokenID('Attr3', clFuchsia,clnone,[]); // Hyperlinks
        if //( not b = c ) and
           (b1 = true) and (c1 = true)
           then begin
           Attr1:= hl.CreateTokenID('Attr1', f, bco, [fsBold]);
           Attr2:= Attr1;
        end else begin
            Attr1:=hl.CreateTokenID('Attr1',f, bco,[]);
            Attr2:=hl.CreateTokenID('Attr2',f,clNone,[fsBold]);
        end;

        if (str[ch] = char(1)) or (str[ch] = char(2)) or (str[ch] = char(3)) or
           (str[ch] = char(8)) or (str[ch] = char(9)) or (str[ch] = char(15)) or (str[ch] = char(31)) then inc(chs);

           if (co = clnone) then
           if ( (str[ch] = char(1)) or (str[ch] = char(2)) or (str[ch] = char(3)) ) then begin
              if not (modi) then hl.AddToken(l, ch-chs, tktext);
           modi:= true;
        end;

        //if (modi = false) then hl.AddToken(l, ch-chs, tkText);
        //if (str[ch] = char(2)) and (co <> clnone) then if (b = false) then hl.AddToken(l, ch-chs-1, Attr1);
        if (c = true) and not (k = '') then if (str[ch+1] = char(2)) then hl.AddToken(l, ch-chs, Attr1);
        if (str[ch] = char(2)) then if (b = false) then hl.AddToken(l, ch-chs, Attr2);
        //if (ch = length(str)) then if (b = true) then hl.AddToken(l, ch-chs-1, Attr2);

        if (str[ch] = char(15)) then if (b1 = true) and (c1 = false) then hl.AddToken(l, ch-chs, Attr2);
        //if (str[ch] = char(15)) then if (b = true) and (c = true) then hl.AddToken(l, ch-chs, tktext);
        if (str[ch] = char(15)) then if (c = false) and (b1 = false) then hl.AddToken(l, ch-chs, Attr1);
        //if (str[ch] = char(15)) and ( b1 = c1 = true) then hl.AddToken(l, ch-chs, Attr1);
        if (str[ch] = char(15)) and ( b1 = c1 = true) then hl.AddToken(l, ch-chs, Attr1);
        //if (str[ch] = char(15)) and (b1 = false) and (c1 = false) then hl.AddToken(l, ch-chs, tkText);

        if (hy = false) then begin
        if (ch = length(str)) and not (str[ch] = char(1)) then if (b1 = true) and (c1 = false) then hl.AddToken(l, ch, Attr2);
        if (ch = length(str)) and not (str[ch] = char(1)) then if (c1 = true) then hl.AddToken(l, ch, Attr1);
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
        //r:= 'hola ' + 'http://ChanOps.com/radio.html ' + char(15) + char(3) +
        //'3 or using a Program (Winamp, WM-Player or VLC): ' + char(3) +'4' + char(15) +
        //'http://salt-lake-server.myautodj.com:8164/listen.pls/stream';
        //if (hy = true) and (str[ch] = char(1)) then hl.AddToken(l, ch-chs+1, tkText);
        //if (assigned(m0[1])) and (str[ch] = char(1)) then ShowMessage(inttostr(ch));
        if (str[ch] = char(1)) then
              if (hy = false) then hl.AddToken(l, ch-chs+1, Attr3) else
                 if (c1 = true) then hl.AddToken(l, ch-chs, Attr1);

        if (hy = true) and (ch = length(str)) then hl.AddToken(l, ch-chs, Attr3);


        if (str[ch] = char(15)) or (ch = length(str)) then begin
           if b = true then b:= false;
           if c1 = true then c:= false;
           b1:= false;
           c1:= false;
           f:= clblack;
           bco:= clnone;
           bk:= '';
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
  str:= StringReplace(str, char(8), '', [rfReplaceAll]);
  str:= StringReplace(str, char(9), '', [rfReplaceAll]);
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
     while (c < length(r)) do begin

           if (r[c] = char(3)) then begin
               k:= copy(r, c, 1);

               while ( (r[c+length(k )] in ['0'..'9'] ) or (r[c+length(k)] = ',') ) and ((c + length(k)) <= length(r))
                     do k:= copy(r, c, length(k)+1);
                     while( k[length(k)] = ',' ) do delete(k, length(k), 1);
                     while(pos(',,', k) > 0) do k:= StringReplace(k, ',,',',',[rfReplaceAll]);
                     //if k[2] = ',' then k:= k[1] + '0' + copy(k, 2, length(k));

               if (pos(',',k) > 2) then
                  while (StrToInt(copy(k, 2, pos(',',k)-2)) > 16) do delete(k, length(k), 1);
               if (pos(',',k) > 0) then
                  while (StrToInt(copy(k, pos(',',k)+1, length(k))) > 16) do (delete(k, length(k), 1)) else
                  if length(k) > 2 then
                  while (strtoint(copy(k, 2, length(k))) > 16) do (delete(k, length(k), 1));

           //if assigned(m0[1]) then ShowMessage(k);
           delete(r, c, length(k)); // Replace
           end;
     if (r[c] <> char(3)) and (c < length(r)) then inc(c);
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
                        //ShowMessage('5' + inttostr(o));
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
    y2:      integer = 0;
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
     y2:= y1;

        //CaretX:= x1;
        //CaretY:= y1;


     x1:= (x div 6);
     y1:= (y div (LineHeight) + TopLine)-1;

     str:= Lines[y1];
     tmp:= str;

     //m0[o].Append('x1: ' + inttostr(x1) + ' y1: ' + inttostr(y1));

     // Getting string
     // Searching backwards from caret position to find a space or bracket
     if not (str = '') then begin

     if (x1 > length(lines[y1])) then x1:= length(lines[y1])-1;
     s:= x1;
     while (pos(str[s], chr) = 0) and (s > 0) do begin
           //ShowMessage(lines[y1]);
           if (pos(str[s],chr ) = 0) and (s = 1) and (y1 > 0) then begin
              dec(y1);
              str:= lines[y1];
              s:= length(lines[y1]);
              //ShowMessage(lines[y1]);
           end;
     dec(s);
     end; // s = space
     //ShowMessage(inttostr(x1) + ' ' + inttostr(y1) + ' s_' + inttostr(s) + sLineBreak + str[s+1]);

     // Getting string
     // Searching forward from caret position to find a space or bracket
     e:= x1+1;
     if e < s then e:= e+s;
     if e > length(str) then e:= s+1;
     //ShowMessage(str + sLineBreak + inttostr(e));
     //y1:= CaretY;
     while (pos(str[e], chr) = 0) and (str[e] <> '*') do begin
           //if (str[e] = '/') or (str[e] = '%') and (e = x1+1) then e:= s+e;
           //if not (str[e] in ['a'..'z']) and not (str[e] in ['A'..'Z']) then
           if (e = length(str)) then if (pos(str[e], chr) = 0) then if ( (str[e] = '/') or (str[e] = '%') or (str[e] = '=')
              or (str[e] = '+') )
              and (y1 < lines.Count) then begin
              inc(y1);
              str:= str + lines[y1];
              //ShowMessage(str);
           end;
     inc(e);
     end;
     //if (str[e] <> ' ') then dec(e);
     //ShowMessage('e '+ copy(str, s, e-s));
     //if e < s then e:= s+2;
     str:= copy(str, s+1, e-1-s); // copying from s+1 to e-1 -> resulting link

     //Removing the next line if necessary
     if (pos('*', str) > 0) or (str[length(str)] = ':') then begin
             e:= length(str);
             while not (str[e] = '/') and not (str[e] = '%') do dec(e);
     delete(str, e+1, length(str)-e);
     end;

     if (pos('http://',str) = 1) or (pos('https://',str) = 1) then begin
        x1:= x + fmainc.Left + Left;
        y1:= y +20+ fmainc.Top  + top;
        //label1.Caption:= 'x: ' + inttostr(x1) + ' y: ' + inttostr(y1);
        //Clipboard.AsText:= str;
     if Button = mbRight then
        fmainc.poplm.PopUp(x1+100,y1+50) else fmainc.opmClick(nil);
        //ShowMessage(str);
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
     l:= (lines.count - l); // Last line
     //if (pos('hey', lines[lines.Count-1]) > 0) then ShowMessage('hey');
     if (last > 1) then begin
        //if (pos('hey', lines[lines.Count-1]) > 0) then ShowMessage('hey');
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
      //ShowMessage('txp: ' + inttostr(i));
      // Select created node except when you get a private message
      if TreeView1.Items.Count > 0 then
      if r = true then
      TreeView1.items.GetLastNode.Selected:= true
      else if go = true then
          //if TreeView1.Selected.HasChildren then ShowMessage('ch');
          //if TreeView1.Selected.HasChildren then
          TreeView1.Items[i].Selected:= true;

      //ShowMessage(inttostr(TreeView1.Items.GetLastNode.AbsoluteIndex));

      //createlog(con, TreeView1.Selected.Text);
      //if length(com) = 1 then
      //SetLength(com, TreeView1.Items.Count, 20);
      //ed0[TreeView1.Selected.AbsoluteIndex].SetFocus;
end;

procedure tfmainc.nbadd1(c,nick: string; con,i: smallint);
{This procedure creates a widget with a listbox
 c = text, con = connection, i = pageindex}
var a: smallint = 0; // Memo number
begin

      if i = Notebook1.PageCount then
         Notebook1.Pages.Add('Page' + inttostr(i))
      else
         Notebook1.Pages.Insert(i, 'Page' + inttostr(i));
         //Notebook1.Pages.Add('Page' + inttostr(i));

     //Notebook1.Page[i].Name:= 'x' + inttostr(i);

     while assigned(m0[a]) do inc(a);
     //ShowMessage('a ' +inttostr(a));

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
     m0[a].OnKeyPress:= @SynEdit1KeyPress;
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
          //name:= 'Nimbus Mono L';
          name:= 'Monospace';
          //CanUTF8;
          height:= 10;
          Color:= clBlack;
          Style:= [];
          //BkColor:= clWhite;
          //HasBkClr:= false;
     end;

     while (pos(' ',c) > 0) do delete(c, 1, pos(' ' ,c));
     m0[a].chan:= inttostr(con) + c;
     m0[a].nnick:= nick;

     // Adding chan and node to chanode
     // nb 1 a 0
     //ShowMessage('nb ' + inttostr(i) + ' a ' + inttostr(a));
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
     m0[a].OnKeyPress:= @SynEdit1KeyPress;
     m0[a].OnMouseMove:= @tsynMouseMove;
     m0[a].OnMouseUp:= @tsynMouseUp; //(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
     m0[a].OnPaint:= @tsynPaint;

     // RichMemo Font Attribues
     //      // spanish iso8859-1
     // adobe-courier-medium-r-normal-*-*-100-*-*-m-*-iso10646-1
     with m0[a].Font do begin
          //Name:= 'Ubuntu Mono';
          //name:= 'Nimbus Mono L';
          name:= 'Monospace';
          //CanUTF8;
          Height:= 10;
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
 If task = 8 then return the node from a given array
 If task = 9 then change an channel}

var
   n:     smallint = 0;
   c:     smallint = 0;
   maxn:  SmallInt = 0; // Max Node
   conn:  string;
   tmp:   tchans;
begin
     case task of
          0: Begin // Append
          for n:= 0 to length(chanod) do begin
                if chanod[n].node >= nod then begin
                   chanod[n].node:= chanod[n].node+1;
                   //chanod[n].arr:= chanod[n].arr+1;
                end;
          end;
                          //ShowMessage(inttostr(ord));
          //SetLength(chanod, length(chanod)+1);
          chanod[length(chanod)-1].chan:= chan;
          chanod[length(chanod)-1].node:= nod;
          chanod[length(chanod)-1].arr:= ord;
          //for n:= 0 to length(chanod)-1 do ShowMessage(inttostr(chanod[n].arr) + ' ' + chanod[n].chan + ' ' + inttostr(chanod[n].node));
          end; // Add

          1: Begin // Delete
          while (n < length(chanod)-1) do begin
                if (chanod[n].node = nod) then begin
                   tmp:= chanod[n];
                   chanod[n]:= chanod[n+1];
                   chanod[n+1]:= tmp;
                end;
                if (chanod[n].node >= nod) then chanod[n].node:= chanod[n].node-1;
                   {com[n]:= com[n+1];
                   length(com):= length(com)-1;}
                   //ShowMessage('1: ' + inttostr(cnode(5,nod,0,'')));
          inc(n);
          end;
          SetLength(chanod, length(chanod)-1);
          //for n:= 0 to length(chanod)-1 do if chanod[n].node > nod then chanod[n].node:= chanod[n].node-1;
          //for n:= 0 to length(chanod) do ShowMessage(inttostr(chanod[n].node) + sLineBreak + inttostr(chanod[n].arr) + ' ' + chanod[n].chan + ' ' + chan + sLineBreak + inttostr(length(chanod)));
          end; // Delete

          2: begin // Search channel by name
          while (n < length(chanod)) do begin
                //chanod[n].chan:= lowercase(chanod[n].chan);
                //if assigned(m0[1]) then ShowMessage(chanod[n].chan + sLineBreak + chan);
                if (lowercase(chanod[n].chan) = lowercase(chan)) then result:= chanod[n].arr;
          inc(n); end;
                //if assigned(m0[1]) then ShowMessage(inttostr(result));
          end; // Search

          3: begin // array-array
          //for n:= 0 to length(chanod)-1 do begin
              //if (chanod[n].arr = ord) then
              result:= chanod[ord].arr;
          //end;
          end; // Search

          4: begin // array-node
          //for n:= 0 to length(chanod)-1 do begin
              //if (chanod[n].node = nod) then
              result:= chanod[ord].node;
          //end;
          end; // Search

          5: begin // Returns array from node
          for n:= 0 to length(chanod)-1 do begin
              //ShowMessage('5' + chanod[n].chan);
              if (chanod[n].node = nod) then
              result:= chanod[n].arr;
          end;
          end; // Search

          6: Begin // Delete a connection. Delete nodes and update channels

          for n:= 0 to length(chanod) do begin
              //if (n+1) < length(chanod) then
              if (chanod[n].node >= nod) and (chanod[n].node <= ord) then
                 chanod[n].node:= 100;
          end;

          repeat
          maxn:= 0;

              for n:= 0 to length(chanod)-2 do
                  //if (n+1) < length(chanod) then
                  //ShowMessage(chanod[n].chan);
                  if (chanod[n].node > chanod[n+1].node) then begin
                     tmp:= chanod[n];
                     chanod[n]:= chanod[n+1];
                     chanod[n+1]:= tmp;
                     maxn:= 1;
                     //ShowMessage(chanod[n].chan);
                  end;

          until maxn = 0;

          setlength(chanod, length(chanod)-(ord - nod +1));

          //ShowMessage('length: ' + inttostr(length(chanod)) + ' n: ' + inttostr(n) + ' arr: '  + inttostr((chanod[n].arr)));
          //for maxn:= 0 to length(chanod)-1 do ShowMessage(inttostr(maxn) + sLineBreak+ 'node: ' + inttostr(chanod[maxn].node) + ' chan: ' + chanod[maxn].chan);

          // Updating connection in channel names
          for n:= 0 to length(chanod)-1 do begin

              // Updating connection
              c:= 1;
              conn:= chanod[n].chan;
              //ShowMessage('u ' + conn);
              while (conn[c+1] in ['0'..'9']) and (c < length(chanod[n].chan)) do inc(c);
              conn:= copy(conn, 1, c);

              if strtoint(conn) > 0 then
                  if conn <> '' then if (chanod[n].node > ord) then begin
                     delete(chanod[n].chan, 1, c);
                     chanod[n].chan:= inttostr(strtoint(conn)-1) + chanod[n].chan;
                  end;

              //ShowMessage('arr: ' + inttostr(chanod[n].arr) + sLineBreak + 'node: ' + inttostr(chanod[n].node) + inttostr(ord));
              if (chanod[n].node > ord) then
                 chanod[n].node:= chanod[n].node - (ord - nod +1);

          //ShowMessage('conn: ' + conn + sLineBreak+ 'las: ' + chanod[n].chan + sLineBreak + ' arr: ' +inttostr(chanod[n].arr) + sLineBreak + 'node: ' +  inttostr(chanod[n].node));
          end; // for

          end; // 6

          7: begin // After update connection in channels (6), b becomes false.
             //b:= false;
             //for n:= 0 to length(chanod)-1 do ShowMessage(inttostr(chanod[n].arr) + ' ' + inttostr(chanod[n].node));
          end;

          8: begin // Returns the node from an array
             for n:= 0 to length(chanod)-1 do
                 if (chanod[n].arr = ord) then result:= chanod[n].node;
          end;

          9: begin // Changes a channel
             for n:= 0 to length(chanod)-1 do
                 if (chanod[n].chan = copy(chan, 1, pos('/', chan)-1) ) then chanod[n].chan:= copy(chan, pos('/', chan)+1, length(chan));
          end;

end; // task
end;

procedure Tfmainc.lbmouseup(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     if Button = mbRight then begin
      rc:= TListBox(sender).GetIndexAtXY(x, y);
      if rc > -1 then begin
         nickinfo(true, TListBox(sender).Items[rc]);
         nickpop.PopUp;
         end;
      end;
end;

function Tfmainc.nickinfo(task: boolean; nick: string): string;
{task = true means right click in the nicks list}
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
     a:= '!~&@%+';

     // Processing nick. Removing ~@%+
     while (s < length(nick)) do begin
           for p:= 1 to 6 do // length(a)
               if (pos(a[p], nick) > 0) then delete(nick, 1, 1);
     inc(s);
     end;
     p:= 0; s:= 0; a:= '';

     // Getting connection
        s:= TreeView1.Selected.Parent.Index +1; // Returns TSyn array

     // Querying who
     if (task = true) then net[s].conn.SendString('WHO ' + nick + #13#10);

     if (task = true) then while a = '' do a:= net[s].conn.RecvString(100);
     while (pos('WHO', tmp) = 0) do tmp:= net[s].conn.RecvString(200);
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
     if (task = true) then
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
     if nickpop.Items[2].Items[5] = sender then fkickmess.ShowModal;
     for p:= 0 to 2 do if nickpop.Items[2].Items[6].Items[p] = sender then fkickmess.ShowModal;
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
     if (sender = kickm) then net[con].conn.SendString('KICK ' + chan + ' ' + nickpop.items[0].caption + mess + e);

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
     s:= '!~&@%+';
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

                 if l=5 then
                 lb0[n].Canvas.Draw(0, lb0[n].ItemRect(a).Top+3, gr[5]);

                 if l=6 then
                 lb0[n].Canvas.Draw(0, lb0[n].ItemRect(a).Top+3, gr[6]);


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
     Timer1.Enabled:= false;

        delete(com, 1,1);
        tmp:= com;
        delete(tmp, 1, pos(' ', tmp));
                      // /ban 3 mcclane fuera de aqui
        delete(com, pos(' ', com), length(com));   // Command

        if (pos('1', tmp) = 1) or (pos('2', tmp) = 1) or (pos('3', tmp) = 1) then begin
           typ:= copy(tmp, 1, pos(' ', tmp)-1);       // Ban Type
           delete(tmp, 1, pos(' ', tmp));
        end;
        if typ = '' then typ:= '1';

        //delete(tmp, 1, pos(' ', tmp));
        if (pos(' ', tmp) > 0) then
        nick:= copy(tmp, 1, pos(' ', tmp)-1) else  // Nick
        nick:= copy(tmp, 1, length(tmp));

        if pos(' ', tmp) > 0 then begin
        delete(tmp, 1, pos(' ', tmp));
        mess:= ':' + copy(tmp, 1, length(tmp));          // Message
        end;
        //ShowMessage('mess ' + mess);

     // Querying who
        net[con].conn.SendString('WHOIS ' + nick + #13#10);
        tmp:= '';
        while (tmp = '') do tmp:= net[con].conn.RecvString(300);
              while (pos( 'whois', lowercase(ip)) = 0 ) do ip:= net[con].conn.RecvString(300);
        // :barjavel.freenode.net 352 Sollo * ~JMcClane 181.31.118.135 tolkien.freenode.net McClane H :0 John McClane
//ShowMessage('bans: ' + tmp + sLineBreak + com + sLineBreak + chan + sLineBreak + typ);
        for n:= 1 to 5 do begin
            delete(tmp, 1, pos(' ', tmp));
            if n = 4 then ident:= copy(tmp, 1, pos(' ', tmp)-1) else ip:= copy(tmp, 1, pos(' ', tmp)-1);
        end;
        //ShowMessage(ident + sLineBreak + ip);

        if (com = 'ban') or (com = 'kb') then begin

           if typ = '1' then net[con].conn.SendString('MODE ' + chan + ' +b ' + nick + '!*@*' + #13#10);
           if typ = '2' then net[con].conn.SendString('MODE ' + chan + ' +b ' + '*!' + ident + '@*' + #13#10);
           if typ = '3' then net[con].conn.SendString('MODE ' + chan + ' +b ' + '*!*@' + ip + #13#10);

        end;
//ShowMessage(mess);
        if (com = 'kb') then net[con].conn.SendString('KICK ' + chan + ' ' + nick  + ' ' + mess + #13#10);
     Timer1.Enabled:= true;
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
     conn.SendString('NAMES ' + ch + ' ' + #13#10);
     while (pos('/NAMES', r) = 0) do begin
     r:= conn.RecvString(200);
     //ShowMessage(r);
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
         fmainc.fillnames(r, 0);
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
   names: array[0..250] of string;
   n:     smallint = 0; // Array items
   p:     smallint = 1; // nick position
   l:     smallint = 1; // s position
begin
     timer1.Enabled:= false;

     {
     //l:= TreeView1.Selected.AbsoluteIndex;
     while (assigned(m0[l])) do begin

     if (ch = m0[l].chan) then begin
     //l:= n;
     n:= 0;
     }
     //while pos(#13, r) > 0 do begin
     //ShowMessage(r);
     while (pos(':', r) > 0 ) do delete(r, 1, pos(':', r));

     {
     if r = '' then
        repeat r:= conn.RecvString(200);
        //while (r = '') and (pos('JOIN', r) > 0) or (pos('PART', r) > 0) and (pos('PRIVMSG', r) = 0)
        //do r:= conn.RecvString(200);
        until (pos('/NAMES', s) > 0);
     }

     if (pos('/NAMES', r) > 0) then r:= '';
     while (pos(' ', r) > 0) do begin
           names[n]:= copy(r, 1, pos(' ', r) -1);
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
   st:   string;
   it:   string;
   p:    smallint = 0;  // Position from srchnick function
   e:    string = '!~&@%+';
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
     st:= srchnick(nick1, 2, a);
     //newnick:= st + newnick;
     //ShowMessage('ch ' + nick1);
     //ShowMessage('new ' + st);
     //fmainc.lbchange(copy(r, 1, pos('!', r)-1), mess, 2, s, num+1) else
Case task of
     0: Begin // append
        lb0[a].items.Insert(p, nick1);
        lb0[a].Selected[p];
        lb0[a].Selected[p]:= false;
     end; // 0 Append

     1: begin // Remove
        lb0[a].Items.Delete(p);
     end;     // 1 Remove


     2: Begin // Change
              //ShowMessage('a ' + arstat(st + newnick));
              lb0[a].Items.Insert(p+1, arstat(st + newnick));
              lb0[a].Items.Delete(p);

     end;     // Change

     3: Begin // Add status
              //ShowMessage('a ' + arstat(newnick + nick1));
              lb0[a].Items[p]:= arstat(st + newnick + nick1);
              //ShowMessage(arstat(st + newnick + nick1));
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
     e:= '!~&@%+';

     // Sorting all
     repeat
     n:= 0;
     p:= 1;
     ch:= false;
     while (n < lb0[a].Items.Count -1) do begin
           item1:= lowercase(lb0[a].Items[n]);
           item2:= lowercase(lb0[a].Items[n+1]);

           while (pos(item1[p], e) > 0) do inc(p);
           item1:= copy(item1, p, length(item1));
           p:= 1;
           while (pos(item2[p], e) > 0) do inc(p);
           item2:= copy(item2, p, length(item2));

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
     //op:= 0;
      while (n < lb0[a].Items.Count -1) do begin
            //if (pos(lb0[a].Items[n],e) > 0) then begin
               s:= pos(lb0[a].Items[n][1], e);   if s=0 then s:= 1000;
               t:= pos(lb0[a].Items[n+1][1], e); if t=0 then t:= 1000;
               //if (s > 0) and (s < 5) then inc(op);
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

      // Counting ops
      for n:= 0 to lb0[a].Items.Count -1 do begin
      s:= 0;
      p:= 0;
            item1:= lowercase(lb0[a].Items[n]);
            while (s < length(e)) do begin
                  if (pos(item1[s], e) > 0) and (pos(item1[s], e) < 6) then p:= pos(item1[s], e);
            inc(s);
            end;
            if (p > 0) and (p < 6) then inc(op);
      end;

      // Filling label
      lab0[a].Caption:= 'Ops: ' + inttostr(op) + ', users: ' + inttostr(lb0[a].Items.Count - op) +
                        ' - Total: ' + inttostr(lb0[a].Items.Count);
end;

function tfmainc.srchnick(nick: string; task, ch: smallint): string;
var n:    smallint = 0;
    tmp:  string;
    st:   string;
    stat: string = '!~&@%+';
    p:    smallint = 1;
    f:    boolean = false;
begin
     while (n < lb0[ch].Count) do begin

           tmp:= lowercase(lb0[ch].Items[n]);
           while (pos(tmp[p], stat) > 0) and (p < length(stat)) do inc(p);

                 tmp:= copy(tmp, p, length(tmp));
                 //ShowMessage(tmp);

           if (lowercase(nick) = tmp) then begin
              st:= st + copy(lowercase(lb0[ch].Items[n]), 1, p-1);
              //ShowMessage('st ' + st);
              f:= true;
              p:= n;
              n:= lb0[ch].Count;
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

          2: Begin    // Status
             result:= st;
          end;

     end;
end;

function tfmainc.nicktab(ch: smallint; test: String):string;
const f:     boolean = false;
      last:  string = '';
      i:     smallint = 0;
      stat:  string = '!~&@%+';
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
         if TreeView1.Items.Count > 1 then treepop.PopUp;
      end;
end;

procedure Tfmainc.closeRmClick(Sender: TObject);
begin
     if TreeView1.Items[rc].Parent = nil then closenclick(rc, TreeView1.Items[rc].Text) else
     LeaveRoom(0);
end;

procedure Tfmainc.LeaveRoom(task: smallint);
{This procedure comes from right click on the tree. It provides RC which is the
node selected for deletion.
1. Delete Notebook page.
3. Delete tree node.
4. Leave the room
}
var
   conn:    smallint;
   room:    string;
   c:       smallint = 0;
   count:   smallint = 0;

begin

     with Notebook1 do begin


case task of

     0: Begin
     TreeView1.Items[rc].Parent.Selected:= true;

     // Getting connection from TTreeView
     conn:= TreeView1.Items[rc].Parent.Index +1;
     // Room = Node name
     room:= TreeView1.Items[rc].Text;

     // Deleting Tree Node
     TreeView1.Items[rc].Delete;

     if (pos('#', room) > 0) and (pos('(', room) = 0) then
     net[conn].conn.SendString('PART ' + room + ' Leaving' + #13#10);
     //timer1.Enabled:= false;
     end; // Case 0


     1: Begin
     //ShowMessage('1 ' + inttostr(rc));
     // Deleting components on deleted page
     c:= cnode(5,rc,0, '');
     if assigned(lb0[c]) then begin
           freeandnil(lab0[c]); freeandnil(gb0[c]);
           freeandnil(lb0[c]);
           FreeAndNil(splt[c]);
     end;
        freeandnil(ed0[c]);freeandnil(m0[c]);


     // Deleting chan and node
     //cnode(1, rc, rc, inttostr(conn-1) + room);
     cnode(1, rc, 0, '');

     // Arranging Notebook pages?
     {count:= rc;
     while (count < PageCount-1) do begin
        // Deleting items. Finding item array from m0[x].node
        if count > rc then
           Pages[count]:= pages[count +1];
     inc(count);
     end;}
     pages.Delete(rc);

     end; // Case 1

     //timer1.Enabled:= true;
     end; // task
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
    lconn:   connex;       // Backup connection
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
           //ShowMessage('5 ' + inttostr(p));
              if assigned(lb0[p]) then begin
              FreeAndNil(lab0[p]);
              FreeAndNil(gb0[p]);
              FreeAndNil(lb0[p]);
              FreeAndNil(splt[p]);
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
           //ShowMessage('p ' + inttostr(n));
           Notebook1.Pages.Delete(rc);
     inc(n);
     end;
     Notebook1.PageIndex:= rc;

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
     if Items[rc].GetNextSibling <> nil then Items[rc].GetNextSibling.Selected:= true else
        if (rc > 0) then Items[rc-1].Selected:= true;
     //num:= Items.Item[n].Index; // Saving index to get the connection
     //TreeView1.Items.Item[n].Text:= '(' + TreeView1.Items.Item[n].Text + ')';

     // Making num match the connection
     num:= TreeView1.Items[rc].Index+1;

     TreeView1.Items.Item[n].Delete;

     end; // TreeView

     //ShowMessage('rc ' + inttostr(num));

     // 3. Close network
     net[num].conn.CloseSocket; // Disconnect
     //items[rc].Text:= '(' + items[rc].text + ')';

     // net:      array[1..10] of connex;
     //if assigned(net[num]) then ShowMessage(net[num].server);
     net[num]:= nil;

     for p:= 1 to length(net)-2 do
         if not (assigned(net[p])) then begin

            if (assigned(net[p+1])) then
            if not (net[p+1].num = -2) then begin
                net[p]:= net[p+1];
                net[p].num:= p -1;
                net[p].server:= net[p+1].server;

                net[p+1]:= nil;
               end;
            //if assigned(net[p]) then ShowMessage(inttostr(p) + ' num ' + inttostr(net[p].num) + sLineBreak + net[p].server);
            end;

     //net[2].destroy;
     //FreeAndNil(net[2]);
     //if assigned(net[1]) then ShowMessage('puta' + inttostr(rc+2));
     //net[1].conn.CloseSocket;

     fmainc.Timer1.Enabled:= true;

     {
     for p:= 1 to length(net) do
         if (net[p].num = -1) then
            net[p]:= nil;
                //if assigned(net[n]) then ShowMessage('num ' + inttostr(net[n].num) + sLineBreak + net[n].server);
     }
     {
     for p:= 1 to length(net) do if assigned(net[p]) then ShowMessage(inttostr(p) + sLineBreak +
                    inttostr(net[p].num) + sLineBreak + net[p].server);
     }

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

var arr:  smallint = 0; // tmemos assigned
    m:    smallint = 0; // tmemos assigned
    n:    smallint = 0;
    i:    TIcon;
    s:    string;
    r:    boolean = false;
begin
     SetLength(mess, TreeView1.Items.Count);
     SetLength(blue, TreeView1.Items.Count);
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

        n:= cnode(3,0,arr, ''); // Array
        m:= cnode(4,0,arr, ''); // Node
        //ShowMessage('node: ' + inttostr(m));

        //if m = 1 then m0[0].Append(inttostr(m));

        if assigned(m0[n]) then
           if (m0[n].Lines <> nil) then
           s:= m0[n].Lines[m0[n].Lines.Count -1];
           //s:= tr.Lines[tr.Lines.Count -1];

           if assigned(m0[n]) then

              if (m0[n].Modified) and not (Notebook1.page[m].IsVisible) then
                 //ShowMessage(TNotebook(m0[n].Parent.Parent).Name);
              //then

              if node.AbsoluteIndex = m then

              if (pos(lowercase(m0[n].nnick), lowercase(s)) > 0)
                 or (blue[m] = true)
                 then begin
                 sender.Canvas.Font.Color:= clBlue;
                 blue[m]:= true;
                 TrayIcon1.Icon:= i;
              end else

              if (blue[m] = false) then
              if (pos('quit', lowercase(s)) = 0) and (pos('quit:', lowercase(s)) = 0)
                 and (pos('part', lowercase(s)) = 0)
                 and (pos('has joined #', lowercase(s)) = 0)
                 and (pos(':', s) > 0)
                 or (mess[m] = true)

              then begin
                   mess[m]:= true;
                   sender.Canvas.Font.Color:= clred;
                   //if blue[m] = false then
                 if (r = false) then begin
                    i.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'trayred.ico');
                    TrayIcon1.Icon:= i;
                 end;

              end else

                  if (mess[m] = false) then
                  sender.Canvas.Font.Color:= clMaroon;

              if (blue[m] = true) then r:= true;

              if (Notebook1.Page[m].isVisible) then begin
                 blue[m]:= false;
                 mess[m]:= false;
                 m0[n].Modified:= false;
                 //if (blue[m] = false) then r:= false;
                 //r:= false;
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
     //if not assigned(TreeView1.Selected) then TreeView1.items[0].Selected:= true;
     //if (Notebook1.PageCount > 0) then Notebook1.PageIndex:= 2;
     Notebook1.PageIndex:= TreeView1.Selected.AbsoluteIndex;

     //ShowMessage('count: ' + inttostr(Notebook1.PageCount));
     if TreeView1.Items.Count > 0 then
     for p:= 0 to length(chanod)-1 do begin
         n:= cnode(3,0,p,''); // array-array
         if assigned(m0[n]) then
         //if m0[n].Visible then ShowMessage(inttostr(m0[n].node));
         if (cnode(4,0,p,'') = Notebook1.PageIndex) then begin // array-node
         //if (chanod[p].node = Notebook1.PageIndex) then begin // array-node
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
           if (Notebook1.Page[Notebook1.PageIndex].Controls[n] is tedit) and
              (Notebook1.Page[Notebook1.PageIndex].IsVisible) then
              //if assigned(Notebook1.page[Notebook1.PageIndex].Controls[n]) then
              tedit(Notebook1.page[Notebook1.PageIndex].Controls[n]).setfocus;
           //ShowMessage('count ' + inttostr(Notebook1.PageCount));
     inc(n);
     end;

end;

procedure Tfmainc.mstatusChange(Sender: TObject);
{This procedure is not used anymore}
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
      f:    smallint = 1;
      n:    smallint = 1;
      a:    boolean = false; // At least one connection is active
begin
     {
     if timer1.Interval = 50 then begin
        while assigned(net[n]) do inc(n);
        n:= n-1;
        //net[n].loop;

     n:= 1
     end else begin
     }

     while (assigned(net[n])) do begin
           if (net[n].fast = true) then f:= n;
           if net[n].active = true then a:= true;
     inc(n);
     end;
     n:= f;
     if a = false then begin
     fmainc.clistm.Enabled:= false;
     fmainc.joinm.Enabled:= false;
       fmainc.ToolButton2.Enabled:= false;
     fmainc.dconm.Enabled:= false;
     fmainc.chanm.Enabled:= false;
     end;

     //while (assigned(net[n])) and (assigned(net[n].conn)) do begin
     while (assigned(net[n])) do begin

     net[n].loop;

     if timer1.Interval = 2000 then
     ping:= ping + 2000;
     if (ping = 100000) then begin
        net[n].conn.SendString('PONG ' + net[n].server + #13#10);
        ping:= 0;
     end;

     if net[n].fast = true then n:= 11;
     inc(n);
     end;
end;


//initialization
//m1:= nil;

end.



