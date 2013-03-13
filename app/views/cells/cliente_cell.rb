class ClienteCell < UITableViewCell
  
  attr_reader :cliente

  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
    super
    #setupBackground
    addClienteLabel
    addCittaLabel
    addDafareBadge
    addInsospesoBadge
    self
  end

  def cliente=(cliente)
    @cliente = cliente
    if @cliente
      @clienteLabel.text = @cliente.nome
      @cittaLabel.text = "#{@cliente.citta}"

      if @cliente.appunti_da_fare == nil || @cliente.appunti_da_fare == 0
        @customBadge.hidden = true
      else
        @customBadge.hidden = false
        @customBadge.autoBadgeSizeWithString("#{@cliente.appunti_da_fare}")
      end

      if @cliente.appunti_in_sospeso == nil || @cliente.appunti_in_sospeso == 0
        @customBadge2.hidden = true
      else
        @customBadge2.hidden = false
        @customBadge2.autoBadgeSizeWithString("#{@cliente.appunti_in_sospeso}")
      end

      self.setNeedsLayout
    end
    @cliente
  end

  def layoutSubviews
    super

    @clienteLabel.frame = CGRectMake(20, 2,  200, 22)
    @cittaLabel.frame   = CGRectMake(20, 24, 200, 18)

    @customBadge.frame = CGRectMake(288 - @customBadge.frame.size.width, 8, @customBadge.frame.size.width, @customBadge.frame.size.height)
    @customBadge2.frame = CGRectMake(260 - @customBadge2.frame.size.width, 8, @customBadge2.frame.size.width, @customBadge2.frame.size.height)
  end

  def setSelected(selected, animated:animated)
    super
    setShadowOffset(selected)
  end

  def setHighlighted(highlighted, animated:animated)
    super
    setShadowOffset(highlighted)
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

    def setShadowOffset(value)
      shadowOffset = value ? CGSizeZero : CGSizeMake(0, 1)
      @clienteLabel.shadowOffset = shadowOffset
      @cittaLabel.shadowOffset = shadowOffset
    end
    
    def setupBackground
      bg = "bg.png".uiimage
      bgView = UIImageView.alloc.initWithImage bg
      self.backgroundView = bgView
    end

    def addClienteLabel
      @clienteLabel = UILabel.alloc.init
      @clienteLabel.font         = UIFont.boldSystemFontOfSize(18)
      @clienteLabel.textColor    = UIColor.colorWithWhite(0.25, alpha:1.0)
      # @clienteLabel.shadowColor  = UIColor.whiteColor
      # @clienteLabel.shadowOffset = CGSizeMake(0, 1)
      @clienteLabel.backgroundColor = UIColor.clearColor
      @clienteLabel.highlightedTextColor = UIColor.whiteColor
      self.contentView.addSubview(@clienteLabel)
    end


    def addCittaLabel
      @cittaLabel = UILabel.alloc.init
      @cittaLabel.font = UIFont.systemFontOfSize(14)
      @cittaLabel.textColor = UIColor.colorWithWhite(0.55, alpha:1.0)
      @cittaLabel.shadowColor = UIColor.whiteColor
      @cittaLabel.shadowOffset = CGSizeMake(0, 1);
      @cittaLabel.backgroundColor = UIColor.clearColor
      @cittaLabel.highlightedTextColor = UIColor.whiteColor
      self.contentView.addSubview(@cittaLabel)
    end

    def addDafareBadge
      @customBadge = CustomBadge.customBadgeWithString("0", 
                           withStringColor:UIColor.whiteColor, 
                            withInsetColor:UIColor.redColor,
                            withBadgeFrame:true,
                       withBadgeFrameColor:UIColor.whiteColor, 
                             withScale:1,
                           withShining:true)
        

      self.contentView.addSubview(@customBadge) 
    end

    def addInsospesoBadge
      @customBadge2 = CustomBadge.customBadgeWithString("0", 
                           withStringColor:UIColor.whiteColor, 
                            withInsetColor:UIColor.greenColor,
                            withBadgeFrame:true,
                       withBadgeFrameColor:UIColor.whiteColor, 
                             withScale:1,
                           withShining:true)
        

      self.contentView.addSubview(@customBadge2) 
    end
end