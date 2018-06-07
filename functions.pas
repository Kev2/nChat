unit functions;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, Forms, LCLType, Graphics, SynEdit, SynHighlighterPosition;

type
    tri =   array of smallint;
    tServ = record
            netw:     string;
            serv:     array[1..15] of string; // server address
            n1,n2,n3: string;                 // nicks
            user:     string;                 // User name
            rn:       string;                 // Real name
    end;

type
  csynedit = class(TCustomSynEdit)                  // TCustomSynedit subclass to change SetLines
  private
   FStrings: TStrings;
  public
   BStrings: TStrings;                              // TStrings with characters to be replaces
   hl:       TSynPositionHighlighter;

   constructor Create(AOwner: TComponent); override;
   destructor Destroy; override;
   //procedure SetCursor(Value: TCursor); override;
   //OnMouseUp:= tsynMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;


function replce(r: string): string;
function colors(c: string): TColor;
function icolors(c: TColor): smallint;
function posit(max: smallint): smallint;
function arstat(newnick: string): string;
function univ(Txt, cption: PChar; Flags: longint; sender: tobject): boolean;

implementation

constructor csynedit.Create(AOwner: TComponent);
begin
     inherited create(AOwner);
     BStrings:= TStringList.Create;
     hl:= TSynPositionHighlighter.Create(self);
     self.Highlighter:= hl;
end;

destructor csynedit.Destroy;
begin
     BStrings.Free;
     hl.Free;
     inherited Destroy;
end;

{
procedure csynedit.SetCursor(Value: TCursor);
begin
  if FCursor <> Value then
  begin
    FCursor := Value;
    Perform(CM_CURSORCHANGED, 0, 0);
  end;
end;
}

function replce(r: string): string;
{if channel is needed, the replacement must be given after colon (:)}
var chan: string;
    tmp:  string;
