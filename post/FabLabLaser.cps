/**
  Copyright (C) 2015 by Autodesk, Inc.
  All rights reserved.

  $Revision: 41602 8a235290846bfe71ead6a010711f4fc730f48827 $
  $Date: 2017-09-14 12:16:32 $

  FORKID {2E27B627-115A-4A16-A853-5B9B9D9AF480}
*/

description = "FabLab laser";
vendor = "Robotika Brno";
vendorUrl = "https://robotikabrno.cz";
certificationLevel = 2;

longDescription = "Post processor for Trotec laser in FabLab Brno. Based on Glowforge post processor.";

extension = "svg";
mimetype = "image/svg+xml";
setCodePage("utf-8");

capabilities = CAPABILITY_JET;

minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
allowHelicalMoves = true;
allowedCircularPlanes = (1 << PLANE_XY); // only XY arcs

properties = {
  generateStock: true,
  width: 500, // width in mm used when useWCS is disabled
  height: 400, // height in mm used when useWCS is disabled
  spacing: 10,
  lineWidth: 0.1
};

// user-defined property definitions
propertyDefinitions = {
  generateStock: {title:"Generate stock", description:"Generate rectangular stock shape", type:"boolean"},
  width: {title:"Stock width(mm)", description:"Width of stock in mm", type:"number"},
  height: {title:"Stock height(mm)", description:"Height of stock in mm", type:"number"},
  spacing: {title:"Spacing", description:"Specify space between the components", type:"number"},
  lineWidth: {title:"Line width", description:"Width of lines in SVG document", type:"number"}
};

var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4)});

// State
outputState = {
  xOffset: 0,
  yOffset: 0,
  zeroXOffset: 0,
  zeroYOffset: 0,
  wcsXOffset: 0,
  wcsYOffset: 0,
  maxX: 0,
  maxY: 0,
  minX: 0,
  minY: 0,
  lastPos: getCurrentPosition(),
  indent: 0,
  text: "",
  pendingRapid: "",
  start: { x: 0, y: 0 },
  openedGroup: false,
  stock: {
    lower: { x: 0, y: 0 },
    upper: { x: 0, y: 0 }
  },
  prevStock:  {
    lower: { x: 0, y: 0 },
    upper: { x: 0, y: 0 }
  },
  openJob: null,
  patternStart: null,
  patternCounter: 0,
  initialPosition: null
};

/** Returns the given spatial value in MM. */
function toMM(value) {
  return value * ((unit == IN) ? 25.4 : 1);
}

function indent() {
  return new Array(outputState.indent * 4 + 1).join( " " );
}

function tX(x) {
  var xx = x + outputState.xOffset - outputState.zeroXOffset - outputState.wcsXOffset;
  outputState.maxX = Math.max(outputState.maxX, xx);
  outputState.minX = Math.min(outputState.minX, xx);
  return xx;
}

function tY(y) {
  var yy = -(y + outputState.yOffset + outputState.zeroYOffset - outputState.wcsYOffset);
  outputState.maxY = Math.max(outputState.maxY, yy);
  outputState.minY = Math.min(outputState.minY, yy);
  return yy;
}

function echo(text) {
  outputState.text += text;
}

function echoln(text) {
  outputState.text += text + "\n";
}

function toolFill() {
  param = getParameter("operation:tool_comment");
  fill = param.split(" ")[0];
  if (fill == "nofill") {
    return "none";
  }
  if (fill == "fill") {
    rgb = param.match(/\d+/g);
    return "rgb(" + rgb.join(",") + ")";
  }
  err = "Cannot parse comment: '" + param + "'";
  writeln(err);
  error(err);
}

function toolStroke() {
  param = getParameter("operation:tool_comment");
  fill = param.split(" ")[0];
  if (fill == "nofill") {
    rgb = param.match(/\d+/g);
    return "rgb(" + rgb.join(",") + ")";
  }
  if (fill == "fill") {
    return "none";
  }
  err = "Cannot parse comment: '" + param + "'";
  writeln(err);
  error(err);
}

function echoStock() {
  echoln(indent() + "<polyline points=\"0,0 "
    + tX(properties.width) + ",0 "
    + tX(properties.width) + "," + tY(properties.height)
    + " 0," + tY(properties.height) + " 0,0\" "
    + " stroke=\"rgb(0,0,0)\" stroke-width=\"" + properties.lineWidth + "\" fill=\"none\"/>");
  outputState.xOffset += properties.width + properties.spacing;
}

function onOpen() {
  // we output in mm always so scale from inches
  xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), scale:(unit == MM) ? 1 : 25.4});
  outputState.indent++;
  if (properties.generateStock) {
    echoStock();
  }
}

function getPatternInstance() {
  var patternId = currentSection.getPatternId();
    var sections = [];
    var first = true;
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var section = getSection(i);
      if (section.getPatternId() == patternId) {
        if (i < getCurrentSectionId()) {
          first = false; // not the first pattern instance
        }
        if (i != getCurrentSectionId()) {
          sections.push(section.getId());
        }
      }
    }
  return sections;
}

