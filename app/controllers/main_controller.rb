class MainController < UIViewController

  extend IB

  outlet :map, MKMapView
  outlet :navigationBar
  outlet :mainToolbar

  attr_accessor :popoverViewController, :clienti

  def viewDidLoad
    super
    
    trackItem = MKUserTrackingBarButtonItem.alloc.initWithMapView(self.map)

    spaceItem =  UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)
 
    @searchBar = UISearchBar.alloc.initWithFrame([[0, 0], [250, 0]])
    @searchBar.delegate = self
    searchItem = UIBarButtonItem.alloc.initWithCustomView(@searchBar)
 
    self.mainToolbar.items = [trackItem, spaceItem, searchItem]
    
    @searchController = SearchClientiController.alloc.initWithStyle(UITableViewStylePlain)
    @searchController.delegate = self

    reload
  end



  def searchClientiController(controller, didSelectCliente:cliente)
    @searchBar.text = cliente.nome
    self.finishSearchWithString(cliente)

    self.map.addAnnotation(cliente)



    r = self.map.visibleMapRect
    r.center = cliente.coordinate
    r.span.latitudeDelta = 0.5
    r.span.longitudeDelta = 0.5
    region = self.map.regionThatFits(r)
    self.map.setRegion(region, animated:true) 

    self.map.selectAnnotation(cliente, animated:true)

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

  def popoverControllerDidDismissPopover(popoverController)
    @searchBar.resignFirstResponder
  end

  

  def willRotateToInterfaceOrientation(toInterfaceOrientation, duration:duration)
    if @searchPopover
      @searchPopover.dismissPopoverAnimated(false)
    end
    # if @annotationPopover
    #   @annotationPopover.dismissPopoverAnimated(false)
    # end
  end
    
  def didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    if @searchPopover
      @searchPopover.presentPopoverFromRect(@searchBar.bounds, inView:@searchBar,
                                             permittedArrowDirections:UIPopoverArrowDirectionAny,
                                                             animated:false)
    end
    if @annotationPopover
      @annotationPopover.presentPopoverFromRect(@selectedAnnotation.bounds, inView:@selectedAnnotation, permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight, animated:true)
    end
  end
























  def viewWillAppear(animated)
    super
    
    if self.popoverViewController
      self.popoverViewController.dismissPopoverAnimated(true)
    end

    @can_dismiss_popover = true

    if clienti.count > 0
      region = self.coordinateRegionForItems(clienti, clienti.count-1)
      self.map.setRegion(region)
    end

    # codice per ricordarmi pointer polyline
    if clienti.count > 3
      clienti_group = [clienti[1].coordinate, clienti[2].coordinate, clienti[3].coordinate]
      ptr = clienti_group.to_pointer(CLLocationCoordinate2D.type)
    end

    "reload_annotations".add_observer(self, :reload)
    "annotation_did_change".add_observer(self, "change_annotation:", nil)
    "allow_dismiss_popover".add_observer(self, "allow_dismiss")
    "unallow_dismiss_popover".add_observer(self, "unallow_dismiss")
    "replace_cliente".add_observer(self, "replaceCliente:", nil)
  end

  def viewWillDisappear(animated)
    "reload_annotations".remove_observer(self, :reload)
    "annotation_did_change".remove_observer(self, "change_annotation:")
    "allow_dismiss_popover".remove_observer(self, "allow_dismiss")
    "unallow_dismiss_popover".remove_observer(self, "unallow_dismiss")
    "replace_cliente".remove_observer(self, "replaceCliente:")
  end

  def allow_dismiss
    @can_dismiss_popover = true
  end

  def unallow_dismiss
    @can_dismiss_popover = false
  end 

  def replaceCliente(notification)

    unless @pippo
      annotation = notification.userInfo[:cliente]
      @annotationPopover.dismissPopoverAnimated(true) if @annotationPopover
      self.performSegueWithIdentifier("replaceCliente", sender:annotation)
      @pippo = true
    end
  end
  
  def change_annotation(notification)

    annotation = notification.userInfo[:cliente]

    # devo mettere questo per ripetizione notifica
    unless @pippo
      annotation.nel_baule == 0 ? annotation.nel_baule = 1 : annotation.nel_baule = 0 
      annotation.update
      Store.shared.persist
      self.map.removeAnnotation(annotation)
      self.map.addAnnotation(annotation)
      @annotationPopover.dismissPopoverAnimated(true) if @annotationPopover
      @pippo = true
    end
  end

  def reload
    self.map.removeAnnotations(@clienti)
    self.clienti = fetch_clienti_in_corso.select {|c| !c.latitude.nil? && !c.longitude.nil?}
    self.map.addAnnotations(@clienti)
  end

  def coordinateRegionForItems(items, itemsCount)
    r = MKMapRectNull
    (0..itemsCount).each do |i|
      p = MKMapPointForCoordinate(items[i].coordinate)
      r = MKMapRectUnion(r, MKMapRectMake(p.x - 10, p.y - 10, 20, 20))
    end
    return MKCoordinateRegionForMapRect(r)
  end

  def fetch_clienti_in_corso
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName("Cliente", inManagedObjectContext:context)
    pred = nil

    searchPredicates = [] 
    ["appunti_da_fare", "appunti_in_sospeso"].each do |sk|
      searchPredicates.addObject(NSPredicate.predicateWithFormat("#{sk} > 0"))
    end

    pred = NSCompoundPredicate.orPredicateWithSubpredicates(searchPredicates)
    request.predicate = pred

    request.sortDescriptors = ["provincia", "comune", "nome"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }
    
    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end

    data
  end

  def showInMaps(sender)
    mapItems = []
    for cliente in clienti
      mapItems.addObject(cliente.mapItem) if cliente.nel_baule == 1
    end
    result = MKMapItem.openMapsWithItems(mapItems, launchOptions:nil)
  end

  def resetPins(sender)
    @clienti.each do |c|
      if c.nel_baule == 1
        c.nel_baule = 0
        c.update
      end
    end 
    Store.shared.persist
    reload
  end



  # MapView dlegates

  def mapView(mapView, viewForAnnotation:annotation)

    return nil if annotation.is_a?(MKUserLocation) 
      
    #kPinIdentifier = "TAXCliente"
    #view = mapView.dequeueReusableAnnotationViewWithIdentifier(kPinIdentifier)
    #unless view
      view = MKPinAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:nil)
      if annotation.nel_baule == 1
        view.pinColor = MKPinAnnotationColorPurple
      elsif annotation.appunti_da_fare && annotation.appunti_da_fare > 0
        view.pinColor = MKPinAnnotationColorRed
      else
        view.pinColor = MKPinAnnotationColorGreen
      end

      view.canShowCallout = true
      view.calloutOffset = CGPointMake(-5, 5);
      view.animatesDrop = false
    #end

    if annotation.nel_baule == 1
      btnImage = "07-map-marker-purple".uiimage
    else
      btnImage = "07-map-marker".uiimage
    end
    leftBtn = UIButton.alloc.initWithFrame(CGRectMake(0, 1, 26, 26))
    leftBtn.setBackgroundImage(btnImage, forState:UIControlStateNormal)

    view.rightCalloutAccessoryView = UIButton.info
    view.leftCalloutAccessoryView = leftBtn
    view

  end


  def mapView(mapView, annotationView:view, calloutAccessoryControlTapped:control)

    @pippo = nil
    @selectedAnnotation = view
    
    @selectedCliente = view.annotation
    mapView.deselectAnnotation(view.annotation, animated:true)

    if control.buttonType == UIButtonTypeInfoLight

      storyboard = UIStoryboard.storyboardWithName("MainStoryboard_iPad", bundle:nil)
      pvc = storyboard.instantiateViewControllerWithIdentifier("PopoverClienteController")
      pvc.cliente = @selectedCliente

      nav = UINavigationController.alloc.initWithRootViewController(pvc)
      popover = UIPopoverController.alloc.initWithContentViewController(nav)
      popover.delegate = self

      @annotationPopover = popover
      @annotationPopover.presentPopoverFromRect(view.bounds, inView:view, permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight, animated:true)
    
    else
      "annotation_did_change".post_notification(self, cliente: @selectedCliente)
    end

  end


  # splitView delegates

  # def splitViewController(svc, shouldHideViewController:vc, inOrientation:orientation)
  #   return false
  # end

  def splitViewController(svc, willHideViewController:vc, withBarButtonItem:barButtonItem, forPopoverController:pc)
    barButtonItem.title = "Menu"
    self.navigationItem.setLeftBarButtonItem(barButtonItem)
    self.popoverViewController = pc
  end
  
  def splitViewController(svc, willShowViewController:avc, invalidatingBarButtonItem:barButtonItem) 
    self.navigationItem.setLeftBarButtonItems([], animated:false)
    self.popoverViewController = nil
  end

  # popoverController delegates

  def popoverControllerShouldDismissPopover(popoverController)
    @can_dismiss_popover
  end



  def prepareForSegue(segue, sender:sender)
    
    if segue.identifier.isEqualToString("replaceCliente")
      segue.destinationViewController.visibleViewController.cliente = sender
    end
  end


end