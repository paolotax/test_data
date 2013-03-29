class AppuntoSmallView < UIView

  def initWithFrame(frame)
    super.tap do
      self.setBackgroundColor(UIColor.clearColor)
    end
  end

  def drawRect(rect)

    ## General Declarations
    context = UIGraphicsGetCurrentContext()

    ## Color Declarations
    fillColor = UIColor.colorWithRed(1, green:1, blue:1, alpha:1)
    strokeColor = UIColor.colorWithRed(0, green:0, blue:0, alpha:1)
    lineColor = UIColor.colorWithRed(0.976, green:0.757, blue:0.757, alpha:1)
    grayLineColor = UIColor.colorWithRed 0.8, green: 0.8, blue: 0.8, alpha: 1

    ## Shadow Declarations
    shadow = strokeColor
    shadowOffset = CGSizeMake(4.1, 4.1)
    shadowBlurRadius = 5

    ## Rounded Rectangle Drawing
    roundedRectanglePath = UIBezierPath.bezierPathWithRoundedRect CGRectMake(12, 6, 298, 69),byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight, cornerRadii: CGSizeMake(15, 15)
    roundedRectanglePath.closePath
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor)
    fillColor.setFill
    roundedRectanglePath.fill
    CGContextRestoreGState(context)

    ## Bezier Drawing
    [0, 2].each do |l|
      bezierPath = UIBezierPath.bezierPath
      bezierPath.moveToPoint CGPointMake(44 + l, 7)
      bezierPath.addCurveToPoint CGPointMake(44 + l, 75), controlPoint1: CGPointMake(44 + l, 7), controlPoint2: CGPointMake(44 + l, 75)
      lineColor.setStroke
      bezierPath.lineWidth = 1
      bezierPath.stroke
    end

    ## Bezier 2 Drawing
    bezier2Path = UIBezierPath.bezierPath
    bezier2Path.moveToPoint(CGPointMake(12, 75))
    bezier2Path.addCurveToPoint(CGPointMake(310, 75), controlPoint1:CGPointMake(310, 75), controlPoint2:CGPointMake(310, 75))
    grayLineColor.setStroke
    bezier2Path.lineWidth = 1
    bezier2PatternArray = [1, 1, 1, 1]
    bezier2Pattern = Pointer.new(:float, bezier2PatternArray.length)
    bezier2PatternArray.each_index{|idx| bezier2Pattern[idx] = bezier2PatternArray[idx] }
    bezier2Path.setLineDash bezier2Pattern, count: 4, phase: 0
    bezier2Path.stroke

  end

end