function onComment(text) {
  echoln(indent() + "<!-- " + text + " -->");
}

function onSection() {
  switch (tool.type) {
  case TOOL_WATER_JET: // allow any way for Epilog
    warning(localize("Using waterjet cutter but allowing it anyway."));
    break;
  case TOOL_LASER_CUTTER:
    break;
  case TOOL_PLASMA_CUTTER: // allow any way for Epilog
    warning(localize("Using plasma cutter but allowing it anyway."));
    break;
  /*
  case TOOL_MARKER: // allow any way for Epilog
    warning(localize("Using marker but allowing it anyway."));
    break;
  */
  default:
    error(localize("The CNC does not support the required tool."));
    return;
  }

  handlePattern();

  var id = "op_" + getParameter("operation-comment").replace(/[ \(\)]/, "_") +
  "-" + getParameter("autodeskcam:operation-id") + "-" + getCurrentSectionId();
  echo(indent() + "<path id=\"" + id
     + "\" fill=\"" + toolFill() + "\" stroke=\"" + toolStroke() + "\" stroke-width=\"" + properties.lineWidth + "\" d=\"");
  outputState.lastPos = getCurrentPosition();
  outputState.pendingRapid = " M" + xyzFormat.format(tX(getCurrentPosition().x)) + " " + xyzFormat.format(tY(getCurrentPosition().y));
  onM(getCurrentPosition());
}

function cloneBb(b) {
  return {
    upper: {
      x: b.upper.x,
      y: b.upper.y,
      z: b.upper.z
    },
    lower: {
      x: b.lower.x,
      y: b.lower.y,
      z: b.upper.z
    }
  };
}

function onParameter(name, value) {
  if (name.lastIndexOf("part-", 0) === 0) {
    if (name == "part-lower-x") {
      outputState.prevStock = cloneBb(outputState.stock);
    }

    var vals = name.split("-");
    v = parseFloat(value);

    var tmp = outputState.stock[vals[1]];
    tmp[vals[2]] = v;
    outputState.stock[vals[1]] = tmp;

    if (name != "part-upper-z") {
      return;
    }

    var stock = outputState.stock;
    outputState.yOffset = stock.upper.y - stock.lower.y;
    outputState.zeroXOffset = stock.lower.x;
    outputState.zeroYOffset = stock.lower.y;

    tX(stock.upper.x);
    tX(stock.lower.x);
    tY(stock.upper.y);
    tY(stock.lower.y);

    var w = stock.upper.x - stock.lower.x;
    var h = stock.upper.y - stock.lower.y;
  }
}

function openPart(name) {
  if (outputState.openedGroup) {
    outputState.indent--;
    echoln(indent() + "</g>");
  }
  echoln(indent() + "<g id=\"" + name + "\">");
  outputState.indent++;
  outputState.openedGroup = true;
  outputState.xOffset += outputState.prevStock.upper.x - outputState.prevStock.lower.x + properties.spacing;
  outputState.prevStock = cloneBb(outputState.stock);
}

function handlePattern() {
  var jD = getParameter("job-description");
  if (jD != outputState.openJob) {
    outputState.patternStart = null;
    outputState.initialPosition = currentSection.getInitialPosition();
  }

  if (!currentSection.isPatterned()) {
    if (jD == outputState.openJob) {
      return;
    }
    openPart(jD.replace(/[ \(\)]/, "_"));
    outputState.wcsXOffset = 0;
    outputState.wcsYOffset = 0;
    outputState.openJob = jD;
    return;
  }

  var opId = getParameter("autodeskcam:operation-id");
  if (outputState.patternStart == null) {
    outputState.patternStart = opId;
    outputState.patternCounter = 1;
  }

  if (outputState.patternStart == opId) {
    openPart(jD.replace(/[ \(\)]/, "_") + "-" + outputState.patternCounter);
    outputState.patternCounter++;

    var init = currentSection.getInitialPosition();
    outputState.wcsXOffset = init.x - outputState.initialPosition.x;
    outputState.wcsYOffset = init.y - outputState.initialPosition.y;
  }
  outputState.openJob = jD;
}

function dumpObject(obj, prefix, depth) {
  if (depth == 3) {
    return;
  }
  for (var property in obj) {
    if (property == "text") {
      continue;
    }
    if (obj.hasOwnProperty(property)) {
        onComment(prefix + property + ": " + obj[property])
    }
    if (typeof(obj[property]) == "object") {
      dumpObject(obj[property], prefix + "\t", depth + 1);
    }
  }
}

function onM(start) {
  outputState.start.x = start.x;
  outputState.start.y = start.y;
}

function onPoint(point) {
  if ((xyzFormat.format(point.x) == xyzFormat.format(outputState.start.x)) &&
      (xyzFormat.format(point.y) == xyzFormat.format(outputState.start.y)))
  {
    echo(" z");
  }
}

