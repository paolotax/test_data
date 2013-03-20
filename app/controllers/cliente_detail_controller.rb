class ClienteDetailController < UIViewController


  KMinScale = 1.0
  KMaxScale = 3.0

  extend IB

  attr_accessor :cliente, 
      :popoverViewController,
      :appuntiCollectionController

  outlet :nomeLabel
  outlet :indirizzoLabel
  outlet :cittaLabel
  outlet :nuovoAppuntoButton
  outlet :navigaButton
  outlet :emailButton
  outlet :callButton

  outlet :segmentedControl

  outlet :collectionViewContainer

  def viewDidLoad
    super

    self.nuovoAppuntoButton.text = "Nuovo Appunto"
    self.nuovoAppuntoButton.textColor = UIColor.whiteColor
    self.nuovoAppuntoButton.textShadowColor = UIColor.darkGrayColor
    self.nuovoAppuntoButton.tintColor = UIColor.colorWithRed(0.45, green:0, blue:0, alpha:1)
    self.nuovoAppuntoButton.highlightedTintColor = UIColor.colorWithRed(0.75, green:0, blue:0, alpha:1)

    self.navigaButton.leftAccessoryImage = "16-car.png".uiimage
    self.emailButton.leftAccessoryImage = "btn-envelope.png".uiimage
    self.callButton.leftAccessoryImage =  "btn-phone.png".uiimage

  end

  def viewWillAppear(animated)
    super
    segmentedControl.removeAllSegments
    display_cliente if @cliente
  end

  def viewWillDisappear(animated)
    super
  end
 
  # def reload
  #   Cliente.reset
  #   Appunto.reset
  #   puts "Notificato"
  # end

  def display_cliente

    self.nomeLabel.text = cliente.nome
    self.indirizzoLabel.text = cliente.indirizzo
    self.cittaLabel.text = "#{cliente.cap} #{cliente.citta} #{cliente.provincia}"

    if cliente.telefono.blank?
      self.callButton.enabled = false
      callButton.alpha = 0.5
    end
    
    if cliente.email.blank?
      self.emailButton.enabled = false
      emailButton.alpha = 0.5
    end
    
    if cliente.cliente_tipo == "Scuola Primaria"
      segmentedControl.insertSegmentWithTitle("Appunti", atIndex:0,animated:false)
      segmentedControl.insertSegmentWithTitle("Classi", atIndex:1,animated:false)
      segmentedControl.selectedSegmentIndex = 0
    else
      segmentedControl.insertSegmentWithTitle("Appunti", atIndex:0,animated:false)
      segmentedControl.selectedSegmentIndex = 0
    end
    
    if self.popoverViewController
      self.popoverViewController.dismissPopoverAnimated(true)
    end


    @appuntiCollectionController = self.storyboard.instantiateViewControllerWithIdentifier("AppuntiCollection")
    @appuntiCollectionController.view.frame = self.collectionViewContainer.bounds
    @appuntiCollectionController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    @appuntiCollectionController.cliente = @cliente
    self.collectionViewContainer.addSubview(@appuntiCollectionController.view)

    @classiCollectionController = self.storyboard.instantiateViewControllerWithIdentifier("ClassiCollection")
    @classiCollectionController.cliente = @cliente

    self.addChildViewController(@appuntiCollectionController)
    @appuntiCollectionController.didMoveToParentViewController(self)



  end


  #  segues

  def prepareForSegue(segue, sender:sender)
    
    if segue.identifier.isEqualToString("showForm")
      segue.destinationViewController.cliente = @cliente
  
    elsif segue.identifier.isEqualToString("nuovoAppunto")

      if Device.ipad?
        controller = segue.destinationViewController.visibleViewController
        controller.presentedAsModal = true
      else
        controller = segue.destinationViewController
      end  
      if Device.ipad? && sender.class == Appunto_Appunto_
        appunto = sender
      else
        controller.isNew = true
        appunto = Appunto.add do |a|
          a.cliente = @cliente
          a.ClienteId = @cliente.ClienteId
          a.cliente_nome = @cliente.nome
          a.status = "da_fare"
          a.created_at = Time.now
        end 
      end

      controller.appunto = appunto
      controller.cliente = @cliente
    elsif segue.identifier.isEqualToString("showEditClassi")
      "dismiss_popover".add_observer(self, :dismissPopover)
      @popoverController = segue.popoverController
      @popoverController.delegate = self
      @popoverController.contentViewController.selected_classi = @classiCollectionController.selected_classi
    end
  end

  def dismissPopover
    @popoverController.dismissPopoverAnimated(true)
    "dismiss_popover".remove_observer(self, :dismissPopover)
  end

  def popoverControllerDidDismissPopover(popoverController)
    @popoverController.delegate = nil
    @popoverController = nil
  end 

  # actions

  def navigate(sender)
    url = NSURL.URLWithString("http://maps.apple.com/maps?q=#{@cliente.latitude},#{@cliente.longitude}")
    UIApplication.sharedApplication.openURL(url);
  end  

  def makeCall(sender)
    url = NSURL.URLWithString("tel://#{@cliente.telefono.split(" ").join}")
    UIApplication.sharedApplication.openURL(url);
  end  

  def sendEmail(sender)
    url = NSURL.URLWithString("mailto://#{@cliente.email}")
    UIApplication.sharedApplication.openURL(url);
  end  

  def collectionChange(sender)

    selectedSegment = sender.selectedSegmentIndex

    if selectedSegment == 0
      sourceView = @classiCollectionController
      destView = @appuntiCollectionController
    else
      sourceView = @appuntiCollectionController
      destView = @classiCollectionController
    end

    self.addChildViewController(destView)
    self.transitionFromViewController(sourceView,
                      toViewController:destView,
                              duration:0.5,
                               options:UIViewAnimationOptionTransitionFlipFromRight,
                            animations:lambda do
                                sourceView.view.removeFromSuperview
                                destView.view.frame = self.collectionViewContainer.bounds
                                self.collectionViewContainer.addSubview(destView.view)
                              end,
                            completion:lambda do |finished|
                                destView.didMoveToParentViewController(self)
                                sourceView.removeFromParentViewController
                              end
    )
  end

  # # splitView delegates

  # def splitViewController(svc, shouldHideViewController:vc, inOrientation:orientation)
  #   return false
  # end

  # # def splitViewController(svc, willHideViewController:vc, withBarButtonItem:barButtonItem, forPopoverController:pc)
  # #   barButtonItem.title = "Menu"
  # #   self.navigationItem.setLeftBarButtonItem(barButtonItem)
  # #   self.popoverViewController = pc
  # # end
  
  # # def splitViewController(svc, willShowViewController:avc, invalidatingBarButtonItem:barButtonItem) 
  # #   self.navigationItem.setLeftBarButtonItems([], animated:false)
  # #   self.popoverViewController = nil
  # # end

end