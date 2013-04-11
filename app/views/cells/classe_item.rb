class ClasseItem < UICollectionViewCell

  attr_accessor :classe
  attr_accessor :status


  def initWithFrame(frame)
    
    super.tap do |cell|
      
      cell.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
      
      @classe_label = UILabel.alloc.initWithFrame([[25, 44], [32, 28]]).tap do |label|
         #label.translatesAutoresizingMaskIntoConstraints = false
         label.numberOfLines = 1
         label.font = UIFont.boldSystemFontOfSize(20.0)
         label.textAlignment = UITextAlignmentCenter
         label.backgroundColor = UIColor.clearColor
         label.textColor = UIColor.darkGrayColor
         label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
         cell.contentView.addSubview(label)
      end

      @note_text = UITextView.alloc.initWithFrame([[90, 13], [242, 19]]).tap do |text|
        text.setFont(UIFont.fontWithName("Trebuchet MS", size:13.0))
        text.setUserInteractionEnabled(false)
        # text.editable = false  #   preserva lo scroll ma sbaglia tap
        text.textAlignment = UITextAlignmentLeft
        text.backgroundColor = UIColor.clearColor
        text.textColor = UIColor.darkGrayColor
        #text.highlightedTextColor = UIColor.whiteColor

        text.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
        cell.contentView.addSubview(text)
      end

      @alunni_label = UILabel.alloc.initWithFrame([[35, 122], [31, 14]]).tap do |label|
         #label.translatesAutoresizingMaskIntoConstraints = false
         label.numberOfLines = 1
         label.font = UIFont.systemFontOfSize(12.0)
         label.textAlignment = UITextAlignmentRight
         label.backgroundColor = UIColor.clearColor
         label.textColor = UIColor.darkGrayColor
         label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
         cell.contentView.addSubview(label)
      end

      @adozione_image =  UIImageView.alloc.initWithFrame([[90, 103], [50, 60]]).tap do |imgv|
        #imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
        imgv.backgroundColor = UIColor.clearColor
        #imgv.layer.cornerRadius = 5
        imgv.alpha = 0.4
        imgv.layer.masksToBounds = true
        self.contentView.addSubview(imgv)

        imgv.when_tapped { toggleKit(imgv) }
      end

      @adozione_image_2 =  UIImageView.alloc.initWithFrame([[140, 103], [50, 60]]).tap do |imgv|
        #imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
        imgv.backgroundColor = UIColor.clearColor
        #imgv.layer.cornerRadius = 5
        imgv.alpha = 0.4
        imgv.layer.masksToBounds = true
        self.contentView.addSubview(imgv)

        imgv.when_tapped { toggleKit(imgv) }
      end

      @adozione_image_3 =  UIImageView.alloc.initWithFrame([[190, 103], [50, 60]]).tap do |imgv|
        #imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
        imgv.backgroundColor = UIColor.clearColor
        #imgv.layer.cornerRadius = 5
        imgv.alpha = 0.4
        imgv.layer.masksToBounds = true
        self.contentView.addSubview(imgv)

        imgv.when_tapped { toggleKit(imgv) }
      end


      @vacanze_image = UIImageView.alloc.initWithFrame([[271.5, 93], [50, 50]]).tap do |imgv|
        
        imgv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
        imgv.setImage UIImage.imageNamed("vacanze_vuoto")
        #imgv.layer.cornerRadius = 5
        #imgv.alpha = 0.4
        #imgv.layer.masksToBounds = true
        self.contentView.addSubview(imgv)

        imgv.when_tapped { toggle_vacanza(imgv) } 
      end 

      @vacanze_image_1 = UIImageView.alloc.initWithFrame([[331.5, 93], [50, 50]]).tap do |imgv|
        
        imgv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
        imgv.setImage UIImage.imageNamed("vacanze_vuoto")
        #imgv.layer.cornerRadius = 5
        #imgv.alpha = 0.4
        #imgv.layer.masksToBounds = true
        self.contentView.addSubview(imgv)

        imgv.when_tapped { toggle_vacanza(imgv) } 
      end  


      @vacanze_image_2 = UIImageView.alloc.initWithFrame([[393.5, 93], [50, 50]]).tap do |imgv|
        
        imgv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
        imgv.setImage UIImage.imageNamed("vacanze_vuoto")
        #imgv.layer.cornerRadius = 5
        #imgv.alpha = 0.4
        #imgv.layer.masksToBounds = true
        self.contentView.addSubview(imgv)

        imgv.when_tapped { toggle_vacanza(imgv) } 
      end      

      cell.contentView.autoresizesSubviews = true

      cell.backgroundColor = UIColor.clearColor

      # # A thin border.
      # cell.layer.borderColor = UIColor.lightGrayColor.CGColor;
      # cell.layer.borderWidth = 1;

      # # Drop shadow.
      # cell.layer.shadowColor = UIColor.blackColor.CGColor;
      # cell.layer.shadowOpacity = 0.5
      # cell.layer.shadowRadius = 3.0
      # cell.layer.shadowOffset = CGSizeMake(3, 3);

      # # selectedBackground
      # bgView = UIView.alloc.initWithFrame(self.frame)
      # bgView.backgroundColor = UIColor.blueColor
      # bgView.layer.borderColor = UIColor.whiteColor.CGColor
      # bgView.layer.borderWidth = 4
      # #bgView.layer.cornerRadius = 10
      # cell.selectedBackgroundView = bgView

      cell.clipsToBounds = false
    end
  end
  
  def classe=(classe)
    @classe = classe
    if @classe
      @classe_label.text = "#{@classe.num_classe} #{@classe.sezione}"
      @alunni_label.text = "#{@classe.nr_alunni}b"
      @note_text.text = @classe.note

      mask = "mask-adozione".uiimage

      if @classe.adozioni.count == 1
        @adozione_image.hidden = false
        @adozione_image.setImage(self.appImage(UIImage.imageNamed("#{@classe.adozioni.objectAtIndex(0).sigla}.jpeg"), mask))   
        @adozione_image_2.hidden = true
        @adozione_image_3.hidden = true
      
      elsif @classe.adozioni.count == 2 
        @adozione_image.setImage(self.appImage(UIImage.imageNamed("#{@classe.adozioni.objectAtIndex(0).sigla}.jpeg"), mask))   
        @adozione_image_2.setImage(self.appImage(UIImage.imageNamed("#{@classe.adozioni.objectAtIndex(1).sigla}.jpeg"), mask))
        @adozione_image.hidden = false
        @adozione_image_2.hidden = false
        @adozione_image_3.hidden = true

      elsif @classe.adozioni.count >= 3 
        @adozione_image.setImage(self.appImage(UIImage.imageNamed("#{@classe.adozioni.objectAtIndex(0).sigla}.jpeg"), mask))   
        @adozione_image_2.setImage(self.appImage(UIImage.imageNamed("#{@classe.adozioni.objectAtIndex(1).sigla}.jpeg"), mask))  
        @adozione_image_3.setImage(self.appImage(UIImage.imageNamed("#{@classe.adozioni.objectAtIndex(2).sigla}.jpeg"), mask))
        @adozione_image.hidden = false
        @adozione_image_2.hidden = false
        @adozione_image_3.hidden = false
 
      else
        @adozione_image.hidden = true
        @adozione_image_2.hidden = true
        @adozione_image_3.hidden = true
      end

    end
    @classe
  end

  def appImage(image, maskImage)
    
    if image
      maskRef = maskImage.CGImage
      mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
              CGImageGetHeight(maskRef),
              CGImageGetBitsPerComponent(maskRef),
              CGImageGetBitsPerPixel(maskRef),
              CGImageGetBytesPerRow(maskRef),
              CGImageGetDataProvider(maskRef), nil, false)
   
      masked = CGImageCreateWithMask(image.CGImage, mask)
      return UIImage.imageWithCGImage(masked)
    end
  end
 
  def toggleKit(sender)
    sender.alpha == 1 ? sender.alpha = 0.4 : sender.alpha = 1
  end

  def toggle_vacanza(sender)

    if @status.nil? || @status == "vacanze_vuoto"
      sender.setImage "vacanze_fiuto".uiimage
      @status = "vacanze_fiuto"
    elsif @status == "vacanze_fiuto"
      sender.setImage "vacanze_fiuto_adottato".uiimage
      @status = "vacanze_fiuto_adottato"
    elsif @status == "vacanze_fiuto_adottato"
      sender.setImage "vacanze_fiuto_ritirato".uiimage
      @status = "vacanze_fiuto_ritirato"
    elsif @status == "vacanze_fiuto_ritirato"
      sender.setImage "vacanze_vuoto".uiimage
      @status = "vacanze_vuoto"
    end
      
  end


  def drawRect rect
    
    ## General Declarations
    context = UIGraphicsGetCurrentContext()

    ## Color Declarations
    fillColor = UIColor.colorWithRed(1, green:1, blue:1, alpha:1)
    strokeColor = UIColor.colorWithRed(0, green:0, blue:0, alpha:1)
    color = UIColor.colorWithRed(1, green:0.114, blue:0.114, alpha:0.468)
    color2 = UIColor.colorWithRed(0.41, green:1, blue:0.114, alpha:0.61)
    color3 = UIColor.colorWithRed(1, green:1, blue:0.114, alpha:1)

    ## Shadow Declarations
    shadow = strokeColor
    shadowOffset = CGSizeMake(3.1, 3.1)
    shadowBlurRadius = 5

    ## Frames
    frame = CGRectMake(0, 0, 456, 151)

    ## Rounded Rectangle Drawing
    roundedRectanglePath = UIBezierPath.bezierPathWithRoundedRect(CGRectMake(CGRectGetMinX(frame) + 2.5, CGRectGetMinY(frame) + 1.5, 449, 144), cornerRadius:4)
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor)
    fillColor.setFill
    roundedRectanglePath.fill
    CGContextRestoreGState(context)

    strokeColor.setStroke
    roundedRectanglePath.lineWidth = 1
    roundedRectanglePath.stroke


    ## Bezier Drawing
    bezierPath = UIBezierPath.bezierPath
    bezierPath.moveToPoint(CGPointMake(CGRectGetMinX(frame) + 75.5, CGRectGetMinY(frame) + 1.5))
    bezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 75.5, CGRectGetMinY(frame) + 142.5))
    strokeColor.setStroke
    bezierPath.lineWidth = 1
    bezierPatternArray = [4, 4, 4, 4]; bezierPattern = Pointer.new(:float, bezierPatternArray.length); bezierPatternArray.each_index{|idx| bezierPattern[idx] = bezierPatternArray[idx] }
    bezierPath.setLineDash bezierPattern, count: 4, phase: 0
    bezierPath.stroke


    ## Bezier 2 Drawing
    bezier2Path = UIBezierPath.bezierPath
    bezier2Path.moveToPoint(CGPointMake(CGRectGetMinX(frame) + 76.5, CGRectGetMinY(frame) + 90.5))
    bezier2Path.addLineToPoint(CGPointMake(CGRectGetMinX(frame) + 451.5, CGRectGetMinY(frame) + 90.5))
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor)
    fillColor.setFill
    bezier2Path.fill
    CGContextRestoreGState(context)

    strokeColor.setStroke
    bezier2Path.lineWidth = 1
    bezier2PatternArray = [4, 4, 4, 4]; bezier2Pattern = Pointer.new(:float, bezier2PatternArray.length); bezier2PatternArray.each_index{|idx| bezier2Pattern[idx] = bezier2PatternArray[idx] }
    bezier2Path.setLineDash bezier2Pattern, count: 4, phase: 0
    bezier2Path.stroke

  end

end