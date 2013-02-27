class ClienteAppuntoCell < UICollectionViewCell

  MARGIN = 2

  attr_accessor :appunto, :deleteButton, :deleteButtonImg

  def initWithFrame(frame)
    
    super.tap do |cell|

      # cell.backgroundColor = UIColor.blueColor
      insetView = UIView.alloc.initWithFrame(CGRectInset(self.bounds, 15, 15))
      insetView.backgroundColor = UIColor.colorWithPatternImage("postit.png".uiimage)

      insetView.layer.shadowOpacity = 0.5
      insetView.layer.shadowOffset  = CGSize.new(0, 3)
      insetView.layer.shadowPath    = UIBezierPath.bezierPathWithRect(CGRectInset(insetView.bounds, 1, 1)).CGPath

      cell.contentView.addSubview(insetView)

      cell.deleteButton = UIButton.alloc.initWithFrame(CGRectMake(0, 0, 35, 35))
      unless deleteButtonImg
        buttonFrame = self.deleteButton.frame
        UIGraphicsBeginImageContext(buttonFrame.size)
        sz = [buttonFrame.size.width, buttonFrame.size.height].min
        path = UIBezierPath.bezierPathWithArcCenter(CGPointMake(buttonFrame.size.width/2, buttonFrame.size.height/2),     radius:sz/2-MARGIN, startAngle:0, endAngle:(Math::PI * 2), clockwise:true)
        path.moveToPoint(CGPointMake(MARGIN, MARGIN))
        path.addLineToPoint(CGPointMake(sz-MARGIN, sz-MARGIN))
        path.moveToPoint(CGPointMake(MARGIN, sz-MARGIN))
        path.addLineToPoint(CGPointMake(sz-MARGIN, MARGIN))
        UIColor.redColor.setFill
        UIColor.whiteColor.setStroke
        path.setLineWidth(2.0)
        path.fill
        path.stroke
        deleteButtonImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
      end
      cell.deleteButton.setImage(deleteButtonImg, forState:UIControlStateNormal)
      cell.contentView.addSubview(self.deleteButton)

      cell.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
      
      @status_image =  UIImageView.alloc.initWithFrame([[10, 10], [25, 25]]).tap do |imgv|
        #imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
        imgv.backgroundColor = UIColor.clearColor
        insetView.addSubview(imgv)
      end
      
      @destinatario_label = UILabel.alloc.initWithFrame([[15, 35], [170, 20]]).tap do |label|
         #label.translatesAutoresizingMaskIntoConstraints = false
         label.numberOfLines = 1

         label.setFont(UIFont.fontWithName("Trebuchet MS-Bold", size:13.0))
         label.textAlignment = UITextAlignmentCenter
         label.backgroundColor = UIColor.clearColor
         label.textColor = UIColor.darkGrayColor
         label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
         insetView.addSubview(label)
      end

      @note_label = UILabel.alloc.initWithFrame([[15, 55], [170, 120]]).tap do |label|
         #label.translatesAutoresizingMaskIntoConstraints = false
         label.numberOfLines = 0
         label.setFont(UIFont.fontWithName("Trebuchet MS", size:13.0))
         label.textAlignment = UITextAlignmentLeft
         label.backgroundColor = UIColor.clearColor
         label.textColor = UIColor.darkGrayColor
         label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
         insetView.addSubview(label)
      end

      @data_label = UILabel.alloc.initWithFrame([[15, 5], [170, 15]]).tap do |label|
         #label.translatesAutoresizingMaskIntoConstraints = false
         label.numberOfLines = 0
         label.setFont(UIFont.fontWithName("Trebuchet MS", size:11.0))
         label.textColor     = UIColor.colorWithWhite(0.45, alpha:1.0)
         label.textAlignment = UITextAlignmentRight
         # label.shadowColor = UIColor.whiteColor
         # label.shadowOffset = CGSizeMake(0, 1);
         label.backgroundColor = UIColor.clearColor
         insetView.addSubview(label)
      end

      @importo_label = UILabel.alloc.initWithFrame([[15, 180], [170, 15]]).tap do |label|
         #label.translatesAutoresizingMaskIntoConstraints = false
         label.numberOfLines = 0
         label.setFont(UIFont.fontWithName("Trebuchet MS", size:13.0))
         label.textAlignment   = UITextAlignmentRight
         label.backgroundColor = UIColor.clearColor
         label.textColor       = UIColor.darkGrayColor
         # label.shadowOffset = CGSizeMake(0, 1);
         label.backgroundColor = UIColor.clearColor
         insetView.addSubview(label)
      end

      @updated_at = UILabel.alloc.initWithFrame([[-15, 92], [230, 15]]).tap do |label|
        
        label.numberOfLines = 0
        label.setFont(UIFont.fontWithName("Trebuchet MS-Bold", size:11.0))
        label.textAlignment   = UITextAlignmentCenter
        label.backgroundColor = UIColor.clearColor
        label.textColor       = UIColor.redColor
        label.backgroundColor = UIColor.clearColor

        label.layer.transform = CATransform3DMakeRotation(315 * Math::PI / 180, 0, 0, 1)
        label.layer.opacity = 0.5
        label.hidden = true
        insetView.addSubview(label)
      end

      insetView.autoresizesSubviews = true

    end
  end
  
  def appunto=(appunto)
    @appunto = appunto
    if @appunto
      @destinatario_label.text = @appunto.destinatario
      
      @note_label.frame.width = 170
      @note_label.text = format_appunto
      @note_label.sizeToFit
      
      @importo_label.text = @appunto.righe.count == 0 ? "" : "copie #{appunto.totale_copie} € #{@appunto.totale_importo.string_with_style(:currency)}" 
      @data_label.text = format_date @appunto.created_at
      @status_image.setImage UIImage.imageNamed("task-#{@appunto.status}")

      if appunto.status == "completato" && appunto.updated_at != nil
        @updated_at.text = "ultima modifica: #{format_date appunto.updated_at}"
        @updated_at.hidden = false
      else
        @updated_at.hidden = true
      end

      self.setNeedsLayout
    end
    @appunto
  end

  def applyLayoutAttributes(layoutAttributes)
    if (layoutAttributes.isDeleteButtonHidden)
      self.deleteButton.layer.opacity = 0.0
      self.stopQuivering
    else
      self.deleteButton.layer.opacity = 1.0
      self.startQuivering
    end
  end    

  def startQuivering
    quiverAnim = CABasicAnimation.animationWithKeyPath("transform.rotation")
    startAngle = (-2) * Math::PI/180.0
    stopAngle = - startAngle
    quiverAnim.fromValue = NSNumber.numberWithFloat(startAngle)
    quiverAnim.toValue   = NSNumber.numberWithFloat(3 * stopAngle)
    quiverAnim.autoreverses = true
    quiverAnim.duration = 0.2
    quiverAnim.repeatCount = Float::INFINITY
    timeOffset = rand(100)/100 - 0.50
    quiverAnim.timeOffset = timeOffset
    layer = self.layer
    layer.addAnimation(quiverAnim, forKey:"quivering")
  end


  def stopQuivering
    layer = self.layer
    layer.removeAnimationForKey("quivering")
  end

  private

    def format_date(date)
      formatter = NSDateFormatter.alloc.init
      formatter.setLocale(NSLocale.alloc.initWithLocaleIdentifier("it_IT"))
      if date.year == Time.now.year
        formatter.setDateFormat("d MMM")
      else
        formatter.setDateFormat("MMM yy")
      end
      date_str = formatter.stringFromDate(date)
      date_str
    end

    def format_appunto
      righeText = ""
      unless @appunto.note.blank?
        righeText += @appunto.note + "\r\n"
      end 
      @appunto.righe.each do |r|
        righeText += "#{r.quantita} - #{r.titolo}\r\n"
      end
      righeText    
    end

end