class BauleView < UIButton

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
    iconShadow = UIColor.colorWithRed(0, green:0, blue:0, alpha:0.8)
    
    if @nel_baule == 1
      baseColor = UIColor.colorWithRed(0.637, green:0.156, blue:0.687, alpha:1)
    else
      baseColor = UIColor.colorWithRed 0.675, green: 0.73, blue: 0.62, alpha: 1
    end

    # baseColorRGBAArray = [0,0,0,0]
    baseColorR = Pointer.new(:float, 1)
    baseColorG = Pointer.new(:float, 1)
    baseColorB = Pointer.new(:float, 1)
    baseColorA = Pointer.new(:float, 1)
    baseColor.getRed(baseColorR, green: baseColorG, blue: baseColorB, alpha: baseColorA)
    baseGradientBottomColor = UIColor.colorWithRed((baseColorR[0] * 0.8), green:(baseColorG[0] * 0.8), blue:(baseColorB[0] * 0.8), alpha:(baseColorA[0] * 0.8 + 0.2))
    
    #baseGradientBottomColor = UIColor.colorWithRed(0.637  * 0.8, green:0.156  * 0.8, blue:0.687  * 0.8, alpha:1 * 0.8 + 0.2)


    strokeColor = UIColor.colorWithRed(0, green:0, blue:0, alpha:0.23)
    upperShine = UIColor.colorWithRed(1, green:1, blue:1, alpha:1)
    bottomShine = upperShine.colorWithAlphaComponent 0.1
    topShine = upperShine.colorWithAlphaComponent 0.9

    ## Gradient Declarations
    shineGradientColors = [ 
      topShine.CGColor, 
      UIColor.colorWithRed(1, green:1, blue:1, alpha:0.5).CGColor, 
      bottomShine.CGColor
    ]

    shineGradientLocationsArray = [0, 0.42, 1]
    shineGradientLocations = Pointer.new(:float, shineGradientLocationsArray.length)
    shineGradientLocationsArray.each_index { |idx| 
      shineGradientLocations[idx] = shineGradientLocationsArray[idx] 
    }

    shineGradient = CGGradientCreateWithColors(colorSpace, shineGradientColors, shineGradientLocations)

    baseGradientColors = [ 
      baseColor.CGColor, 
      baseGradientBottomColor.CGColor
    ]

    baseGradientLocationsArray = [0, 1]; 
    baseGradientLocations = Pointer.new(:float, baseGradientLocationsArray.length)
    baseGradientLocationsArray.each_index { |idx| 
      baseGradientLocations[idx] = baseGradientLocationsArray[idx] 
    }
    baseGradient = CGGradientCreateWithColors(colorSpace, baseGradientColors, baseGradientLocations)

    ## Shadow Declarations
    iconBottomShadow = iconShadow
    iconBottomShadowOffset = CGSizeMake(0.1, 2.1)
    iconBottomShadowBlurRadius = 4
    upperShineShadow = upperShine
    upperShineShadowOffset = CGSizeMake(0.1, 1.1)
    upperShineShadowBlurRadius = 1

    ## ShadowGroup# {
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, iconBottomShadowOffset, iconBottomShadowBlurRadius, iconBottomShadow.CGColor)
    CGContextSetBlendMode(context, KCGBlendModeMultiply)
    CGContextBeginTransparencyLayer(context, nil)


    ## shadowRectangle Drawing
    shadowRectanglePath = UIBezierPath.bezierPathWithRoundedRect(CGRectMake(6, 3, 57, 57), cornerRadius:11)
    baseColor.setFill
    shadowRectanglePath.fill


    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)# }

    ## Button# {
    ## ButtonRectangle Drawing
    buttonRectanglePath = UIBezierPath.bezierPathWithRoundedRect(CGRectMake(6, 3, 57, 57), cornerRadius:11)
    CGContextSaveGState(context)
    buttonRectanglePath.addClip
    CGContextDrawLinearGradient(context, baseGradient, CGPointMake(34.5, 3), CGPointMake(34.5, 60), 0)
    CGContextRestoreGState(context)

    ### ButtonRectangle Inner Shadow
    buttonRectangleBorderRect = CGRectInset(buttonRectanglePath.bounds, -upperShineShadowBlurRadius, -upperShineShadowBlurRadius)
    buttonRectangleBorderRect = CGRectOffset(buttonRectangleBorderRect, -upperShineShadowOffset.width, -upperShineShadowOffset.height)
    buttonRectangleBorderRect = CGRectInset(CGRectUnion(buttonRectangleBorderRect, buttonRectanglePath.bounds), -1, -1)

    buttonRectangleNegativePath = UIBezierPath.bezierPathWithRect(buttonRectangleBorderRect)
    buttonRectangleNegativePath.appendPath(buttonRectanglePath)
    buttonRectangleNegativePath.usesEvenOddFillRule = true

    CGContextSaveGState(context)
    
    xOffset = upperShineShadowOffset.width + buttonRectangleBorderRect.size.width.ceil
    yOffset = upperShineShadowOffset.height
    CGContextSetShadowWithColor(context,
        CGSizeMake(xOffset + 0.1, yOffset + 0.1),
        upperShineShadowBlurRadius,
        upperShineShadow.CGColor)

    buttonRectanglePath.addClip
    transform = CGAffineTransformMakeTranslation(-buttonRectangleBorderRect.size.width.ceil, 0)
    buttonRectangleNegativePath.applyTransform(transform)
    UIColor.grayColor.setFill
    buttonRectangleNegativePath.fill
    
    CGContextRestoreGState(context)

    strokeColor.setStroke
    buttonRectanglePath.lineWidth = 1
    buttonRectanglePath.stroke


    ## UpperShinner
    CGContextSaveGState(context)
    CGContextSetBlendMode(context, KCGBlendModeHardLight)
    CGContextBeginTransparencyLayer(context, nil)


    ## UpperShinnyPart Drawing
    upperShinnyPartPath = UIBezierPath.bezierPath
    upperShinnyPartPath.moveToPoint(CGPointMake(63, 17))
    upperShinnyPartPath.addLineToPoint(CGPointMake(63, 27))
    upperShinnyPartPath.addCurveToPoint(CGPointMake(35, 33), controlPoint1:CGPointMake(55, 32), controlPoint2:CGPointMake(45.03, 33))
    upperShinnyPartPath.addCurveToPoint(CGPointMake(6, 27), controlPoint1:CGPointMake(26, 33), controlPoint2:CGPointMake(14, 32))
    upperShinnyPartPath.addLineToPoint(CGPointMake(6, 17))
    upperShinnyPartPath.addCurveToPoint(CGPointMake(17, 4), controlPoint1:CGPointMake(6, 7), controlPoint2:CGPointMake(11, 4))
    upperShinnyPartPath.addLineToPoint(CGPointMake(52, 4))
    upperShinnyPartPath.addCurveToPoint(CGPointMake(63, 17), controlPoint1:CGPointMake(58, 4), controlPoint2:CGPointMake(63, 7))
    upperShinnyPartPath.closePath
    CGContextSaveGState(context)
    upperShinnyPartPath.addClip
    CGContextDrawLinearGradient(context, shineGradient, CGPointMake(34.5, 4), CGPointMake(34.5, 33), 0)
    CGContextRestoreGState(context)

    ### UpperShinnyPart Inner Shadow
    upperShinnyPartBorderRect = CGRectInset(upperShinnyPartPath.bounds, -upperShineShadowBlurRadius, -upperShineShadowBlurRadius)
    upperShinnyPartBorderRect = CGRectOffset(upperShinnyPartBorderRect, -upperShineShadowOffset.width, -upperShineShadowOffset.height)
    upperShinnyPartBorderRect = CGRectInset(CGRectUnion(upperShinnyPartBorderRect, upperShinnyPartPath.bounds), -1, -1)

    upperShinnyPartNegativePath = UIBezierPath.bezierPathWithRect(upperShinnyPartBorderRect)
    upperShinnyPartNegativePath.appendPath(upperShinnyPartPath)
    upperShinnyPartNegativePath.usesEvenOddFillRule = true

    CGContextSaveGState(context)
    
    xOffset = upperShineShadowOffset.width + upperShinnyPartBorderRect.size.width.ceil
    yOffset = upperShineShadowOffset.height
    CGContextSetShadowWithColor(context,
        CGSizeMake(xOffset + 0.1, yOffset + 0.1),
        upperShineShadowBlurRadius,
        upperShineShadow.CGColor)

    upperShinnyPartPath.addClip
    transform = CGAffineTransformMakeTranslation(-upperShinnyPartBorderRect.size.width.ceil, 0)
    upperShinnyPartNegativePath.applyTransform(transform)
    UIColor.grayColor.setFill
    upperShinnyPartNegativePath.fill
    
    CGContextRestoreGState(context)

    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)
    # }



    # Drawing Box Icon

    ## Color Declarations
    white = UIColor.colorWithRed(1, green:1, blue:1, alpha:1)

    boxPath = UIBezierPath.bezierPath
    boxPath.moveToPoint(CGPointMake(23.5, 30.5))
    boxPath.addLineToPoint(CGPointMake(25.5, 30.5))
    boxPath.addLineToPoint(CGPointMake(25.5, 39.5))
    boxPath.addLineToPoint(CGPointMake(44.5, 39.5))
    boxPath.addLineToPoint(CGPointMake(44.5, 30.5))
    boxPath.addLineToPoint(CGPointMake(46.5, 30.5))
    boxPath.addLineToPoint(CGPointMake(46.5, 41.5))
    boxPath.addLineToPoint(CGPointMake(23.5, 41.5))
    boxPath.addLineToPoint(CGPointMake(23.5, 30.5))
    boxPath.closePath
    white.setFill
    boxPath.fill
    white.setStroke
    boxPath.lineWidth = 1
    boxPath.stroke

    if @nel_baule == 1
      ## arrowDownload Drawing
      arrowDownloadPath = UIBezierPath.bezierPath
      arrowDownloadPath.moveToPoint(CGPointMake(29, 27))
      arrowDownloadPath.addLineToPoint(CGPointMake(33, 27))
      arrowDownloadPath.addLineToPoint(CGPointMake(33, 20))
      arrowDownloadPath.addLineToPoint(CGPointMake(37, 20))
      arrowDownloadPath.addLineToPoint(CGPointMake(37, 27))
      arrowDownloadPath.addLineToPoint(CGPointMake(41, 27))
      arrowDownloadPath.addLineToPoint(CGPointMake(35, 34))
      arrowDownloadPath.addLineToPoint(CGPointMake(35, 34))
      arrowDownloadPath.addLineToPoint(CGPointMake(29, 27))
      arrowDownloadPath.closePath
      arrowDownloadPath.lineCapStyle = KCGLineCapRound
      white.setFill
      arrowDownloadPath.fill
    else
      ## arrowUpload Drawing
      arrowUploadPath = UIBezierPath.bezierPath
      arrowUploadPath.moveToPoint(CGPointMake(29, 27))
      arrowUploadPath.addLineToPoint(CGPointMake(33, 27))
      arrowUploadPath.addLineToPoint(CGPointMake(33, 34))
      arrowUploadPath.addLineToPoint(CGPointMake(37, 34))
      arrowUploadPath.addLineToPoint(CGPointMake(37, 27))
      arrowUploadPath.addLineToPoint(CGPointMake(41, 27))
      arrowUploadPath.addLineToPoint(CGPointMake(35, 20))
      arrowUploadPath.addLineToPoint(CGPointMake(35, 20))
      arrowUploadPath.addLineToPoint(CGPointMake(29, 27))
      arrowUploadPath.closePath
      arrowUploadPath.lineCapStyle = KCGLineCapRound
      white.setFill
      arrowUploadPath.fill
    end
  end

end