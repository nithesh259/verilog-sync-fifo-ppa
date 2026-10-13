$ErrorActionPreference = "Stop"

Write-Host "====================================="
Write-Host " Synchronous FIFO Regression Tests"
Write-Host "====================================="

# Run from the repository root.
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# Ensure output directories exist.
New-Item -ItemType Directory -Force -Path ".\sim" | Out-Null
New-Item -ItemType Directory -Force -Path ".\waveforms" | Out-Null

# Compile RTL and testbench.
Write-Host "`n[1/2] Compiling FIFO..."
iverilog -g2012 -Wall -o ".\sim\fifo_sim.vvp" ".\rtl\sync_fifo.v" ".\tb\tb_sync_fifo.v"

if ($LASTEXITCODE -ne 0) {
    throw "Compilation failed."
}

# Execute the simulation.
Write-Host "`n[2/2] Running simulation..."
vvp ".\sim\fifo_sim.vvp"

if ($LASTEXITCODE -ne 0) {
    throw "Simulation execution failed."
}

Write-Host "`nRegression simulation finished."
