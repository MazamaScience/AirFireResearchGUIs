# Bluesky plot with WRF vectors (only for PNW model runs)

# ===== GUI parameters =========================================================

# NOTE:  WRF data is only available for PNW model runs during the past week

# Shared parameters
modelName <- "PNW-4km"
modelRun <- "2021031200"
modelMode <- "forecast"

# * Potential GUI parameters -----

# NOTE:  Will will probably have only a few, pre-determined areas

# Washington bounding box
stateCode <- "WA"
xlim = c(-125, -116)
ylim = c(45, 50)

# Oregon bounding box
# stateCode <- "OR"
# xlim = c(-125, -116)
# ylim = c(41, 47)

# WRF-only parameters
modelRunHour <- 24
varNames <- c("U10", "V10")   #  Wind vector components
res <- 0.1                    # Use res = 0.1 for state-sized regions

# ===== BEGIN plot =============================================================

# ----- Setup ------------------------------------------------------------------

library(MazamaSpatialUtils)
library(AirFireModeling)
library(AirFireWRF)
library(AirFirePlots)
library(raster)

MazamaSpatialUtils::setSpatialDataDir("~/Data/Spatial")
loadSpatialData("NaturalEarthAdm1")

AirFireModeling::setModelDataDir("~/Data/BlueSky")
AirFireWRF::setWRFDataDir("~/Data/WRF")

# ----- Load Bluesky data ------------------------------------------------------

bluesky <- bluesky_load(
  modelName = modelName,
  modelRun = modelRun,
  modelMode = modelMode,       # Always use 'forecast'
  xlim = xlim,
  ylim = ylim
)

# ----- Load WRF data ----------------------------------------------------------

# NOTE:  Appears to complete but stops with the following warnings:
# NOTE:
# NOTE:  Error in value[[3L]](cond) : Error downloading: PNW-4km
# NOTE:  In addition: Warning messages:
# NOTE:  1: In utils::download.file(url = fileUrl, destfile = filePath, quiet = !verbose) :
# NOTE:    downloaded length 208584704 != reported length 367002144
# NOTE:  2: In utils::download.file(url = fileUrl, destfile = filePath, quiet = !verbose) :

# Could either: 1) solve properly in AirFireWRF
#           or: 2) just put this in a try block for now

wrf <- wrf_load(
  modelName = modelName,
  modelRun = modelRun,
  modelRunHour = modelRunHour,
  varNames = varNames,
  res = res,
  xlim = xlim,
  ylim = ylim
)

# ----- PLot -------------------------------------------------------------------

gg <- plot_base(
  title = sprintf("Bluesky Forecast for hour %d", modelRunHour),
  xlab = "Longitude",
  ylab = "Latitude",
  clab = NULL,
  flab = "PM2.5",
  xlim = xlim,
  ylim = ylim,
  ratio = 1.4,                # Appropriate for Washington
  expand = FALSE
) +
  layer_raster(
    raster = bluesky[[modelRunHour]],
    varName = NULL,
    naRemove = FALSE,
    breaks = c(0, 1, 2, 5, 10, 25, 50, 100, Inf),
    alpha = 1
  ) +
  layer_counties(
    lineWidth = 0.3,
    color = "gray80",
    fill = "transparent",
    xlim = xlim,
    ylim = ylim
  ) +
  layer_states(
    stateCodes = c(stateCode),
    xlim = xlim,
    ylim = ylim,
    lineWidth = 0.5,
    color = "firebrick",
    fill = "transparent",
  ) +
  layer_vectorField(
    raster = wrf,
    uName = "U10",
    vName = "V10",
    #arrowCount = 1000,
    #arrowScale = 0.05,
    #headLength = ggplot2::unit(0.05, "inches"),
    #headAngle = 60,
    #lineWidth = 0.3,
    color = "blue",
    alpha = 0.6,
    xlim = xlim,
    ylim = ylim
  ) +
  ggplot2::scale_fill_brewer(
    palette = "Greys",
    na.value = "transparent"
  )

print(gg)


