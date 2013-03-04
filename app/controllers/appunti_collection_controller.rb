class AppuntiCollectionController < UIViewController


  KMinScale = 1.0
  KMaxScale = 3.0

  extend IB

  attr_accessor :cliente, 
                :appunti_in_corso, 
                :appunti_completati, 
                :isDeletionModeActive,
                :currentPinchCollectionView,
                :currentPinchedItem





  outlet :appuntiCollectionView
  outlet :completatiCollectionView

  outlet :collectionViewContainer

  def viewDidLoad
    super
    if Device.ipad?

      self.isDeletionModeActive = false

      # appuntiCollectionView
      self.appuntiCollectionView.registerClass(ClienteAppuntoCell, forCellWithReuseIdentifier:"clienteAppuntoCell")
      self.appuntiCollectionView.registerClass(UICollectionReusableView, 
           forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, 
                  withReuseIdentifier: "headerDaFare")
      self.appuntiCollectionView.collectionViewLayout = SpringboardLayout.alloc.init

      self.appuntiCollectionView.setShowsHorizontalScrollIndicator(false)
      self.appuntiCollectionView.setShowsVerticalScrollIndicator(false)

      longPress = UILongPressGestureRecognizer.alloc.initWithTarget(self, action:"activateDeletionMode:")
      longPress.delegate = self
      self.appuntiCollectionView.addGestureRecognizer(longPress)
      touch = UITapGestureRecognizer.alloc.initWithTarget(self, action:"endDeletionMode:")
      touch.delegate = self
      self.view.addGestureRecognizer(touch)

      # classiView CON STACK Appunti
      self.completatiCollectionView.registerClass(ClienteAppuntoCell, forCellWithReuseIdentifier:"clienteAppuntoCell")
      self.completatiCollectionView.collectionViewLayout = StacksLayout.alloc.init
      
      self.completatiCollectionView.setShowsHorizontalScrollIndicator(false)
      self.completatiCollectionView.setShowsVerticalScrollIndicator(false)

      pinch = UIPinchGestureRecognizer.alloc.initWithTarget(self, action:'handlePinchOut:')
      self.completatiCollectionView.addGestureRecognizer(pinch)

      UISwipeGestureRecognizer.alloc.initWithTarget(self, action:'handleSwipeUp:').tap do |swipeUp|
        swipeUp.direction = UISwipeGestureRecognizerDirectionDown;
        self.appuntiCollectionView.addGestureRecognizer(swipeUp)
      end 

    end
  end

  def viewWillAppear(animated)
    super
    "reload_appunti_collections".add_observer(self, :reload)
    puts "observing reload_appunti_collections"
    reload
  end

  def viewWillDisappear(animated)
    super
    "reload_appunti_collections".remove_observer(self, :reload)
    puts "blind reload_appunti_collections"
  end
 
  def reload
    Cliente.reset
    Appunto.reset
    if Device.ipad?
      self.appuntiCollectionView.reloadData
      self.completatiCollectionView.reloadData
    end
    puts "Notificato"
  end

  def appunti_in_corso
    @appunti_in_corso = []
    @appunti_in_corso = sorted_appunti.select { |a| a.status != "completato" }
    @appunti_in_corso
  end

  def appunti_completati
    @appunti_completati = [] 
    @appunti_completati = sorted_appunti.select { |a| a.status == "completato" }
    @appunti_completati
  end

  def sorted_appunti
    @sorted_appunti = []
    orderAppunti = NSSortDescriptor.sortDescriptorWithKey("created_at", ascending:false)
    @sorted_appunti = @cliente.appunti.sortedArrayUsingDescriptors([orderAppunti])
    @sorted_appunti
  end


  #  segues

  def prepareForSegue(segue, sender:sender)

    puts segue.identifier

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
    end

    
    # if segue.identifier.isEqualToString("modalAppunto")
    #   if Device.ipad?
    #     controller = segue.destinationViewController.visibleViewController
    #     controller.presentedAsModal = true
    #   else
    #     controller = segue.destinationViewController
    #   end  
    #   if Device.ipad? && sender.class == Appunto_Appunto_
    #     appunto = sender
    #   end
    #   controller.appunto = appunto
    #   controller.cliente = @cliente
    # end
  end


  # actions

  def delete(sender)

    puts sender
    sender.superview.superview
    
    indexPath = self.appuntiCollectionView.indexPathForCell(sender.superview.superview)
    puts indexPath
    appunto = @appunti_in_corso.objectAtIndex(indexPath.row)
    appunto.remove
    self.appuntiCollectionView.deleteItemsAtIndexPaths([indexPath])
  
    # delete from backround
  end

  def handlePinchOut(recognizer)

    if recognizer.state == UIGestureRecognizerStateBegan
      pinchPoint = recognizer.locationInView(self.completatiCollectionView)
      pinchedItem = self.completatiCollectionView.indexPathForItemAtPoint(pinchPoint)
      
      if (pinchedItem)
        self.currentPinchedItem = pinchedItem;

        layout = PinchLayout.alloc.init
        layout.itemSize = CGSizeMake(230, 230)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        #layout.headerReferenceSize = CGSizeMake(0.0f, 90.0f);
        layout.pinchedStackScale = 0
        
        self.currentPinchCollectionView = UICollectionView.alloc.initWithFrame(self.completatiCollectionView.frame, collectionViewLayout:layout)
        self.currentPinchCollectionView.backgroundColor = UIColor.clearColor
        self.currentPinchCollectionView.delegate = self
        self.currentPinchCollectionView.dataSource = self
        self.currentPinchCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
        self.currentPinchCollectionView.setShowsHorizontalScrollIndicator(false)
        self.currentPinchCollectionView.setShowsVerticalScrollIndicator(false)
        self.currentPinchCollectionView.registerClass(ClienteAppuntoCell, forCellWithReuseIdentifier:"clienteAppuntoCell") 
        self.collectionViewContainer.addSubview(self.currentPinchCollectionView)

        recognizer = UIPinchGestureRecognizer.alloc.initWithTarget(self, action:"handlePinchInGesture:")
        @currentPinchCollectionView.addGestureRecognizer(recognizer)
      end
    
    elsif (recognizer.state == UIGestureRecognizerStateChanged) && (self.currentPinchedItem) 

      theScale = recognizer.scale
      theScale = [theScale, KMaxScale].min
      theScale = [theScale, KMinScale].max
          
      theScalePct = (theScale - KMinScale) / (KMaxScale - KMinScale);
          
      layout = @currentPinchCollectionView.collectionViewLayout
      layout.pinchedStackScale = theScalePct
      layout.pinchedStackCenter = recognizer.locationInView(self.completatiCollectionView)

      self.completatiCollectionView.alpha = 1.0 - theScalePct
    
    elsif (self.currentPinchedItem)

      layout = @currentPinchCollectionView.collectionViewLayout
      layout.pinchedStackScale = 1.0
      self.completatiCollectionView.alpha = 0.0
    end
    
  end


  def handlePinchInGesture(recognizer)
    if (recognizer.state == UIGestureRecognizerStateBegan)
      self.completatiCollectionView.alpha = 0

    elsif (recognizer.state == UIGestureRecognizerStateChanged) 
      theScale = 1.0 / recognizer.scale
        
      theScale = [theScale, KMaxScale].min
      theScale = [theScale, KMinScale].max

      theScalePct = 1.0 - ((theScale - KMinScale) / (KMaxScale - KMinScale))
      
      layout = self.currentPinchCollectionView.collectionViewLayout
      layout.pinchedStackScale = theScalePct
      layout.pinchedStackCenter = recognizer.locationInView(self.completatiCollectionView)

      #self.completatiCollectionView.alpha = 1.0 - theScalePct
    else
      self.completatiCollectionView.alpha = 1.0
        
      self.currentPinchCollectionView.removeFromSuperview
      self.currentPinchCollectionView = nil
      self.currentPinchedItem = nil
    end
  end


  def handleSwipeUp(gesture)
    #return unless self.layoutSupportsDelete
    start_point = gesture.locationInView(self.appuntiCollectionView)
    cell_path   = self.appuntiCollectionView.indexPathForItemAtPoint(start_point)
    
    if cell_path
      appunto = self.appuntiCollectionView.cellForItemAtIndexPath(cell_path).appunto
      appunti = self.appuntiCollectionView.dataSource
      appunti_count = self.appuntiCollectionView.numberOfItemsInSection(cell_path.section)
      
      appunto.status = "completato"
      appunto.save_to_backend
      appunto.updated_at = Time.now
      appunto.update
      self.appuntiCollectionView.deleteItemsAtIndexPaths([cell_path])
      self.completatiCollectionView.reloadData
      # if appunti.deleteAppuntoAtIndex(cell_path)        
      #   if appunti_count <= 1
      #     puts " reload"
      #     self.appuntiCollectionView.reloadData
      #   else
      #     puts "delete"
      #     self.appuntiCollectionView.deleteItemsAtIndexPaths([cell_path])
      #   end
      # end
    end
  end



  # # collectionView delegates

  def collectionView(collectionView, numberOfItemsInSection:section)
    
    if collectionView == self.appuntiCollectionView
      if @cliente
        self.appunti_in_corso.count
      else
        0
      end
    elsif collectionView == self.completatiCollectionView || collectionView == self.currentPinchCollectionView
      if @cliente
        self.appunti_completati.count
      else
        0
      end      
    else
      0
    end
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    
    if collectionView == self.appuntiCollectionView
      if indexPath.section == 0
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("clienteAppuntoCell",
                                                                         forIndexPath:indexPath)
        cell.appunto =  @appunti_in_corso[indexPath.row]
        cell.deleteButton.addTarget(self, action:"delete:", forControlEvents:UIControlEventTouchUpInside)
      end
    elsif collectionView == self.completatiCollectionView || collectionView == self.currentPinchCollectionView
      if indexPath.section == 0
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("clienteAppuntoCell",
                                                                      forIndexPath:indexPath)
        cell.appunto =  @appunti_completati[indexPath.row]
      end   
    end

    cell
  end

  def collectionView(collectionView, viewForSupplementaryElementOfKind:kind, atIndexPath:indexPath)
    if collectionView == self.appuntiCollectionView
      if kind == UICollectionElementKindSectionHeader
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, 
                                                        withReuseIdentifier:"headerDaFare", 
                                                               forIndexPath:indexPath)
      end
    end
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    if collectionView == self.appuntiCollectionView && !isDeletionModeActive
      appunto = @appunti_in_corso[indexPath.row]
    elsif collectionView == self.completatiCollectionView || collectionView == self.currentPinchCollectionView
      appunto = @appunti_completati[indexPath.row]
    end
    self.performSegueWithIdentifier("nuovoAppunto", sender:appunto)
  end

  # Custom LayoutDelegate

  def isDeletionModeActiveForCollectionView(collectionView, layout:collectionViewLayout)
    if collectionView == self.appuntiCollectionView
      return isDeletionModeActive
    elsif collectionView == self.completatiCollectionView || collectionView == self.currentPinchCollectionView
      return false
    end
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

  def gestureRecognizer(gestureRecognizer, shouldReceiveTouch:touch)
    puts "toccato"
    touchPoint = touch.locationInView(self.appuntiCollectionView)
    indexPath = self.appuntiCollectionView.indexPathForItemAtPoint(touchPoint)
    if (indexPath && gestureRecognizer.isKindOfClass(UITapGestureRecognizer))
      return false
    end 
    return true
  end

  def activateDeletionMode(gr)
    if (gr.state == UIGestureRecognizerStateBegan)
      indexPath = self.appuntiCollectionView.indexPathForItemAtPoint(gr.locationInView(self.appuntiCollectionView))
      if (indexPath)
        self.isDeletionModeActive = true
        layout = self.appuntiCollectionView.collectionViewLayout
        layout.invalidateLayout
      end
    end
  end

  def endDeletionMode(gr)
    if (isDeletionModeActive)
      indexPath = self.appuntiCollectionView.indexPathForItemAtPoint(gr.locationInView(self.appuntiCollectionView))
      unless indexPath
        self.isDeletionModeActive = false
        layout = self.appuntiCollectionView.collectionViewLayout
        layout.invalidateLayout
      end
    end
  end


end