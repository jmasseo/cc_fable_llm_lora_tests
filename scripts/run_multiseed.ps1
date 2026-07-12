param(
    [string] $PythonBin = $env:PYTHON,
    [int] $Steps = 200,
    [int[]] $Seeds = @(0, 1, 2, 3, 4, 5, 6, 7, 8, 9),
    [string] $OutDir = "artifacts"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($PythonBin)) {
    $PythonBin = "python"
}
if ($env:STEPS) {
    $Steps = [int] $env:STEPS
}
if ($env:SEEDS) {
    $Seeds = @($env:SEEDS -split "[,\s]+" | Where-Object { $_ } | ForEach-Object { [int] $_ })
}
if ($env:OUT_DIR) {
    $OutDir = $env:OUT_DIR
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

function Invoke-PythonStep {
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Arguments
    )

    & $PythonBin @Arguments
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

Push-Location $RepoRoot
try {
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    Write-Host "Writing seed artifacts under $OutDir"
    Write-Host "Python: $PythonBin"
    Write-Host "Steps: $Steps"
    Write-Host "Seeds: $($Seeds -join ' ')"

    foreach ($Seed in $Seeds) {
        Invoke-PythonStep @(
            "scripts/evaluate_sequence.py",
            "--steps", "$Steps",
            "--seed", "$Seed",
            "--out", "$OutDir/sequence_seed_$Seed.json"
        )

        Invoke-PythonStep @(
            "scripts/run_controller.py",
            "--steps", "$Steps",
            "--seed", "$Seed",
            "--anchor", "1.0",
            "--out", "$OutDir/controller_anchor_seed_$Seed.json"
        )
    }
}
finally {
    Pop-Location
}
