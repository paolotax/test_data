class ClienteTitleView < UIView

  attr_reader :cliente

  def initWithFrame(frame)
    super.tap do
      
      @bauleButton = BauleButton.alloc.initWithFrame [[18 ,28], [54,71]]
      @bauleButton.backgroundColor = UIColor.clearColor
      self.addSubview @bauleButton  
    
      @scuolaLabel = UILabel.alloc.initWithFrame [[81, 28], [263, 21]]
      @scuolaLabel.backgroundColor = UIColor.clearColor 
      self.addSubview @scuolaLabel

      @indirizzoLabel = UILabel.alloc.initWithFrame [[81, 49], [263, 21]]
      @indirizzoLabel.backgroundColor = UIColor.clearColor 
      self.addSubview @indirizzoLabel

      @cittaLabel = UILabel.alloc.initWithFrame [[81, 70], [263, 21]]
      @cittaLabel.backgroundColor = UIColor.clearColor 
      self.addSubview @cittaLabel
    end
  end

  def cliente=(cliente)
    @cliente = cliente

    @scuolaLabel.text = cliente.nome
    @scuolaLabel.fit_to_size(18)
    @indirizzoLabel.text = cliente.indirizzo
    @indirizzoLabel.fit_to_size(15)
    @cittaLabel.text = "#{cliente.cap} #{cliente.citta} #{cliente.provincia}"
    @cittaLabel.fit_to_size(15)

    @bauleButton.nel_baule = cliente.nel_baule
    @bauleButton.on(:touch) {
      if cliente.nel_baule?
        self.cliente.nel_baule = 0
      else
        self.cliente.nel_baule = 1
      end
      cliente.update
      Store.shared.persist
      @bauleButton.nel_baule = cliente.nel_baule
      "baule_did_change".post_notification
    }

    self.setNeedsDisplay
  end


  def layoutSubviews
    super
    puts "layoutSubviews"
  end

  def drawRect(rect)
    puts "drawRect"
    ## General Declarations
    colorSpace = CGColorSpaceCreateDeviceRGB()
    context = UIGraphicsGetCurrentContext()

    ## Color Declarations
    fillColor = UIColor.colorWithRed(1, green:1, blue:1, alpha:1)
    strokeColor = UIColor.colorWithRed(0.763, green:0.763, blue:0.763, alpha:1)
    color = UIColor.colorWithRed(0.333, green:0.333, blue:0.333, alpha:1)
    color4 = UIColor.colorWithRed(0.052, green:0.212, blue:0.531, alpha:0.596)

    ## Gradient Declarations
    gradientColors = [ 
        fillColor.CGColor, 
        UIColor.colorWithRed(0.881, green:0.881, blue:0.881, alpha:1).CGColor, 
        strokeColor.CGColor]
    gradientLocationsArray = [0, 0.68, 1]
    gradientLocations = Pointer.new(:float, gradientLocationsArray.length)
    gradientLocationsArray.each_index{|idx| gradientLocations[idx] = gradientLocationsArray[idx] }
    gradient = CGGradientCreateWithColors(colorSpace, gradientColors, gradientLocations)
    gradient2Colors = [ 
        strokeColor.CGColor, 
        UIColor.colorWithRed(0.881, green:0.881, blue:0.881, alpha:1).CGColor, 
        fillColor.CGColor]
    gradient2LocationsArray = [0, 0.26, 0.96]
    gradient2Locations = Pointer.new(:float, gradient2LocationsArray.length)
    gradient2LocationsArray.each_index{|idx| gradient2Locations[idx] = gradient2LocationsArray[idx] }
    gradient2 = CGGradientCreateWithColors(colorSpace, gradient2Colors, gradient2Locations)

    ## Shadow Declarations
    shadow = strokeColor
    shadowOffset = CGSizeMake(-1.1, 1.1)
    shadowBlurRadius = 5

    ## Image Declarations
    buttonBaule = UIImage.imageNamed "baule-button"
    buttonBaulePattern = UIColor.colorWithPatternImage buttonBaule

    ## Frames
    frame = CGRectMake(0, 0, 388, 121)

    ## Group# {
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor)
    CGContextBeginTransparencyLayer(context, nil)

    ## Rounded Rectangle Drawing
    roundedRectangleRect = CGRectMake(CGRectGetMinX(frame) + 1.5, CGRectGetMinY(frame) + 2.5, 372, 114)
    roundedRectanglePath = UIBezierPath.bezierPathWithRoundedRect(roundedRectangleRect, cornerRadius:4)
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor)
    CGContextBeginTransparencyLayer(context, nil)
    roundedRectanglePath.addClip
    CGContextDrawLinearGradient(context, gradient2,
        CGPointMake(CGRectGetMidX(roundedRectangleRect), CGRectGetMinY(roundedRectangleRect)),
        CGPointMake(CGRectGetMidX(roundedRectangleRect), CGRectGetMaxY(roundedRectangleRect)),
        0)
    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)

    ## Rectangle 2 Drawing
    rectangle2Rect = CGRectMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 8, 358, 102)
    rectangle2Path = UIBezierPath.bezierPathWithRoundedRect(rectangle2Rect, cornerRadius:4)
    CGContextSaveGState(context)
    rectangle2Path.addClip
    CGContextDrawLinearGradient(context, gradient,
        CGPointMake(CGRectGetMidX(rectangle2Rect), CGRectGetMinY(rectangle2Rect)),
        CGPointMake(CGRectGetMidX(rectangle2Rect), CGRectGetMaxY(rectangle2Rect)),
        0)
    CGContextRestoreGState(context)

    ### Rectangle 2 Inner Shadow
    rectangle2BorderRect = CGRectInset(rectangle2Path.bounds, -shadowBlurRadius, -shadowBlurRadius)
    rectangle2BorderRect = CGRectOffset(rectangle2BorderRect, -shadowOffset.width, -shadowOffset.height)
    rectangle2BorderRect = CGRectInset(CGRectUnion(rectangle2BorderRect, rectangle2Path.bounds), -1, -1)

    rectangle2NegativePath = UIBezierPath.bezierPathWithRect(rectangle2BorderRect)
    rectangle2NegativePath.appendPath(rectangle2Path)
    rectangle2NegativePath.usesEvenOddFillRule = true

    CGContextSaveGState(context)
    
    xOffset = shadowOffset.width + rectangle2BorderRect.size.width.ceil
    yOffset = shadowOffset.height
    CGContextSetShadowWithColor(context,
        CGSizeMake(xOffset + 0.1, yOffset + 0.1),
        shadowBlurRadius,
        shadow.CGColor)

    rectangle2Path.addClip
    transform = CGAffineTransformMakeTranslation(-rectangle2BorderRect.size.width.ceil, 0)
    rectangle2NegativePath.applyTransform(transform)
    UIColor.grayColor.setFill
    rectangle2NegativePath.fill

    CGContextRestoreGState(context)

    color4.setStroke
    rectangle2Path.lineWidth = 2
    rectangle2PatternArray = [6, 2, 6, 2]
    rectangle2Pattern = Pointer.new(:float, rectangle2PatternArray.length)
    rectangle2PatternArray.each_index{|idx| rectangle2Pattern[idx] = rectangle2PatternArray[idx] }
    rectangle2Path.setLineDash rectangle2Pattern, count: 4, phase: 2.5
    rectangle2Path.stroke

    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)

  end



end