#ifndef AppVersion
  #error AppVersion must be supplied with /DAppVersion=YY.MM.DD
#endif

[Setup]
AppId={{2C065D99-3AEC-4CE8-A97F-93BA15E78173}
AppName=CS2 Workshop Tools
AppVersion={#AppVersion}
AppPublisher=CS2 Workshop Tools
DefaultDirName={userdocs}\Adobe\Adobe Substance 3D Painter\python\plugins\CS2 Workshop Tools
DisableDirPage=no
UsePreviousAppDir=yes
AppendDefaultDirName=no
PrivilegesRequired=lowest
DisableProgramGroupPage=yes
UninstallDisplayName=CS2 Workshop Tools
OutputDir=..\..\dist
OutputBaseFilename=CS2-Workshop-Tools-{#AppVersion}-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=no
RestartApplications=no
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Files]
Source: "..\..\build\payload\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
