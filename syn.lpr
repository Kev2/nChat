program syn;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, mainc, servf, banlist, kmessf, joinf,
  laz_synapse, functions, chanlist;

{$R *.res}

begin
     Application.Title:='n-Chat';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(Tfmainc, fmainc);
  Application.CreateForm(Tfclist, fclist);
  Application.CreateForm(Tfbanlist, fbanlist);
  Application.CreateForm(Tfkickmess, fkickmess);
  Application.CreateForm(Tfjoin, fjoin);
  Application.CreateForm(Tfserv, fserv);
  Application.Run;
end.