function onDwell(seconds) {
}

function onCycle() {
}

function onCyclePoint(x, y, z) {
}

function onCycleEnd() {
}

function writeLine(x, y) {
  if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
    echoln(localize("Compensation in control is not supported."));
    error(localize("Compensation in control is not supported."));
    return;
  }
  switch (movement) {
  case MOVEMENT_CUTTING:
  case MOVEMENT_REDUCED:
  case MOVEMENT_FINISH_CUTTING:
    break;
  case MOVEMENT_RAPID:
  case MOVEMENT_HIGH_FEED:
  case MOVEMENT_LEAD_IN:
  case MOVEMENT_LEAD_OUT:
  case MOVEMENT_LINK_TRANSITION:
  case MOVEMENT_LINK_DIRECT:
  default:
    return; // skip
  }

  var start = getCurrentPosition();
  if ((xyzFormat.format(start.x) == xyzFormat.format(x)) &&
      (xyzFormat.format(start.y) == xyzFormat.format(y))) {
    return; // ignore vertical
  }
  if ((xyzFormat.format(start.x) != xyzFormat.format(outputState.lastPos.x)) ||
      (xyzFormat.format(start.y) != xyzFormat.format(outputState.lastPos.y))) {
    echo(" M" + xyzFormat.format(tX(start.x)) + " " + xyzFormat.format(tY(start.y)));
    outputState.pendingRapid = "";
    onM(start);
  }
  if (outputState.pendingRapid != "") {
    echo(outputState.pendingRapid);
    outputState.pendingRapid = "";
  }
  echo(" L" + xyzFormat.format(tX(x)) + " " + xyzFormat.format(tY(y)));
  outputState.lastPos = new Vector(x, y, 0);
  onPoint(outputState.lastPos);
}

function onRapid(x, y, z) {
  writeLine(x, y);
}

function onLinear(x, y, z, feed) {
  writeLine(x, y);
}

function onRapid5D(x, y, z, dx, dy, dz) {
  onRapid(x, y, z);
}

function onLinear5D(x, y, z, dx, dy, dz, feed) {
  onLinear(x, y, z);
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  if (radiusCompensation != RADIUS_COMPENSATION_OFF) {
    writeln(localize("Compensation in control is not supported."));
    error(localize("Compensation in control is not supported."));
    return;
  }

  switch (movement) {
  case MOVEMENT_CUTTING:
  case MOVEMENT_REDUCED:
  case MOVEMENT_FINISH_CUTTING:
    break;
  case MOVEMENT_RAPID:
  case MOVEMENT_HIGH_FEED:
  case MOVEMENT_LEAD_IN:
  case MOVEMENT_LEAD_OUT:
  case MOVEMENT_LINK_TRANSITION:
  case MOVEMENT_LINK_DIRECT:
  default:
    return; // skip
  }

  var start = getCurrentPosition();

  var largeArc = (getCircularSweep() > Math.PI) ? 1 : 0;
  var sweepFlag = isClockwise() ? 1 : 0;

  if ((xyzFormat.format(start.x) != xyzFormat.format(outputState.lastPos.x)) ||
      (xyzFormat.format(start.y) != xyzFormat.format(outputState.lastPos.y)))
  {
    echo(" M" + xyzFormat.format(tX(start.x)) + " " + xyzFormat.format(tY(start.y)));
    outputState.pendingRapid = "";
    onM(start);
  }
  if (outputState.pendingRapid != "") {
    echo(outputState.pendingRapid);
    outputState.pendingRapid = "";
  }
  echo(["A",
           xyzFormat.format(getCircularRadius()),
           xyzFormat.format(getCircularRadius()),
           0,
           largeArc,
           sweepFlag,
           xyzFormat.format(tX(x)),
           xyzFormat.format(tY(y))
      ].join(" "));
  outputState.lastPos = new Vector(x, y, 0);
  onPoint(outputState.lastPos);
}

function onCommand() {
}

function onSectionEnd() {
  echoln("\"/>");
}

function onClose() {
  if (outputState.openedGroup) {
    outputState.indent--;
    echoln(indent() + "</g>");
  }

  outputState.indent--;
  echoln(indent() + "</svg>");

  var width = outputState.maxX - outputState.minX + 2 * properties.spacing;
  var height = outputState.maxY - outputState.minY + 2 * properties.spacing;

  // Echo header
  writeln("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>");
  writeln("<svg xmlns=\"http://www.w3.org/2000/svg\" "
    + "width=\"" + (width + properties.spacing) + "mm\" "
    + "height=\"" + (height + properties.spacing) + "mm\" "
    + "viewBox=\"" + [-properties.spacing, outputState.minY - properties.spacing,
        width + properties.spacing, height + properties.spacing].join(" ") + "\""
    + ">");

  writeln(outputState.text);
}