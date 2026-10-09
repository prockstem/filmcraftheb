# Builds the Hebrew Epic Film and Epic PDF from source (in %USERPROFILE%\EpicBuild) into D:\EPIC EDITORS, with Desktop shortcuts.
# Needs Git, Rust (rustup) and the Visual Studio C++ build tools. Git and Rust are installed with winget
# when missing. Run it again later to update both apps.
foreach ($tool in @(@{ Cmd = 'git'; Id = 'Git.Git' }, @{ Cmd = 'cargo'; Id = 'Rustlang.Rustup' })) {
  if (-not (Get-Command $tool.Cmd -ErrorAction SilentlyContinue)) { winget install -e --id $tool.Id }
}
$root = 'D:\EPIC EDITORS'
# Sources and build files stay on C: (some systems block git from writing to other drives); only
# the finished apps are copied to $root.
$build = Join-Path $HOME 'EpicBuild'
New-Item -ItemType Directory -Force $build, $root | Out-Null
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
$apps = @(
  @{ Name = 'Epic Film'; Branch = 'claude/nice-ride-xviqu7'; Dir = 'EpicFilm'; Pkg = 'filmcraft' },
  @{ Name = 'Epic PDF';  Branch = 'epic-pdf';                Dir = 'EpicPDF';  Pkg = 'pdfcraft' }
)
foreach ($a in $apps) {
  $src = Join-Path $build $a.Dir
  if (Test-Path "$src\.git") { git -C $src fetch --depth 1 origin $a.Branch; git -C $src reset --hard FETCH_HEAD }
  else { git clone -b $a.Branch --depth 1 https://github.com/prockstem/filmcraftheb $src }
  Push-Location $src; cargo build --release -p $a.Pkg; $ok = ($LASTEXITCODE -eq 0); Pop-Location
  if (-not $ok) { Write-Host "$($a.Name): build failed (see the messages above)" -ForegroundColor Red; continue }
  $dest = Join-Path $root $a.Name
  New-Item -ItemType Directory -Force $dest | Out-Null
  Copy-Item "$src\target\release\$($a.Pkg).exe" "$dest\$($a.Name).exe" -Force
  $lnk = (New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path ([Environment]::GetFolderPath('Desktop')) "$($a.Name).lnk"))
  $lnk.TargetPath = "$dest\$($a.Name).exe"; $lnk.WorkingDirectory = $dest; $lnk.Save()
  Write-Host "$($a.Name) is ready: $dest\$($a.Name).exe" -ForegroundColor Green
}
