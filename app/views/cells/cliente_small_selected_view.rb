class ClienteSmallSelectedView < UIView

  def initWithFrame(frame)
    super.tap do
      self.setBackgroundColor(UIColor.clearColor)
    end
  end

  def drawRect(rect)

    ## General Declarations
    context = UIGraphicsGetCurrentContext()

    ## Color Declarations
    fillColor = UIColor.colorWithRed(0.438, green:0, blue:0.657, alpha:1)
    strokeColor = UIColor.colorWithRed(0, green:0, blue:0, alpha:1)
    fillColor2 = UIColor.colorWithRed(0.856, green:0.856, blue:0.856, alpha:1)
    color2 = UIColor.colorWithRed(0.143, green:0, blue:0.429, alpha:1)
    color3 = UIColor.colorWithRed(0, green:0, blue:0.886, alpha:1)

    ## Shadow Declarations
    shadow = color2
    shadowOffset = CGSizeMake(2.1, 1.1)
    shadowBlurRadius = 9
    shadow2 = fillColor2
    shadow2Offset = CGSizeMake(0.1, 1.1)
    shadow2BlurRadius = 0

    ## Rounded Rectangle 2 Drawing
    roundedRectangle2Path = UIBezierPath.bezierPathWithRoundedRect(CGRectMake(12, 7, 298, 30), cornerRadius:4)
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor)
    CGContextRestoreGState(context)

    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor)
    color3.setStroke
    roundedRectangle2Path.lineWidth = 1
    roundedRectangle2Path.stroke
    CGContextRestoreGState(context)


    ## Rounded Rectangle Drawing
    roundedRectanglePath = UIBezierPath.bezierPathWithRoundedRect(CGRectMake(12, 7, 298, 30), cornerRadius:4)
    fillColor.setFill
    roundedRectanglePath.fill

    ### Rounded Rectangle Inner Shadow
    roundedRectangleBorderRect = CGRectInset(roundedRectanglePath.bounds, -shadowBlurRadius, -shadowBlurRadius)
    roundedRectangleBorderRect = CGRectOffset(roundedRectangleBorderRect, -shadowOffset.width, -shadowOffset.height)
    roundedRectangleBorderRect = CGRectInset(CGRectUnion(roundedRectangleBorderRect, roundedRectanglePath.bounds), -1, -1)

    roundedRectangleNegativePath = UIBezierPath.bezierPathWithRect(roundedRectangleBorderRect)
    roundedRectangleNegativePath.appendPath(roundedRectanglePath)
    roundedRectangleNegativePath.usesEvenOddFillRule = true

    CGContextSaveGState(context)# {
        xOffset = shadowOffset.width + roundedRectangleBorderRect.size.width.ceil
        yOffset = shadowOffset.height
        CGContextSetShadowWithColor(context,
            CGSizeMake(xOffset + 0.1, yOffset + 0.1),
            shadowBlurRadius,
            shadow.CGColor)

        roundedRectanglePath.addClip
        transform = CGAffineTransformMakeTranslation(-roundedRectangleBorderRect.size.width.ceil, 0)
        roundedRectangleNegativePath.applyTransform(transform)
        UIColor.grayColor.setFill
        roundedRectangleNegativePath.fill# }
    CGContextRestoreGState(context)

    strokeColor.setStroke
    roundedRectanglePath.lineWidth = 1
    roundedRectanglePath.stroke











  end

end