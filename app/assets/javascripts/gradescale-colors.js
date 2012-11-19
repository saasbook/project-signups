// scale for colors

var GradeScale = {
  'min': -3,
  'max': 1,
  'rgbaForScore': {
    '-3': { 'red': 205, 'green': 38, 'blue': 38 },
    '-2': { 'red': 224, 'green': 120, 'blue': 30 },
    '-1': { 'red': 244, 'green': 202, 'blue': 22 },
    '0' : { 'red': 76, 'green': 187, 'blue': 23 },
    '1' : { 'red': 127, 'green': 174, 'blue': 211 }
  }
}

var Colors = {
  // set scale colors
  minRgbHash: { 'red': 205, 'green': 38, 'blue': 38 },
  midRgbHash: { 'red': 244, 'green': 202, 'blue': 22 },
  maxRgbHash: { 'red': 76, 'green': 187, 'blue': 23 },

  getRgbHash: function(score) {
    var min        = GradeScale['min'],
        max        = GradeScale['max'],
        minRgbHash = this.minRgbHash,
        midRgbHash = this.midRgbHash,
        maxRgbHash = this.maxRgbHash,
        mid        = Math.floor( (min + max)/2 ),
        redSlope,
        greenSlope,
        blueSlope,
        redOffset,
        greenOffset,
        blueOffset,
        rgbHash;

    if (score <= mid) {
      // red to yellow scale
      redSlope    = (midRgbHash['red'] - minRgbHash['red'])/(mid - min);
      greenSlope  = (midRgbHash['green'] - minRgbHash['green'])/(mid - min);
      blueSlope   = (midRgbHash['blue'] - minRgbHash['blue'])/(mid - min);
      redOffset   = minRgbHash['red'] - redSlope * min;
      greenOffset = minRgbHash['green'] - greenSlope * min;
      blueOffset  = minRgbHash['blue'] - blueSlope * min;

      rgbHash = {
        'red'   : parseInt(redSlope*score + redOffset),
        'green' : parseInt(greenSlope*score + greenOffset),
        'blue'  : parseInt(blueSlope*score + blueOffset) };
    } else {
      if (score == 0) {
        // green
        rgbHash = { 'red': 76, 'green': 187, 'blue': 23 };
      } else {
        // blue
        rgbHash = { 'red': 127, 'green': 174, 'blue': 211 };
      }
      /*
      redSlope    = (maxRgbHash['red'] - midRgbHash['red'])/(max - mid);
      greenSlope  = (maxRgbHash['green'] - midRgbHash['green'])/(max - mid);
      blueSlope   = (maxRgbHash['blue'] - midRgbHash['blue'])/(max - mid);
      redOffset   = midRgbHash['red'] - redSlope * mid;
      greenOffset = midRgbHash['green'] - greenSlope * mid;
      blueOffset  = midRgbHash['blue'] - blueSlope * mid;
      */
    }

    return rgbHash;
  },

  scoreToRgba: function(score, alpha) {
    var min         = GradeScale['min'],
        max         = GradeScale['max'],
        mid         = Math.floor( (min + max)/2 ),
        rgbHash     = this.getRgbHash(score, min, max),
        redValue    = rgbHash['red'],
        greenValue  = rgbHash['green'],
        blueValue   = rgbHash['blue'];

    return 'rgba('+redValue+', '+greenValue+', '+blueValue+', '+alpha+')';
  }
};
