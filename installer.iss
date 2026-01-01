#define AppName "CS2 SP Worskhop Tools"
#define AppVersion "1.0.0b"

[Setup]
AppName={#AppName}
AppVersion={#AppVersion}
DefaultDirName={localappdata}\{#AppName}
DisableProgramGroupPage=yes
OutputDir={#SourcePath}\Output
OutputBaseFilename={#AppName}_Setup
Compression=lzma2
SolidCompression=yes
Uninstallable=yes

[Messages]
WelcomeLabel1=Welcome to {#AppName}
WelcomeLabel2=This installer is a self-extracting archive.%n%nIt packs the contents of the build folder into one setup.exe and, when run, simply extracts everything to the folder you choose.%n%nNo shortcuts or system integration are created.
SelectDirLabel3=Select the folder where the packaged files will be extracted.
ReadyLabel1=Setup is ready to extract files.
ReadyLabel2=Click Install to extract the packaged files to the selected folder.%n%nUninstall will remove the entire installation folder you selected.

[Files]
Source: "{#SourcePath}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "Output\*,*.iss,*.pdb,*.log,*.tmp,Thumbs.db,desktop.ini,.git\*,.github\*"

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
