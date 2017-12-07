unit servf;

{$mode objfpc}{$H+}

interface

uses
  Classes, ComCtrls, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Laz2_DOM, laz2_XMLRead, laz2_XMLWrite, functions;

type

  { Tfserv }

  Tfserv = class(TForm)
    adn: TButton;
    connb: TButton;
    ListBox1: TListBox;
    newb: TButton;
    Ads: TButton;
    globalc: TCheckBox;
    deln: TButton;
    dels: TButton;
    ginfol1: TLabel;
    gnick1: TLabeledEdit;
    gnick2: TLabeledEdit;
    gnick3: TLabeledEdit;
    grname: TLabeledEdit;
    guser: TLabeledEdit;
    ListBox2: TListBox;
    nick1: TLabeledEdit;
    nick2: TLabeledEdit;
    nick3: TLabeledEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    Port: TLabeledEdit;
    rname: TLabeledEdit;
    serv: TLabeledEdit;
    serv1l: TLabel;
    netw: TLabeledEdit;
    servl: TLabel;
    PageControl1: TPageControl;
    sinfol: TLabel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    userm: TLabeledEdit;
    procedure connbClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject);

    procedure AdsClick(Sender: TObject);
    procedure delsClick(Sender: TObject);

    procedure adnClick(Sender: TObject);
    procedure delnClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
    procedure newbClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fserv: Tfserv;
  lserv: array[1..120] of tServ;
  f:     TXMLDocument;
  n1,a:  TDOMNode;


implementation
uses mainc;

{$R *.lfm}

{ Tfserv }

procedure Tfserv.FormActivate(Sender: TObject);
var
   n:      smallint = 1;
   c:      smallint = 0; // Servers
   tmp:    string;
begin
     if ListBox1.Items.Count > 0 then listbox1.ItemIndex:= 0;

     if ListBox1.Items.Count = 0 then begin

     f:= TXMLDocument.Create;
     if FileExists(GetEnvironmentVariable('HOME') + '/.config/nchat/nchat.xml') then
        ReadXMLFile(f, GetEnvironmentVariable('HOME') + '/.config/nchat/nchat.xml');

     n1:= f.FindNode('Networks');
     n1:= n1.FirstChild;
     while assigned(n1) do begin

           if n1.HasChildNodes then

           while (c < n1.ChildNodes.Count) do begin
                 if n1.ChildNodes.Item[c].HasAttributes then
                 //showmessage(n1.ChildNodes.Item[n].Attributes.Item[0].NodeValue);
                 if (n1.ChildNodes.Item[c].Attributes.Item[0].NodeValue = 'server') then begin
                 if n=1 then begin

                    tmp:= n1.ChildNodes.Item[c].TextContent;
                    tmp:= copy( tmp, 1, pos('/', tmp)-1);
                 listbox2.Items.Add(tmp);

                 tmp:= n1.ChildNodes.Item[c].TextContent;
                 tmp:= copy( tmp, pos('/', tmp)+1, length(tmp) );

                 if c = 0 then
                 Port.Caption:= tmp;

                 end;
                 lserv[n].serv[c+1]:= n1.ChildNodes.Item[c].TextContent;
                 end;

                 if not globalc.Checked then begin
                 if (n1.ChildNodes.Item[c].NodeName = 'n1') then
                    lserv[n].n1:= n1.ChildNodes.Item[c].TextContent;

                 if (n1.ChildNodes.Item[c].NodeName = 'n2') then
                    lserv[n].n2:= n1.ChildNodes.Item[c].TextContent;


                 if (n1.ChildNodes.Item[c].NodeName = 'n3') then
                    lserv[n].n3:= n1.ChildNodes.Item[c].TextContent;

                 if (n1.ChildNodes.Item[c].NodeName = 'u') then
                    lserv[n].user:= n1.ChildNodes.Item[c].TextContent;

                 if (n1.ChildNodes.Item[c].NodeName = 'rn') then
                    lserv[n].rn:= n1.ChildNodes.Item[c].TextContent;
                 end;

                 if n = 1 then begin
                    nick1.Caption:= lserv[n].n1;
                    nick2.Caption:= lserv[n].n2;
                    nick3.Caption:= lserv[n].n3;
                    userm.Caption:= lserv[n].user;
                    rname.Caption:= lserv[n].rn;
                 end;
           inc(c);
           end;
           c:= 0;

     lserv[n].netw:= n1.NodeName;
     ListBox1.items.Add(n1.NodeName);
     listbox1.ItemIndex:= 0;
     if n = 1 then begin
     netw.Caption:= n1.NodeName;
     serv.Caption:= copy(n1.FirstChild.TextContent, 1, pos('/', n1.FirstChild.TextContent)-1);
     end;

     n1:= n1.NextSibling;
     inc(n);
     end;
     f.Free;
