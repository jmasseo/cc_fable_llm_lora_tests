param(
    [string] $PythonBin = $env:PYTHON,
    [string] $OutRoot = "artifacts/sweeps",
    [int] $Steps = 200,
    [int[]] $Seeds = @(0, 1, 2, 3, 4, 5, 6, 7, 8, 9),
    [int[]] $KValues = @(4, 8, 16, 32),
    [double[]] $OrthoValues = @(0, 0.1, 1.0),
    [int[]] $TaskCounts = @(2, 3, 4, 5, 6)
)

$ErrorActionPreference = "Stop"

function Split-ValueList {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Value
    )
    return @($Value -split "[,\s]+" | Where-Object { $_ })
}

function Format-InvariantFloat {
    param(
        [Parameter(Mandatory = $true)]
        [double] $Value
    )
    return $Value.ToString("G", [System.Globalization.CultureInfo]::InvariantCulture)
}

if ([string]::IsNullOrWhiteSpace($PythonBin)) {
    $PythonBin = "python"
}
if ($env:OUT_ROOT) {
    $OutRoot = $env:OUT_ROOT
}
if ($env:STEPS) {
    $Steps = [int] $env:STEPS
}
if ($env:SEEDS) {
    $Seeds = @(Split-ValueList $env:SEEDS | ForEach-Object { [int] $_ })
}
if ($env:K_VALUES) {
    $KValues = @(Split-ValueList $env:K_VALUES | ForEach-Object { [int] $_ })
}
if ($env:ORTHO_VALUES) {
    $OrthoValues = @(Split-ValueList $env:ORTHO_VALUES | ForEach-Object { [double] $_ })
}
if ($env:TASK_COUNTS) {
    $TaskCounts = @(Split-ValueList $env:TASK_COUNTS | ForEach-Object { [int] $_ })
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

function Invoke-SequenceRun {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Out,
        [string[]] $ExtraArgs = @()
    )

    $Arguments = @(
        "scripts/evaluate_sequence.py",
        "--steps", "$Steps"
    ) + $ExtraArgs + @(
        "--out", $Out
    )
    Invoke-PythonStep $Arguments
}

function Invoke-ControllerRun {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Out,
        [string[]] $ExtraArgs = @()
    )

    $Arguments = @(
        "scripts/run_controller.py",
        "--steps", "$Steps"
    ) + $ExtraArgs + @(
        "--out", $Out
    )
    Invoke-PythonStep $Arguments
}

Push-Location $RepoRoot
try {
    New-Item -ItemType Directory -Force -Path $OutRoot | Out-Null

    Write-Host "Writing sweep artifacts under $OutRoot"
    Write-Host "Python: $PythonBin"
    Write-Host "Steps: $Steps"
    Write-Host "Seeds: $($Seeds -join ' ')"

    Write-Host ""
    Write-Host "== Seed sweep: full suite + anchored controller =="
    New-Item -ItemType Directory -Force -Path "$OutRoot/seed" | Out-Null
    foreach ($Seed in $Seeds) {
        Invoke-SequenceRun "$OutRoot/seed/sequence_seed_$Seed.json" @(
            "--seed", "$Seed"
        )
        Invoke-ControllerRun "$OutRoot/seed/controller_anchor_seed_$Seed.json" @(
            "--seed", "$Seed",
            "--anchor", "1.0"
        )
    }

    Write-Host ""
    Write-Host "== K sweep: full suite over n_components =="
    New-Item -ItemType Directory -Force -Path "$OutRoot/k" | Out-Null
    foreach ($K in $KValues) {
        foreach ($Seed in $Seeds) {
            Invoke-SequenceRun "$OutRoot/k/sequence_k_${K}_seed_$Seed.json" @(
                "--seed", "$Seed",
                "--n-components", "$K"
            )
        }
    }

    Write-Host ""
    Write-Host "== Ortho sweep: controller only =="
    New-Item -ItemType Directory -Force -Path "$OutRoot/ortho" | Out-Null
    foreach ($Ortho in $OrthoValues) {
        $OrthoText = Format-InvariantFloat $Ortho
        $Tag = $OrthoText.Replace(".", "p")
        foreach ($Seed in $Seeds) {
            Invoke-ControllerRun "$OutRoot/ortho/controller_ortho_${Tag}_seed_$Seed.json" @(
                "--seed", "$Seed",
                "--ortho", "$OrthoText"
            )
        }
    }

    Write-Host ""
    Write-Host "== No-gates ablation: controller only =="
    New-Item -ItemType Directory -Force -Path "$OutRoot/no_gates" | Out-Null
    foreach ($Seed in $Seeds) {
        Invoke-ControllerRun "$OutRoot/no_gates/controller_no_gates_seed_$Seed.json" @(
            "--seed", "$Seed",
            "--no-gates"
        )
        Invoke-ControllerRun "$OutRoot/no_gates/controller_anchor_no_gates_seed_$Seed.json" @(
            "--seed", "$Seed",
            "--anchor", "1.0",
            "--no-gates"
        )
    }

    Write-Host ""
    Write-Host "== Task-count sweep: full suite =="
    New-Item -ItemType Directory -Force -Path "$OutRoot/task_count" | Out-Null
    foreach ($NTasks in $TaskCounts) {
        $FactsPerTask = 4
        if ($NTasks -gt 4) {
            $FactsPerTask = 3
        }
        foreach ($Seed in $Seeds) {
            Invoke-SequenceRun "$OutRoot/task_count/sequence_tasks_${NTasks}_facts_${FactsPerTask}_seed_$Seed.json" @(
                "--seed", "$Seed",
                "--n-tasks", "$NTasks",
                "--facts-per-task", "$FactsPerTask"
            )
        }
    }

    Write-Host ""
    Write-Host "Done. Aggregate with scripts/summarize_sweeps.py or the narrower seed-only summarizer."
}
finally {
    Pop-Location
}
