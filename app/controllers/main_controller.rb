class MainController < UIViewController

  extend IB

  outlet :map, MKMapView
  outlet :navigationBar

  attr_accessor :popoverViewController, :clienti, :annotationPopover

  def viewDidLoad
    super
    self.navigationBar.leftBarButtonItem = MKUserTrackingBarButtonItem.alloc.initWithMapView(self.map)
    @clienti = fetch_clienti_in_corso.select {|c| !c.latitude.nil? && !c.longitude.nil?}
    self.map.addAnnotations(@clienti)
  end

  def viewWillAppear(animated)
    super    
    if clienti.count > 0
      region = self.coordinateRegionForItems(clienti, clienti.count-1)
      self.map.setRegion(region)
    end

    # codice per ricordarmi pointer polyline
    if clienti.count > 3
      clienti_group = [clienti[1].coordinate, clienti[2].coordinate, clienti[3].coordinate]
      ptr = clienti_group.to_pointer(CLLocationCoordinate2D.type)
    end

    "reload_annotations".add_observer(self, "reload:", nil)
  end

  def viewWillDisppear(animated)
    super    
    "reload_annotations".remove_observer(self, :reload, nil)
  end 

  def reload(notification)
    annotation = notification.userInfo[:cliente]
    annotation.nel_baule == 0 ? annotation.nel_baule = 1 : annotation.nel_baule = 0 
    annotation.update
    Store.shared.persist
    self.map.removeAnnotation(annotation)
    self.map.addAnnotation(annotation)
    self.annotationPopover.dismissPopoverAnimated(true) if annotationPopover
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
    self.map.removeAnnotations(@clienti)
    self.map.addAnnotations(@clienti)
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

    selectedCliente = view.annotation
    mapView.deselectAnnotation(view.annotation, animated:true)

    if control.buttonType == UIButtonTypeInfoLight

      storyboard = UIStoryboard.storyboardWithName("MainStoryboard_iPad", bundle:nil)
      pvc = storyboard.instantiateViewControllerWithIdentifier("PopoverClienteController")
      pvc.cliente = selectedCliente
      pvc.navigationItem.title = "#{selectedCliente.nome}"

      nav = UINavigationController.alloc.initWithRootViewController(pvc)
      popover = UIPopoverController.alloc.initWithContentViewController(nav)
      popover.delegate = self
      
      self.annotationPopover = popover
      self.annotationPopover.presentPopoverFromRect(view.bounds, inView:view, permittedArrowDirections:UIPopoverArrowDirectionAny, animated:true)
    
    else
      "reload_annotations".post_notification(self, cliente: selectedCliente)
    end

    # mapItem = selectedCliente.mapItem
    # launchOptions = { MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving }
    # mapItem.openInMapsWithLaunchOptions(launchOptions)
  end


  # splitView delegates

  def splitViewController(svc, shouldHideViewController:vc, inOrientation:orientation)
    return false
  end

  # def splitViewController(svc, willHideViewController:vc, withBarButtonItem:barButtonItem, forPopoverController:pc)
  #   barButtonItem.title = "Menu"
  #   self.navigationItem.setLeftBarButtonItem(barButtonItem)
  #   self.popoverViewController = pc
  # end
  
  # def splitViewController(svc, willShowViewController:avc, invalidatingBarButtonItem:barButtonItem) 
  #   self.navigationItem.setLeftBarButtonItems([], animated:false)
  #   self.popoverViewController = nil
  # end

end