end; // Tlistbox
     nick1.SetFocus;

     ListBox1.Selected[listbox1.Items.Count-1]:= true;
     ListBox1Click(nil);
end;



procedure Tfserv.FormClose(Sender: TObject);
var
   n:   smallint = 1;
   c:   smallint = 1;
   n1,a,b:  TDOMNode;
begin

     if not DirectoryExists(GetEnvironmentVariable('HOME') + '/.config/nchat') then
        mkdir(GetEnvironmentVariable('HOME') + '/.config/nchat');

     f:= TXMLDocument.Create;
     n1:= (f.CreateElement('Networks'));
     f.AppendChild(n1);
     n1:= f.FindNode('Networks');

     while (lserv[n].netw <> '') and (n < 100) do begin
           b:= f.FindNode('Networks');
           a:= (f.CreateElement(lserv[n].netw));
           b.AppendChild(a);

           if n = 1 then
                        n1:= n1.FirstChild else
                        n1:= n1.NextSibling;

           c:= 1;
           while (lserv[n].serv[c] <> '') //and (c < length(lserv[n].serv)) do begin
                 do begin
                 a:= f.CreateElement('s' + inttostr(c));
                 b:= f.CreateTextNode(lserv[n].serv[c]);
                 TDOMElement(a).SetAttribute('name', 'server');
                 a.AppendChild(b);
                 n1.AppendChild(a);
           inc(c);
           end;

           a:= f.CreateElement('n1');
           b:= f.CreateTextNode(lserv[n].n1);
           a.AppendChild(b);
           n1.AppendChild(a);

           a:= f.CreateElement('n2');
           b:= f.CreateTextNode(lserv[n].n2);
           a.AppendChild(b);
           n1.AppendChild(a);

           a:= f.CreateElement('n3');
           b:= f.CreateTextNode(lserv[n].n3);
           a.AppendChild(b);
           n1.AppendChild(a);

           a:= f.CreateElement('u');
           b:= f.CreateTextNode(lserv[n].user);
           a.AppendChild(b);
           n1.AppendChild(a);

           a:= f.CreateElement('rn');
           b:= f.CreateTextNode(lserv[n].rn);
           a.AppendChild(b);
           n1.AppendChild(a);

     inc(n);
     end;
     WriteXML(f, GetEnvironmentVariable('HOME') + '/.config/nchat/nchat.xml');
     f.Free;
end;

procedure Tfserv.adnClick(Sender: TObject);
var
   i: smallint = 1; // record
   s: smallint = 0; // Servers count
begin
     //ShowMessage(inttostr(ListBox1.Items.Count));

     if netw.Caption <> '' then
     while (lserv[i].netw <> netw.Caption) and (lserv[i].netw <> '') and (i < length(lserv)) do inc(i);
           //if (lserv[i].netw <> netw.Caption) and (i < ListBox1.Items.Count) then inc(i);
           if i > 100 then ShowMessage('It is not possible adding more servers') else

           if (i > ListBox1.Items.Count) then
           //if listbox1.Items[i-1] <> netw.Caption then
           ListBox1.Items.Add(netw.Caption);

                lserv[i].netw:= netw.Caption;
                lserv[i].n1:=   nick1.Caption;
                lserv[i].n2:=   nick2.Caption;
                lserv[i].n3:=   nick3.Caption;
                lserv[i].user:= userm.Caption;
                lserv[i].rn:=   rname.Caption;

                // Adding server
                if serv.Caption <> '' then
                if listbox2.Items.Count = 0 then
                   listbox2.items.Add(serv.Caption) else

                while (listbox2.Items[s] <> serv.Caption) and (s < listbox2.Items.Count) do inc(s);

                if ListBox2.Items.Count > 0 then
                      if listbox2.Items[s] <> serv.Caption then
                         listbox2.items.Add(serv.Caption);
                      //ShowMessage(listbox2.GetSelectedText);
                s:= 0;
                while (s < listbox2.Items.Count) do begin
                      listbox2.ItemIndex:= s;
                      lserv[i].serv[s+1]:= ListBox2.GetSelectedText + '/' + Port.Caption;
                inc(s);
                end;

           //end; // Do
     FormClose(adn);
