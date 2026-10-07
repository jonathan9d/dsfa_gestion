; ============================================================
;  DSFA Gestion - Script d'installation (Inno Setup 6+)
;  Empaquette le build Windows Release de l'application Flutter.
;
;  Compilation :
;    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\dsfa_gestion.iss
;  (ou lancer compile_installer.cmd à la racine du projet)
; ============================================================

#define MonApp       "DSFA Gestion"
#define MonVersion   "1.1.1"
#define MonEditeur   "DSFA / UNICEF"
#define MonExe       "dsfa_gestion.exe"
#define DossierBuild "..\build\windows\x64\runner\Release"

[Setup]
AppId={{8F3B2C1A-4D5E-4A6B-9C7D-A1B2C3D40001}
AppName={#MonApp}
AppVersion={#MonVersion}
AppVerName={#MonApp} {#MonVersion}
AppPublisher={#MonEditeur}
DefaultDirName={autopf}\{#MonApp}
DefaultGroupName={#MonApp}
UninstallDisplayName={#MonApp}
UninstallDisplayIcon={app}\{#MonExe}
OutputDir=..\build\installer
OutputBaseFilename=DSFA_Gestion_Setup_{#MonVersion}
SetupIconFile=..\windows\runner\resources\app_icon.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
ArchitecturesAllowed=x64compatible
MinVersion=10.0
; Installation sans droits admin par defaut (dossier utilisateur),
; mais l'utilisateur peut choisir "Pour tous les utilisateurs" dans l'assistant.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog commandline

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "bureauepingle"; Description: "Creer un raccourci sur le Bureau"; GroupDescription: "Raccourcis :"
Name: "demenudemarrage"; Description: "Creer un raccourci dans le menu Demarrer"; GroupDescription: "Raccourcis :"

[Files]
Source: "{#DossierBuild}\{#MonExe}";        DestDir: "{app}"; Flags: ignoreversion
Source: "{#DossierBuild}\*.dll";             DestDir: "{app}"; Flags: ignoreversion
Source: "{#DossierBuild}\native_assets.json"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#DossierBuild}\data\*";            DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MonApp}";                 Filename: "{app}\{#MonExe}"; Tasks: demenudemarrage
Name: "{group}\Desinstaller {#MonApp}";    Filename: "{uninstallexe}"; Tasks: demenudemarrage
Name: "{autodesktop}\{#MonApp}";           Filename: "{app}\{#MonExe}"; Tasks: bureauepingle

[Run]
Filename: "{app}\{#MonExe}"; Description: "Lancer {#MonApp} maintenant"; Flags: nowait postinstall skipifsilent
