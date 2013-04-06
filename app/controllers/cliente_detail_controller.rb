class ClienteDetailController < UIViewController


  KMinScale = 1.0
  KMaxScale = 3.0

  extend IB

  attr_accessor :cliente, 
      :popoverViewController,
      :appuntiCollectionController

  outlet :mainToolbar

  outlet :nuovoAppuntoButton
  outlet :navigaButton
  outlet :emailButton
  outlet :callButton

  outlet :editMultipleButton


  outlet :segmentedControl

  outlet :collectionViewContainer

  def slidePopContainer
    self.parentViewController
  end

  def viewDidLoad
    super

    @clienteTitleView = ClienteTitleView.alloc.initWithFrame [[10, 49], [400,150]]
    @clienteTitleView.backgroundColor = UIColor.clearColor
    self.view.addSubview @clienteTitleView   

    mapItem = UIBarButtonItem.imaged("103-map".uiimage) {
      slidePopContainer.popViewController(self)
    }

    mapItem = UIBarButtonItem.imaged("103-map".uiimage) {
      slidePopContainer.popViewController(self)
    }
    
    spaceItem =  UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)
 
    @searchBar = UISearchBar.alloc.initWithFrame([[0, 0], [250, 0]])
    @searchBar.delegate = self
    searchItem = UIBarButtonItem.alloc.initWithCustomView(@searchBar)
 
    self.mainToolbar.items = [mapItem, spaceItem, searchItem]
    
    @searchController = SearchClientiController.alloc.initWithStyle(UITableViewStylePlain)
    @searchController.delegate = self

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

  def display_cliente

    @clienteTitleView.cliente = @cliente
    
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
    
    self.editMultipleButton.enabled = false

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
        controller.appunto = appunto
      else
        controller.isNew = true
      end
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


  # searchBar SearchClienti delegates and methods

  def searchClientiController(controller, didSelectCliente:cliente)
    @searchBar.text = cliente.nome
    self.finishSearchWithString(cliente)
    "pushClienteController".post_notification(self, cliente: cliente)
  end

  def searchBarTextDidBeginEditing(searchBar)
    
    if @searchPopover == nil
    
      nav = UINavigationController.alloc.initWithRootViewController(@searchController)
      popover = UIPopoverController.alloc.initWithContentViewController(nav)
      @searchPopover = popover
      @searchPopover.delegate = self

      popover.passthroughViews = [@searchBar]
      
      @searchPopover.presentPopoverFromRect(@searchBar.bounds,
                                                         inView:@searchBar,
                                       permittedArrowDirections:UIPopoverArrowDirectionAny,
                                                       animated:true)
    end
  end                                                    

  def searchBarTextDidEndEditing(searchBar)

    if @searchPopover != nil
      nav = @searchPopover.contentViewController
      searchesController = nav.topViewController
      #if (searchesController.confirmSheet == nil)
        @searchPopover.dismissPopoverAnimated(true)
        @searchPopover = nil
      #end
    end
    searchBar.resignFirstResponder
  end

  def searchBar(searchBar, textDidChange:searchText)
    @searchController.filter(searchText)
  end

  def searchBarSearchButtonClicked(searchBar)
    searchString = searchBar.text
    # searchController addToRecentSearches:searchString];
    self.finishSearchWithString(searchString)
  end

  def finishSearchWithString(searchString)
    @searchPopover.dismissPopoverAnimated(true)
    @searchPopover = nil
    @searchBar.resignFirstResponder
  end


  # popover delegates and rotation

  def popoverControllerDidDismissPopover(popoverController)
    @popoverController.delegate = nil
    @popoverController = nil
    @searchBar.resignFirstResponder
  end 

  def willRotateToInterfaceOrientation(toInterfaceOrientation, duration:duration)
    if @searchPopover
      @searchPopover.dismissPopoverAnimated(false)
    end
  end
    
  def didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    if @searchPopover
      @searchPopover.presentPopoverFromRect(@searchBar.bounds, inView:@searchBar,
                                             permittedArrowDirections:UIPopoverArrowDirectionAny,
                                                             animated:false)
    end
  end

end