end;

procedure Tfserv.delnClick(Sender: TObject);
var n:    smallint = 0;
begin
     n:= ListBox1.Items.IndexOf(ListBox1.GetSelectedText);
     if n <= ListBox1.Items.Count -1 then inc(n);
     while (n <= ListBox1.Items.Count -1) do begin
           if length(lserv) >= n+1 then lserv[n]:= lserv[n+1];
     inc(n);
     end;

     lserv[n].netw:= '';
     if ListBox1.Items.Count > 0 then
     ListBox1.Items.Delete(ListBox1.Items.IndexOf(ListBox1.GetSelectedText));
end;

procedure Tfserv.ListBox1Click(Sender: TObject);
var n:      smallint = 0;
    s:      smallint = 1; // Server index
    tmp:    string;
begin

           listbox2.Clear;
           while n < fserv.ComponentCount do begin
                 if fserv.Components[n] is TLabeledEdit then
                 TLabeledEdit(fserv.Components[n]).Clear;
           inc(n);
           end;

           n:= ListBox1.Items.IndexOf(listbox1.GetSelectedText) +1;

           while (s < 10) do begin
                 if lserv[n].serv[s] <> '' then begin

                 tmp:= lserv[n].serv[s];
                 tmp:= copy( tmp, 1, pos('/', tmp)-1);

                 listbox2.Items.Add(tmp);

                 tmp:= lserv[n].serv[s];
                 tmp:= copy( tmp, pos('/', tmp)+1, length(tmp) );

                 if s = 1 then
                 Port.Caption:= tmp;

              //lserv[n].serv[s+1]:= n1.ChildNodes.Item[s].TextContent;

              end;
           inc(s);
           end;

           if not globalc.Checked then begin
           nick1.Caption:= lserv[n].n1;
           nick2.Caption:= lserv[n].n2;
           nick3.Caption:= lserv[n].n3;
           userm.Caption:= lserv[n].user;
           rname.Caption:= lserv[n].rn;
           end;

           netw.Caption:= ListBox1.GetSelectedText;
           if listbox2.Items.Count > 0 then ListBox2.ItemIndex:= 0;
           serv.Caption:= ListBox2.GetSelectedText;
end;

procedure Tfserv.ListBox2Click(Sender: TObject);
var a:     string;
begin
     serv.Caption:= ListBox2.GetSelectedText;
     a:= lserv[listbox1.ItemIndex+1].serv[listbox2.ItemIndex+1];
     a:= copy(a, pos('/', a)+1, length(a));
     port.Caption:= a;
end;

procedure Tfserv.newbClick(Sender: TObject);
var
   n: smallint = 0;
begin
     listbox2.Clear;

     if listbox1.Items.Count > 0 then
     while n < fserv.ComponentCount -1 do begin
           if fserv.Components[n] is TLabeledEdit then
           TLabeledEdit(fserv.Components[n]).Clear;
     inc(n);
     end;
end;

procedure Tfserv.AdsClick(Sender: TObject);
begin
     if serv.Caption <> '' then listbox2.items.Add(serv.Caption);
end;

procedure Tfserv.delsClick(Sender: TObject);
var n: smallint = 0;
begin
     if listbox2.Items.Count > 0 then
     ListBox2.Items.Delete(listbox2.Items.IndexOf(listbox2.GetSelectedText));

        while (ListBox2.Items.Count > 0) and (n < ListBox2.Items.Count) do begin
              lserv[ListBox1.ItemIndex +1].serv[n+1]:= ListBox2.Items[n];
        inc(n);
        end;
end;

procedure Tfserv.connbClick(Sender: TObject);
var n:  smallint = 1;
begin
     while (assigned(net[n])) do begin
     inc(n);
     //ShowMessage('con: ' + inttostr(n));
     end;
     net[n]:= connex.create;
     net[n].connect(n-1, True);
     //inc(n);
     //nick1.Text:= 'coccco';
     fserv.Close;
end;


end.

