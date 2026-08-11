# WetEvents — Global Vegetation GPP Sensitivity, Resistance, and Resilience to Wet Events

MATLAB (+ shell/GDAL) pipeline supporting a global analysis of vegetation gross primary
productivity (GPP) responses to wet events, identified from SPEI-03, over the historical
period 2001–2022, and projected under CMIP6 future scenarios (SSP1-2.6/2-4.5/3-7.0/5-8.5,
2071–2100).


Scripts are numbered `Proc##_Name.m` in strict execution order; each stage reads the prior
stage's `../output/NN_.../` (or raw `../input/`) and writes `../output/(N+1)_.../`. Every
`Proc##` script **deletes and recreates its own output folder** on each run
(`rm -rf` + `mkdir -p`), so re-running a stage is idempotent but destroys that stage's prior
output — never point two stages at the same output folder.


## Main processing stages

**1. Historical preprocessing & analysis (Proc00–Proc11)** — observation-based, 2001–2022:
CRU-TS climatology → MOD17 monthly GPP time series → SPEI-to-GeoTIFF conversion → SPEI-03
time series masked to natural vegetation → monthly GPP "normal" baseline → GPP
**sensitivity** to wet events → **resistance** (Ω) and **resilience** (Δ) per wet-event
severity level → multi-year aggregation of each metric → Mann-Kendall/Sen-slope trend
analysis → biome-level summary statistics.

**2. CMIP6 preprocessing (Proc11a–Proc16)** — converts raw per-model CMIP6 GPP NetCDF
(historical and SSP scenarios) to GeoTIFF, applies bias adjustment, and regrids CMIP6 GPP
and SPEI outputs from their native resolution to 0.5°.

**3. Future (CMIP6-based) analyses (Proc17–Proc26)** — mirrors the historical pipeline
(GPP normalization → sensitivity → resistance/resilience → aggregation) applied to each
CMIP6 model and SSP scenario for a 1981–2010 baseline vs. 2071–2100 future period; computes
the future minus baseline change (Δ) per model, the multi-model-ensemble mean (MME) across
models, and aggregates results to the country scale.

## Recommended execution order

Within each stage, run scripts strictly by their numeric prefix. High-level order:

```
Proc00 → Proc01 → Proc02 → Proc03 → Proc04 → Proc05 → Proc06 → Proc07 → Proc08 → Proc09
  → Proc10 → Proc11                                   (historical pipeline)

Proc11a/b/c → Proc12a/b/c → Proc13 → Proc14 (.sh) → Proc15 → Proc16 (.sh)
  → Proc17 → Proc18 → Proc19 → Proc20 → Proc21 → Proc22
  → Proc23/23b → Proc24/24b → Proc25/25b → Proc26a/b/c      (CMIP6 pipeline)
```


## Software requirements

- MATLAB (tested on R2024a) with the Mapping Toolbox (`readgeoraster`, `geotiffinfo`,
  `geoshow`, `shaperead`) and Statistics and Machine Learning Toolbox (`corr`, `prctile`).
- `addpath(genpath('./'))` (called at the top of every script) to load the bundled
  `code/program_2025b` utility toolbox (trend statistics, custom plotting/colormap helpers).
- GDAL (`gdalwarp`) and a POSIX shell for the `.sh` regridding scripts (Proc14, Proc16, and
  the input-preprocessing scripts under `input/`).

