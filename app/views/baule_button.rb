class BauleButton < UIButton

  attr_reader :nel_baule

  def nel_baule=(nel_baule)
    @nel_baule = nel_baule
    self.setNeedsDisplay
  end

  def drawRect(rect)

    ## General Declarations
    colorSpace = CGColorSpaceCreateDeviceRGB()
    context = UIGraphicsGetCurrentContext()

    ## Color Declarations

    if @nel_baule == 1
      baseColor = UIColor.colorWithRed(0.307, green:0.117, blue:0.927, alpha:0.754)
    else
      baseColor = UIColor.colorWithRed(0.074, green:0.074, blue:0.074, alpha:0.523)
    end
    
    baseColorR = Pointer.new(:float, 1)
    baseColorG = Pointer.new(:float, 1)
    baseColorB = Pointer.new(:float, 1)
    baseColorA = Pointer.new(:float, 1)
    baseColor.getRed baseColorR, green: baseColorG, blue: baseColorA, alpha: baseColorA

    baseColorH  = Pointer.new(:float, 1)
    baseColorS  = Pointer.new(:float, 1)
    baseColorBr = Pointer.new(:float, 1)
    baseColorAl = Pointer.new(:float, 1)
    baseColor.getHue baseColorH, saturation: baseColorS, brightness: baseColorBr, alpha: baseColorAl

    topColor = UIColor.colorWithRed((baseColorR[0] * 0.2 + 0.8), green:(baseColorG[0] * 0.2 + 0.8), blue:(baseColorB[0] * 0.2 + 0.8), alpha:(baseColorA[0] * 0.2 + 0.8))

    topColorR = Pointer.new(:float, 1)
    topColorG = Pointer.new(:float, 1)
    topColorB = Pointer.new(:float, 1)
    topColorA = Pointer.new(:float, 1)
    topColor.getRed topColorR, green: topColorG, blue: topColorB, alpha: topColorA
    topOutColor = UIColor.colorWithRed((topColorR[0] * 0 + 1), green:(topColorG[0] * 0 + 1), blue:(topColorB[0] * 0 + 1), alpha:(topColorA[0] * 0 + 1))

 
    bottomColor = UIColor.colorWithHue baseColorH[0], saturation: baseColorS[0], brightness: 0.8, alpha: baseColorAl[0]
    bottomColorR = Pointer.new(:float, 1)
    bottomColorG = Pointer.new(:float, 1)
    bottomColorB = Pointer.new(:float, 1)
    bottomColorA = Pointer.new(:float, 1)    
    bottomColor.getRed bottomColorR, green: bottomColorG, blue: bottomColorB, alpha: bottomColorA

    bottomColorOut = UIColor.colorWithRed((bottomColorR[0] * 0.9), green:(bottomColorG[0] * 0.9), blue:(bottomColorB[0] * 0.9), alpha:(bottomColorA[0] * 0.9 + 0.1))
    topColor2 = UIColor.colorWithRed((baseColorR[0] * 0.2 + 0.8), green:(baseColorG[0] * 0.2 + 0.8), blue:(baseColorB[0] * 0.2 + 0.8), alpha:(baseColorA[0] * 0.2 + 0.8))
    
    bottomColor2 = UIColor.colorWithHue baseColorH[0], saturation: baseColorS[0], brightness: 0.8, alpha: baseColorAl[0]
    smallShadowColor = UIColor.colorWithRed(0.298, green:0.298, blue:0.298, alpha:1)
    symbolShadow = UIColor.colorWithRed(0.496, green:0.496, blue:0.496, alpha:1)
    white = UIColor.colorWithRed(1, green:1, blue:1, alpha:1)
    symbolONColor = UIColor.colorWithRed(0.798, green:0.949, blue:1, alpha:1)

    ## Gradient Declarations
    buttonOutGradientColors = [ 
      bottomColorOut.CGColor, 
      UIColor.colorWithRed(0.619, green:0.545, blue:0.86, alpha:0.889).CGColor, 
      topOutColor.CGColor
    ]
    buttonOutGradientLocationsArray = [0, 0.66, 1] 
    buttonOutGradientLocations = Pointer.new(:float, buttonOutGradientLocationsArray.length)

    buttonOutGradientLocationsArray.each_index{|idx| 
      buttonOutGradientLocations[idx] = buttonOutGradientLocationsArray[idx] 
    }
    buttonOutGradient = CGGradientCreateWithColors(colorSpace, buttonOutGradientColors, buttonOutGradientLocations)
    buttonGradient2Colors = [ 
      bottomColor2.CGColor, 
      topColor2.CGColor
    ]
    buttonGradient2LocationsArray = [0, 1]
    buttonGradient2Locations = Pointer.new(:float, buttonGradient2LocationsArray.length)
    buttonGradient2LocationsArray.each_index{ |idx| 
      buttonGradient2Locations[idx] = buttonGradient2LocationsArray[idx] 
    }
    buttonGradient2 = CGGradientCreateWithColors(colorSpace, buttonGradient2Colors, buttonGradient2Locations)

    ## Shadow Declarations
    smallShadow = smallShadowColor
    smallShadowOffset = CGSizeMake(0.1, 3.1)
    smallShadowBlurRadius = 5.5
    shadow = symbolShadow
    shadowOffset = CGSizeMake(0.1, 210.1)
    shadowBlurRadius = 15
    glow = symbolONColor
    glowOffset = CGSizeMake(0.1, -0.1)
    glowBlurRadius = 7.5
    
    strokeColor = UIColor.colorWithRed(0, green:0, blue:0, alpha:1)
    ## Shadow Declarations
    symbolOffShadow = strokeColor
    symbolOffShadowOffset = CGSizeMake(0.1, 2.1)
    symbolOffShadowBlurRadius = 5.5

    ## Frames
    frame = CGRectMake(0, 0, 52, 57)


    ## GroupShadow# {
    CGContextSaveGState(context)
    CGContextSetAlpha(context, 0.75)
    CGContextSetBlendMode(context, KCGBlendModeMultiply)
    CGContextBeginTransparencyLayer(context, nil)


    ## LongShadow Drawing
    longShadowPath = UIBezierPath.bezierPath
    longShadowPath.moveToPoint(CGPointMake(25.29, -149.67))
    longShadowPath.addCurveToPoint(CGPointMake(39.15, -188.38), controlPoint1:CGPointMake(43.33, -149.46), controlPoint2:CGPointMake(44.54, -178.67))
    longShadowPath.addCurveToPoint(CGPointMake(25.29, -198), controlPoint1:CGPointMake(37.76, -190.89), controlPoint2:CGPointMake(34.79, -198.08))
    longShadowPath.addCurveToPoint(CGPointMake(11.84, -188.38), controlPoint1:CGPointMake(16.04, -197.92), controlPoint2:CGPointMake(12.98, -190.99))
    longShadowPath.addCurveToPoint(CGPointMake(25.29, -149.67), controlPoint1:CGPointMake(7.29, -177.92), controlPoint2:CGPointMake(8.67, -149.86))
    longShadowPath.closePath
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor)
    baseColor.setFill
    longShadowPath.fill
    CGContextRestoreGState(context)



    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)# }


    ## outerRing Drawing
    outerRingRect = CGRectMake(CGRectGetMinX(frame) + 3, CGRectGetMinY(frame) + 3, 44, 44)
    outerRingPath = UIBezierPath.bezierPathWithOvalInRect(outerRingRect)
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, smallShadowOffset, smallShadowBlurRadius, smallShadow.CGColor)
    CGContextBeginTransparencyLayer(context, nil)
    outerRingPath.addClip
    CGContextDrawLinearGradient(context, buttonOutGradient,
        CGPointMake(CGRectGetMidX(outerRingRect), CGRectGetMaxY(outerRingRect)),
        CGPointMake(CGRectGetMidX(outerRingRect), CGRectGetMinY(outerRingRect)),
        0)
    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)



    ## innerRing Drawing
    innerRingRect = CGRectMake(CGRectGetMinX(frame) + 6, CGRectGetMinY(frame) + 6, CGRectGetWidth(frame) - 14, CGRectGetHeight(frame) - 19)
    innerRingPath = UIBezierPath.bezierPathWithOvalInRect(innerRingRect)
    CGContextSaveGState(context)
    innerRingPath.addClip
    CGContextDrawLinearGradient(context, buttonGradient2,
        CGPointMake(CGRectGetMidX(innerRingRect), CGRectGetMaxY(innerRingRect)),
        CGPointMake(CGRectGetMidX(innerRingRect), CGRectGetMinY(innerRingRect)),
        0)
    CGContextRestoreGState(context)


    ## symbolOn# {
    ## box Drawing

    if nel_baule == 1
      boxPath = UIBezierPath.bezierPath
      boxPath.moveToPoint(CGPointMake(CGRectGetMinX(frame) + 13.5, CGRectGetMinY(frame) + 23.5))
      boxPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 23.5))
      boxPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 32.5))
      boxPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 34.5, CGRectGetMinY(frame) + 32.5))
      boxPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 34.5, CGRectGetMinY(frame) + 23.5))
      boxPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMinY(frame) + 23.5))
      boxPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMinY(frame) + 34.5))
      boxPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 13.5, CGRectGetMinY(frame) + 34.5))
      boxPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 13.5, CGRectGetMinY(frame) + 23.5))
      boxPath.closePath
      CGContextSaveGState(context)
      CGContextSetShadowWithColor(context, glowOffset, glowBlurRadius, glow.CGColor)
      white.setFill
      boxPath.fill
      CGContextRestoreGState(context)

      white.setStroke
      boxPath.lineWidth = 1
      boxPath.stroke


      ## arrowDownload Drawing
      arrowDownloadPath = UIBezierPath.bezierPath
      arrowDownloadPath.moveToPoint(CGPointMake(CGRectGetMinX(frame) + 19, CGRectGetMinY(frame) + 20))
      arrowDownloadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 20))
      arrowDownloadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 13))
      arrowDownloadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 27, CGRectGetMinY(frame) + 13))
      arrowDownloadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 27, CGRectGetMinY(frame) + 20))
      arrowDownloadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 31, CGRectGetMinY(frame) + 20))
      arrowDownloadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 25, CGRectGetMinY(frame) + 27))
      arrowDownloadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 25, CGRectGetMinY(frame) + 27))
      arrowDownloadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 19, CGRectGetMinY(frame) + 20))
      arrowDownloadPath.closePath
      arrowDownloadPath.lineCapStyle = KCGLineCapRound

      CGContextSaveGState(context)
      CGContextSetShadowWithColor(context, glowOffset, glowBlurRadius, glow.CGColor)
      white.setFill
      arrowDownloadPath.fill
      CGContextRestoreGState(context)
    
    else

      ## symbolOff# {
      CGContextSaveGState(context)
      CGContextSetAlpha(context, 0.25)
      CGContextBeginTransparencyLayer(context, nil)


      ## boxOff Drawing
      boxOffPath = UIBezierPath.bezierPath
      boxOffPath.moveToPoint(CGPointMake(CGRectGetMinX(frame) + 13.5, CGRectGetMinY(frame) + 23.5))
      boxOffPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 23.5))
      boxOffPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 32.5))
      boxOffPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 34.5, CGRectGetMinY(frame) + 32.5))
      boxOffPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 34.5, CGRectGetMinY(frame) + 23.5))
      boxOffPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMinY(frame) + 23.5))
      boxOffPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMinY(frame) + 34.5))
      boxOffPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 13.5, CGRectGetMinY(frame) + 34.5))
      boxOffPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 13.5, CGRectGetMinY(frame) + 23.5))
      boxOffPath.closePath
      CGContextSaveGState(context)
      boxOffPath.addClip
      boxOffBounds = CGPathGetPathBoundingBox(boxOffPath.CGPath)
      CGContextDrawLinearGradient(context, buttonGradient2,
          CGPointMake(CGRectGetMidX(boxOffBounds), CGRectGetMinY(boxOffBounds)),
          CGPointMake(CGRectGetMidX(boxOffBounds), CGRectGetMaxY(boxOffBounds)),
          0)
      CGContextRestoreGState(context)

      ### boxOff Inner Shadow
      boxOffBorderRect = CGRectInset(boxOffPath.bounds, -symbolOffShadowBlurRadius, -symbolOffShadowBlurRadius)
      boxOffBorderRect = CGRectOffset(boxOffBorderRect, -symbolOffShadowOffset.width, -symbolOffShadowOffset.height)
      boxOffBorderRect = CGRectInset(CGRectUnion(boxOffBorderRect, boxOffPath.bounds), -1, -1)

      boxOffNegativePath = UIBezierPath.bezierPathWithRect(boxOffBorderRect)
      boxOffNegativePath.appendPath(boxOffPath)
      boxOffNegativePath.usesEvenOddFillRule = true

      CGContextSaveGState(context)

      xOffset = symbolOffShadowOffset.width + boxOffBorderRect.size.width.ceil
      yOffset = symbolOffShadowOffset.height
      CGContextSetShadowWithColor(context,
          CGSizeMake(xOffset + 0.1, yOffset + 0.1),
          symbolOffShadowBlurRadius,
          symbolOffShadow.CGColor)

      boxOffPath.addClip
      transform = CGAffineTransformMakeTranslation(-boxOffBorderRect.size.width.ceil, 0)
      boxOffNegativePath.applyTransform(transform)
      UIColor.grayColor.setFill
      boxOffNegativePath.fill
      CGContextRestoreGState(context)

      ## arrowUpload Drawing
      arrowUploadPath = UIBezierPath.bezierPath
      arrowUploadPath.moveToPoint(CGPointMake(CGRectGetMinX(frame) + 19, CGRectGetMinY(frame) + 20))
      arrowUploadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 20))
      arrowUploadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 27))
      arrowUploadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 27, CGRectGetMinY(frame) + 27))
      arrowUploadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 27, CGRectGetMinY(frame) + 20))
      arrowUploadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 31, CGRectGetMinY(frame) + 20))
      arrowUploadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 25, CGRectGetMinY(frame) + 13))
      arrowUploadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 25, CGRectGetMinY(frame) + 13))
      arrowUploadPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 19, CGRectGetMinY(frame) + 20))
      arrowUploadPath.closePath
      arrowUploadPath.lineCapStyle = KCGLineCapRound

      CGContextSaveGState(context)
      arrowUploadPath.addClip
      arrowUploadBounds = CGPathGetPathBoundingBox(arrowUploadPath.CGPath)
      CGContextDrawLinearGradient(context, buttonGradient2,
          CGPointMake(CGRectGetMidX(arrowUploadBounds), CGRectGetMinY(arrowUploadBounds)),
          CGPointMake(CGRectGetMidX(arrowUploadBounds), CGRectGetMaxY(arrowUploadBounds)),
          0)
      CGContextRestoreGState(context)

      ### arrowUpload Inner Shadow
      arrowUploadBorderRect = CGRectInset(arrowUploadPath.bounds, -symbolOffShadowBlurRadius, -symbolOffShadowBlurRadius)
      arrowUploadBorderRect = CGRectOffset(arrowUploadBorderRect, -symbolOffShadowOffset.width, -symbolOffShadowOffset.height)
      arrowUploadBorderRect = CGRectInset(CGRectUnion(arrowUploadBorderRect, arrowUploadPath.bounds), -1, -1)

      arrowUploadNegativePath = UIBezierPath.bezierPathWithRect(arrowUploadBorderRect)
      arrowUploadNegativePath.appendPath(arrowUploadPath)
      arrowUploadNegativePath.usesEvenOddFillRule = true

      CGContextSaveGState(context)

      xOffset = symbolOffShadowOffset.width + arrowUploadBorderRect.size.width.ceil
      yOffset = symbolOffShadowOffset.height
      CGContextSetShadowWithColor(context,
          CGSizeMake(xOffset + 0.1, yOffset + 0.1),
          symbolOffShadowBlurRadius,
          symbolOffShadow.CGColor)

      arrowUploadPath.addClip
      transform = CGAffineTransformMakeTranslation(-arrowUploadBorderRect.size.width.ceil, 0)
      arrowUploadNegativePath.applyTransform(transform)
      UIColor.grayColor.setFill
      arrowUploadNegativePath.fill

      CGContextRestoreGState(context)
      CGContextEndTransparencyLayer(context)
      CGContextRestoreGState(context)
    end










  end

end