class BauleView < UIView


  def drawRect(rect)

    ## General Declarations
    colorSpace = CGColorSpaceCreateDeviceRGB()
    context = UIGraphicsGetCurrentContext()

    ## Color Declarations
    iconShadow = UIColor.colorWithRed(0, green:0, blue:0, alpha:0.8)
    baseColor = UIColor.colorWithRed(0.637, green:0.156, blue:0.687, alpha:1)


    # CGFloat baseColorRGBA[4]
    # [baseColor getRed: &baseColorRGBA[0] green: &baseColorRGBA[1] blue: &baseColorRGBA[2] alpha: &baseColorRGBA[3]]

    # baseGradientBottomColor = UIColor.colorWithRed((baseColorRGBA[0] * 0.8), green:(baseColorRGBA[1] * 0.8), blue:(baseColorRGBA[2] * 0.8), alpha:(baseColorRGBA[3] * 0.8 + 0.2))

    baseGradientBottomColor = UIColor.colorWithRed(0.637, green:0.156, blue:0.687, alpha:1)


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


  end

end