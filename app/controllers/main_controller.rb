class MainController < UIViewController

  extend IB

  outlet :map, MKMapView
  outlet :mainToolbar

  attr_accessor :clienti

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

    @filterClienti = ["switch_da_fare", "switch_in_sospeso", "switch_nel_baule"]
    reload
  end

  def viewWillAppear(animated)
    super
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
    "pushClienteController".add_observer(self, "pushClienteTapped:", nil)
    "pushAppuntoController".add_observer(self, "pushAppuntoTapped:", nil)
    
  end

  def viewWillDisappear(animated)
    "reload_annotations".remove_observer(self, :reload)
    "annotation_did_change".remove_observer(self, "change_annotation:")
    "allow_dismiss_popover".remove_observer(self, "allow_dismiss")
    "unallow_dismiss_popover".remove_observer(self, "unallow_dismiss")
    "pushClienteController".remove_observer(self, "pushClienteTapped:")
    "pushAppuntoController".remove_observer(self, "pushAppuntoTapped:", nil)
  end

  def allow_dismiss
    @can_dismiss_popover = true
  end

  def unallow_dismiss
    @can_dismiss_popover = false
  end 

  def slidePopContainer
    self.parentViewController
  end

  def pushClienteTapped(notification)
    cliente = notification.userInfo[:cliente]
    @annotationPopover.dismissPopoverAnimated(false) if @annotationPopover
    clienteDetail = self.storyboard.instantiateViewControllerWithIdentifier("ClienteDetailController")
    clienteDetail.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    clienteDetail.cliente = cliente
    slidePopContainer.pushViewController(clienteDetail)
  end

  def pushAppuntoTapped(notification)
    appunto = notification.userInfo[:appunto]
    @annotationPopover.dismissPopoverAnimated(false) if @annotationPopover
    appuntoDetail = self.storyboard.instantiateViewControllerWithIdentifier("AppuntoFormController")
    appuntoDetail.presentedInDetailView = true
    appuntoDetail.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    appuntoDetail.appunto = appunto
    nav = UINavigationController.alloc.initWithRootViewController appuntoDetail
    nav.navigationBar.barStyle = UIBarStyleBlack
    slidePopContainer.pushViewController nav
  end

  
  def change_annotation(notification)
    annotation = notification.userInfo[:cliente]
    # devo mettere questo per ripetizione notifica
    unless @pippo
      annotation.nel_baule == 0 ? annotation.nel_baule = 1 : annotation.nel_baule = 0 
      annotation.update
      annotation.save_to_backend
      annotation.persist
      self.map.removeAnnotation(annotation)
      self.map.addAnnotation(annotation)
      @annotationPopover.dismissPopoverAnimated(true) if @annotationPopover
      "baule_did_change".post_notification
      @pippo = true
    end
  end

  def reload
    self.map.removeAnnotations(@clienti)
    self.clienti = fetch_clienti.select {|c| !c.latitude.nil? && !c.longitude.nil?}
    self.map.addAnnotations(@clienti)
  end



  def fetch_clienti

    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName("Cliente", inManagedObjectContext:context)

    pred = nil
    searchPredicates = [] 

    if @filterClienti.include?("switch_da_fare")
      searchPredicates.addObject(NSPredicate.predicateWithFormat("appunti_da_fare > 0"))
    end
    if @filterClienti.include?("switch_in_sospeso")
      searchPredicates.addObject(NSPredicate.predicateWithFormat("appunti_in_sospeso > 0"))
    end
    if @filterClienti.include?("switch_nel_baule")
      searchPredicates.addObject(NSPredicate.predicateWithFormat("nel_baule = 1"))
    end
    if @filterClienti.include?("switch_scuole_primarie")
      searchPredicates.addObject(NSPredicate.predicateWithFormat("cliente_tipo = 'Scuola Primaria' and fatto != 1"))
    end
    if @filterClienti.include?("switch_scuole_primarie_fatte")
      searchPredicates.addObject(NSPredicate.predicateWithFormat("cliente_tipo = 'Scuola Primaria' and fatto = 1"))
    end
    if @filterClienti.include?("switch_altri_clienti")
      searchPredicates.addObject(NSPredicate.predicateWithFormat("cliente_tipo != 'Scuola Primaria'"))
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



  # MapView dlegates

  def mapView(mapView, viewForAnnotation:annotation)

    return nil if annotation.is_a?(MKUserLocation) 
    
    view = mapView.dequeueReusableAnnotationViewWithIdentifier("spot")
    if (!view)
      view = MKAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:"spot")
      view.enabled = true
      view.canShowCallout = true
      view.centerOffset = CGPointMake(7, -15)
      view.calloutOffset = CGPointMake(-8, 0)
    end

    if annotation.nel_baule == 1
      view.image = "pin-purple".uiimage
    elsif annotation.appunti_da_fare && annotation.appunti_da_fare > 0
      view.image = "pin-red".uiimage
    elsif annotation.appunti_in_sospeso && annotation.appunti_in_sospeso > 0
      view.image = "pin-green".uiimage
    elsif annotation.cliente_tipo == "Scuola Primaria"
      
      if annotation.fatto == 1
        view.image = "pin-black".uiimage
      else
        view.image = "pin-orange".uiimage
      end
      
    else
      view.image = "pin-gray".uiimage
    end

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

  # map methods

  def selectItemInMap(item)
    
    unless @clienti.include? item
      self.map.addAnnotation(item)
    end

    r = self.map.visibleMapRect
    pt = MKMapPointForCoordinate(item.coordinate)
    r.origin.x = pt.x - r.size.width * 0.5
    r.origin.y = pt.y - r.size.height * 0.5
    self.map.setVisibleMapRect(r, animated:true)

    self.map.selectAnnotation(item, animated:true)
  end
  
  def coordinateRegionForItems(items, itemsCount)
    r = MKMapRectNull
    (0..itemsCount).each do |i|
      p = MKMapPointForCoordinate(items[i].coordinate)
      r = MKMapRectUnion(r, MKMapRectMake(p.x, p.y, 0.1, 0.1))
    end
    return MKCoordinateRegionForMapRect(r)
  end

  def showInMaps(sender)
    mapItems = []
    for cliente in clienti
      mapItems.addObject(cliente.mapItem) if cliente.nel_baule == 1
    end
    result = MKMapItem.openMapsWithItems(mapItems, launchOptions:nil)
  end

  def setPins(sender)
    unless @setPinPopover
      storyboard = UIStoryboard.storyboardWithName("MainStoryboard_iPad", bundle:nil)
      pvc = storyboard.instantiateViewControllerWithIdentifier("SetPinController")
      pvc.delegate = self
      pvc.selectedPins = @filterClienti
      nav = UINavigationController.alloc.initWithRootViewController(pvc)
      popover = UIPopoverController.alloc.initWithContentViewController(nav)
      popover.delegate = self
      @setPinPopover = popover
      @setPinPopover.presentPopoverFromBarButtonItem(sender, permittedArrowDirections:UIPopoverArrowDirectionAny, animated:true)
    end
  end


  # setPinController delegate

  def smartBaule
    visibleMapRect = map.visibleMapRect
    visibleAnnotations = map.annotationsInMapRect(visibleMapRect)
    if visibleAnnotations
      visibleAnnotations.allObjects.each do |c|
        c.nel_baule = 1
        c.update
        c.save_to_backend
      end 
      Store.shared.persist
    end
    reload
    "baule_did_change".post_notification
  end

  def resetBaule
    @clienti.each do |c|
      if c.nel_baule == 1
        c.nel_baule = 0
        c.update
        c.save_to_backend
      end
    end 
    Store.shared.persist
    reload
    "baule_did_change".post_notification
  end

  def setPinController(controller, didChangedPin:selectedPins)
    @filterClienti = selectedPins
    reload
  end


  # searchBar SearchClienti delegates and methods

  def searchClientiController(controller, didSelectCliente:cliente)
    @searchBar.text = cliente.nome
    self.finishSearchWithString(cliente)
    self.selectItemInMap(cliente)
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

  def willRotateToInterfaceOrientation(toInterfaceOrientation, duration:duration)
    if @searchPopover
      @searchPopover.dismissPopoverAnimated(false)
    end
    if @annotationPopover
      @annotationPopover.dismissPopoverAnimated(false)
    end
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

  # popoverController delegates

  def popoverControllerShouldDismissPopover(popoverController)
    @can_dismiss_popover
  end

  def popoverControllerDidDismissPopover(popoverController)
    if @setPinPopover
      @setPinPopover.delegate = nil
      @setPinPopover = nil
    end
    if @annotationPopover
      @annotationPopover.delegate = nil
      @annotationPopover = nil
    end
    @searchBar.resignFirstResponder
  end





end