begin
     delete(r, 1, 1);
     chan:= copy(r, pos(':', r)+1, length(r));

     // Join
     if (pos('j', r) = 1) or (pos('J', r) = 1) then begin
        if (pos('j', r) = 1) then r:= StringReplace(r, 'j', 'JOIN', [rfReplaceAll]) else
        r:= StringReplace(r, 'J', 'JOIN', [rfReplaceAll]);
     end;

     // PART
     if (pos(lowercase('part'), lowercase(r)) = 1) then begin
        r:= StringReplace(r, 'part', 'PART', [rfReplaceAll]);
        tmp:= r;
        delete(tmp, 1, pos(' ', tmp));
        if (pos('#', tmp) = 1) then begin
           chan:= copy(tmp, pos('#', tmp), pos(' ', tmp)-1);
           delete(tmp, 1, pos(' ',tmp)); // tmp = message
        end else
            chan:= copy(tmp, pos(':', tmp)+1, length(tmp));
        delete(tmp, pos(':', tmp), length(tmp)); // tmp = message

        if (tmp = '') or (tmp = ' ') or (tmp = chan) then tmp:= 'Leaving';
        //if (pos('#', chan) > 0) then
           r:= 'PART ' + chan + ' :' + tmp;
     end;

     // Topic
     if (pos(lowercase('topic'),r) = 1) then begin
     //r:= 'topic ' + chan + ' :Topic is: ' + char(2) + char(3) + '1,11 Bienvenidos al canal ' + char(3) +'0,13 #LC-Argentina' + char(15) + char(2) + char(3) + '1 Ahora podes chatear desde ' + char(15) + char(2) + char(3) + '1,3Kiwi ' + char(15) + char(3) + char(2) + char(2) + char(3) + '1en ' + char(2) + char(3) + '12http://canalargentina.net/kiwi ' + char(15) + char(3) + char(2) + char(2) + char(3) + char(2) + char(3) + '1 y desde ' + char(15) + char(2) + char(3) + '4,14Mibbit' + char(15) + char(3) + char(2) + char(2) + char(3) + char(2) + char(3) + '1 desde ' + char(15) + char(2) + char(3) + '12http://canalargentina.net/mibbit' + char(15);
     //r:= char(3) + '4' + char(2) + '2018 minus 3 days away If you have anyone that cant join #Chat because of our modes.. please tell him to register his/her nickname and its gonna be fine For help come to #helpcome to #helpcome to #helpcome to #helpcome to #helpcome to #helpcome to #helpcome :D :p to #help' + ':' + '#nvz';

     delete(r, 1, length('topic')+1);
     if r[1] = '#' then delete(r, pos(':',r), length(r));

     // Channel
     if r[1] = '#' then chan:= copy(r, 1, pos(' ', r)-1) else begin
        chan:= r;
        while (pos(':', chan) > 0) do delete(chan, 1, pos(':', chan));
     end;

     // Message
     if (pos(': :', r) > 0) then tmp:= ':' else
     if r[1] = '#' then tmp:= copy(r, pos(' ',r)+1, length(r)) else
        tmp:= copy(r, 1, pos(':',r)-1);

     if tmp = ':' then r:= 'TOPIC ' + chan + ' :' else
     if tmp <> '' then
        r:= 'TOPIC ' + chan + ' :' + tmp else
        r:= 'TOPIC ' + chan;
     end;

     // Mode
     if (pos('mode', lowercase(r)) = 1) then begin
        delete(r, pos(':',r)-1, length(r));
        r:= StringReplace(r, 'mode','MODE',[rfReplaceAll]);
     end;


     // Notice
     if (pos('notice', lowercase(r)) = 1) then begin
        tmp:= copy(r, pos(' ', r)+1, length(r));
        delete(tmp, 1, pos(' ', tmp));
        delete(r, pos(tmp, r), length(r));
        r:= StringReplace(r, 'notice', 'NOTICE', [rfReplaceAll]) + ':' + tmp;
     end;

     // INVITE
     if (pos(lowercase('invite'), r) = 1) then begin
        r:= StringReplace(r, 'invite', 'INVITE', [rfReplaceAll]);
        delete(r, pos(':', r), length(r));
        r:= r + ' ' + chan;
     end;

     // INVITE SENT                            // mcclane #chan
     if (pos(lowercase('invite'), r) = 1) then begin
        delete(r, 1, pos(' ', r)); delete(r, 1, pos(' ', r));
        r:= 'You have invited ' + copy(r, 1, pos(' ' , r)) + copy(r, pos('#', r), length(r));
     end;

     // /me              /me dances~sollo
     if (pos('me', lowercase(r)) = 1) or (pos('me', lowercase(r)) = 2) then begin
        if pos('me', lowercase(r)) = 1 then tmp:= '1';
        r:= StringReplace(r, ' me', '', [rfReplaceAll]);
        r:= StringReplace(r, 'me', '', [rfReplaceAll]);
        // nick: baila
        //delete(r, pos(':', r), 1);
        if tmp = '1' then begin
           // Show local
           r:= '* ' + copy(r, pos('~', r)+1, length(r)) + copy(r, 1, pos('~', r)-1);
           tmp:= 'no13';
        end else
        // Send to server
           r:= char(1) + 'ACTION' + r + char(1);
           delete(r, pos('~', r), Length(r));
     end;

     // Query: example /query hola no way
     // Getting the first word after /query
     if (pos('query', lowercase(r)) = 1) then begin
        delete(r, 1, pos(' ',r));
        delete(r, pos(' ',r), length(r));
        if (r = '') or (r = ' ') or (r = '  ') or (lowercase(r) = 'query') then r:= 'noquery';
     tmp:= 'no13';
     end;

     // Voice
     if (pos(lowercase('voice'), r) = 1) then begin
        r:= StringReplace(r, 'voice', 'MODE ' + copy(r, pos('#',r), length(r)) + ' +v', [rfReplaceAll]);
        delete(r, pos(':',r), length(r));
     end;
     if (pos(lowercase('devoice'), r) = 1) then begin
        r:= StringReplace(r, 'devoice', 'MODE ' + copy(r, pos('#',r), length(r)) + ' -v', [rfReplaceAll]);
        delete(r, pos(':',r), length(r));
     end;

     // OP
     if (pos(lowercase('op'), r) = 1) then begin
        r:= StringReplace(r, 'op', 'MODE ' + copy(r, pos('#',r), length(r)) + ' +o', [rfReplaceAll]);
        ///MODE #nvx:/op Sol Sollo
        delete(r, pos(':',r), length(r));
     end;
     if (pos(lowercase('deop'), r) = 1) then begin
        r:= StringReplace(r, 'deop', 'MODE ' + copy(r, pos('#',r), length(r)) + ' -o', [rfReplaceAll]);
        ///MODE #nvx:/op Sol Sollo
        delete(r, pos(':',r), length(r));
     end;

     // HOP // Gives/Removes half op status
     if (pos(lowercase('hop'), r) = 1) then begin
        r:= StringReplace(r, 'hop', 'MODE ' + copy(r, pos('#',r), length(r)) + ' +h', [rfReplaceAll]);
        ///MODE #nvx:/op Sol Sollo
        delete(r, pos(':',r), length(r));
     end;
     if (pos(lowercase('dehop'), r) = 1) then begin
        r:= StringReplace(r, 'dehop', 'MODE ' + copy(r, pos('#',r), length(r)) + ' -h', [rfReplaceAll]);
        ///MODE #nvx:/op Sol Sollo
        delete(r, pos(':',r), length(r));
     end;

     // KICK
     if (pos(lowercase('kick'), r) = 1) then begin
        // /kick mcclane fuera de aqui :#nvz
        // /kick #nvz mcclane fuera de aqui :#nvz
        chan:= r;
        delete(chan, 1, pos(' ', chan));
        if (pos('#', chan) = 1) then delete(chan, pos(' ', chan), length(chan)) else begin
           while (pos(':', chan) > 0) do delete(chan, 1, pos(':', chan));
        end;

        tmp:= r;
        while (pos(':', tmp) > 0) do delete(tmp, 1, pos(':', tmp));
        delete(r, length(r)-(length(tmp)+1), length(tmp)+2);

        //while (r[length(r)] = ':') or (r[length(r)] = ' ') do delete(r, length(r), 1);

        // Kick #chan mcclane fuera de aqui
        tmp:= r; // Kick #nvz mcclane
        delete(tmp, 1, pos(' ', tmp));
        if (pos('#', tmp) = 1) then delete(tmp, 1, pos(' ', tmp));
        chan:= chan + ' ' + copy(tmp, 1, pos(' ', tmp));   // Channel + nick
        delete(tmp, 1, pos(' ', tmp));
        //delete(r, length(r) - length(tmp)+1, length(tmp)+2);

        r:= 'KICK ' + chan + ':' + tmp;
     end;

     // BAN
     if (pos(lowercase('ban'), r) = 1) then begin //ban m:nick :#chan
        chan:= r;
        while (pos(':', chan) > 0) do delete(chan, 1, pos(':', chan));
        delete(r, pos(chan, r), length(chan));
        r:= StringReplace(r, 'ban', 'MODE ' + chan + ' +b', [rfReplaceAll]);
        ///MODE #nvx:/op Sol Sollo
        //delete(r, pos('#',r)-2, length(r));
     end;
     if (pos(lowercase('unban'), r) = 1) then begin
        r:= StringReplace(r, 'unban', 'MODE ' + copy(r, pos('#',r), length(r)) + ' -b', [rfReplaceAll]);
        ///MODE #nvx:/op Sol Sollo
        //delete(r, pos('#',r)-2, length(r));
     end;
     if tmp = 'no13' then result:= r else result:= r + #13#10;
