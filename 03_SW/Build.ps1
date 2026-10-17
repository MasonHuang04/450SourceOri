$ErrorActionPreference = 'Stop'
$candidates = @(
    (Join-Path $env:ProgramFiles 'Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/MSBuild.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/2022/BuildTools/MSBuild/Current/Bin/MSBuild.exe')
)
$builder = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (!$builder) { throw 'Install Visual Studio 2022 .NET desktop build tools and the .NET Framework 4.8 targeting pack, or open the solution in Visual Studio.' }
foreach ($configuration in @('Release', 'Debug')) {
    & $builder (Join-Path $PSScriptRoot 'UsMimoTestBench/UsMimoTestBench.csproj') /p:Configuration=$configuration /p:Platform=AnyCPU /nologo /verbosity:minimal
    if ($LASTEXITCODE -ne 0) { throw 'Build failed.' }
}
