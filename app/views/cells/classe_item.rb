class ClasseItem < UICollectionViewCell

  attr_accessor :classe

  def initWithFrame(frame)
    
    super.tap do |cell|
      
      cell.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
      
      @classe_label = UILabel.alloc.initWithFrame([[0, 0], [55, 50]]).tap do |label|
         #label.translatesAutoresizingMaskIntoConstraints = false
         label.numberOfLines = 1
         label.font = UIFont.boldSystemFontOfSize(20.0)
         label.textAlignment = UITextAlignmentCenter
         label.backgroundColor = UIColor.clearColor
         label.textColor = UIColor.darkGrayColor
         label.highlightedTextColor = UIColor.whiteColor
         label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
         cell.contentView.addSubview(label)
      end

      @note_text = UITextView.alloc.initWithFrame([[55, 5], [100, 40]]).tap do |text|
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

      @alunni_label = UILabel.alloc.initWithFrame([[0, 0], [157, 20]]).tap do |label|
         #label.translatesAutoresizingMaskIntoConstraints = false
         label.numberOfLines = 1
         label.font = UIFont.systemFontOfSize(12.0)
         label.textAlignment = UITextAlignmentRight
         label.backgroundColor = UIColor.clearColor
         label.textColor = UIColor.darkGrayColor
         label.highlightedTextColor = UIColor.whiteColor
         label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
         cell.contentView.addSubview(label)
      end

      @adozione_image =  UIImageView.alloc.initWithFrame([[5, 50], [50, 60]]).tap do |imgv|
        #imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
        imgv.backgroundColor = UIColor.clearColor
        imgv.layer.cornerRadius = 5
        imgv.alpha = 0.8
        imgv.layer.masksToBounds = true
        self.contentView.addSubview(imgv)
      end

      @adozione_image_2 =  UIImageView.alloc.initWithFrame([[55, 50], [50, 60]]).tap do |imgv|
        #imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
        imgv.backgroundColor = UIColor.clearColor
        imgv.layer.cornerRadius = 5
        imgv.alpha = 0.8
        imgv.layer.masksToBounds = true
        self.contentView.addSubview(imgv)
      end

      @adozione_image_3 =  UIImageView.alloc.initWithFrame([[105, 50], [50, 60]]).tap do |imgv|
        #imgv.translatesAutoresizingMaskIntoConstraints = false
        imgv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
        imgv.backgroundColor = UIColor.clearColor
        imgv.layer.cornerRadius = 5
        imgv.alpha = 0.8
        imgv.layer.masksToBounds = true
        self.contentView.addSubview(imgv)
      end

      cell.contentView.autoresizesSubviews = true

      # cell.backgroundColor = UIColor.clearColor
      # image = UIImage.imageNamed("bgclasse.png")
      # cell.layer.backgroundColor = UIColor.colorWithPatternImage(image).CGColor;
      cell.backgroundColor = UIColor.whiteColor

      # Rounded corners.
      cell.layer.cornerRadius = 10

      # A thin border.
      cell.layer.borderColor = UIColor.yellowColor.CGColor;
      cell.layer.borderWidth = 3;

      # Drop shadow.
      cell.layer.shadowColor = UIColor.blackColor.CGColor;
      cell.layer.shadowOpacity = 0.5
      cell.layer.shadowRadius = 3.0
      cell.layer.shadowOffset = CGSizeMake(3, 3);

      # selectedBackground
      bgView = UIView.alloc.initWithFrame(self.frame)
      bgView.backgroundColor = UIColor.blueColor
      bgView.layer.borderColor = UIColor.whiteColor.CGColor
      bgView.layer.borderWidth = 4
      bgView.layer.cornerRadius = 10
      cell.selectedBackgroundView = bgView

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
 


end