end;

function arstat(newnick: string): string;
{arstat stands for arrange statuses
Sorts statuses in this order ~@%+}
var
   stat:   string = '!~&@%+';
   n:      smallint = 1;
   tmp:    string = '';
   t:      char;
   ch:     boolean = false;
begin
     //newnick:= '+@~hola';
     // Adding stat to tmp
     while (n < length(newnick)) do begin
           if (pos(newnick[n], stat) > 0) then tmp:= newnick[n] + tmp;
     inc(n);
     end;

     // Sorting
     repeat
       ch:= false;
       n:= 1;
     while (n < length(tmp)) do begin
           //ShowMessage(inttostr(ord(tmp[n+1])) + ' n: ' + inttostr(ord(tmp[n])));
           if ( ord(tmp[n+1]) > ord(tmp[n]) ) then begin //or ( (ord(tmp[n+1]) < (ord(tmp[n]))) and (tmp[n] = '+') ) then begin
              t:= tmp[n];
                 tmp[n]:= tmp[n+1];
                 tmp[n+1]:= t;
                 ch:= true;
           end;
     inc(n);
     end;
     until ch = false;

     {The ascii code of + is higher than %, so let's move it to the end}
     if (pos('+', tmp) > 0) then begin
        tmp:= StringReplace(tmp, '+', '', [rfReplaceAll]);
        tmp:= tmp + '+';
     end;

     result:= tmp + copy(newnick, length(tmp)+1, length(newnick));
end;

function colors(c: string): TColor;
begin
     if c = '0' then result:= clWhite;
     if c = '1' then result:= clBlack;
     if c = '2' then result:= clNavy;
     if c = '3' then result:= clGreen;
     if c = '4' then result:= clRed;
     if c = '5' then result:= clMaroon;
     if c = '6' then result:= clPurple;
     if c = '7' then result:= clOlive;
     if c = '8' then result:= clYellow;
     if c = '9' then result:= clLime;
     if c = '10' then result:= clTeal;
     if c = '11' then result:= clAqua;
     if c = '12' then result:= clBlue;
     if c = '13' then result:= clFuchsia;
     if c = '14' then result:= clGray;
     if c = '15' then result:= clSilver;
     if c = '16' then result:= clWhite;
end;

function icolors(c: TColor): smallint;
begin
     if c = clWhite then result:= 0;
     if c = clBlack then result:= 1;
     if c = clNavy then result:= 2;
     if c = clGreen then result:= 3;
     if c = clRed then result:= 4;
     if c = clMaroon then result:= 5;
     if c = clPurple then result:= 6;
     if c = clOlive then result:= 7;
     if c = clYellow then result:= 8;
     if c = clLime then result:= 9;
     if c = clTeal then result:= 10;
     if c = clAqua then result:= 11;
     if c = clBlue then result:= 12;
     if c = clFuchsia then result:= 13;
     if c = clGray then result:= 14;
     if c = clSilver then result:= 15;
end;

function posit(max: smallint): smallint;
const
     las: array of smallint = nil;
     p:   smallint = 0;
begin
     if max = 0 then inc(p);
     las[p]:= max;
     //result:= inc(las[p]);

end;

// Universal Ok
function univ(Txt, cption: PChar; Flags: longint; sender: tobject): boolean;
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

