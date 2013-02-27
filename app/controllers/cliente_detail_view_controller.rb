class ClienteDetailViewController < UIViewController

  extend IB

  attr_accessor :cliente, :popoverViewController, :appunti_in_corso, :appunti_completati, :isDeletionModeActive

  outlet :nomeLabel
  outlet :indirizzoLabel
  outlet :cittaLabel
  outlet :nuovoAppuntoButton
  outlet :navigaButton
  outlet :emailButton
  outlet :callButton

  outlet :appuntiCollectionView
  outlet :classiCollectionView
  outlet :docentiCollectionView

  def viewDidLoad
    super

    self.nuovoAppuntoButton.text = "Nuovo Appunto"
    self.nuovoAppuntoButton.textColor = UIColor.whiteColor
    self.nuovoAppuntoButton.textShadowColor = UIColor.darkGrayColor
    self.nuovoAppuntoButton.tintColor = UIColor.colorWithRed(0.45, green:0, blue:0, alpha:1)
    self.nuovoAppuntoButton.highlightedTintColor = UIColor.colorWithRed(0.75, green:0, blue:0, alpha:1)

    self.navigaButton.text = "Naviga"
    self.emailButton.text  = "Email"
    self.callButton.text   = "Chiama"



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
      self.classiCollectionView.registerClass(ClienteAppuntoCell, forCellWithReuseIdentifier:"clienteAppuntoCell")
      self.classiCollectionView.collectionViewLayout = StacksLayout.alloc.init
      self.classiCollectionView.setShowsHorizontalScrollIndicator(false)
      self.classiCollectionView.setShowsVerticalScrollIndicator(false)

      pinch = UIPinchGestureRecognizer.alloc.initWithTarget(self, action:'handlePinch:')
      self.classiCollectionView.addGestureRecognizer(pinch)

      UISwipeGestureRecognizer.alloc.initWithTarget(self, action:'handleSwipeUp:').tap do |swipeUp|
        swipeUp.direction = UISwipeGestureRecognizerDirectionDown;
        self.appuntiCollectionView.addGestureRecognizer(swipeUp)
      end 

      # self.docentiCollectionView.registerClass(DocenteItem, forCellWithReuseIdentifier:"docenteItem")
      # self.docentiCollectionView.setShowsHorizontalScrollIndicator(false)
      # self.docentiCollectionView.setShowsVerticalScrollIndicator(false)
    end
  end

  def viewWillAppear(animated)
    super
    "reload_appunti_collections".add_observer(self, :reload)
    puts "observing reload_appunti_collections"

    display_cliente if @cliente
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
      self.classiCollectionView.reloadData
    end
    puts "Notificato"
  end


  def display_cliente

    self.nomeLabel.text = cliente.nome
    self.indirizzoLabel.text = cliente.indirizzo
    self.cittaLabel.text = "#{cliente.cap} #{cliente.citta} #{cliente.provincia}"

    if cliente.telefono.blank?
      self.callButton.enabled = false
      #callButton.alpha = 0.5
    end
    if cliente.email.blank?
      self.emailButton.enabled = false
      #emailButton.alpha = 0.5
    end
  
    if self.popoverViewController
      self.popoverViewController.dismissPopoverAnimated(true)
    end  
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
    end
    
    
    if segue.identifier.isEqualToString("nuovoAppunto")

      if Device.ipad?
        controller = segue.destinationViewController.visibleViewController
        controller.presentedAsModal = true
        #segue.destinationViewController.visibleViewController.sourceController = self
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

  def delete(sender)
    indexPath = self.appuntiCollectionView.indexPathForCell(sender.superview.superview)
    puts indexPath
    appunto = @appunti_in_corso.objectAtIndex(indexPath.row)
    appunto.remove
    self.appuntiCollectionView.deleteItemsAtIndexPaths([indexPath])
  
    # delete from backround
  end

  def changeToLayout(layout, animated:animated)
    reload_data = false
    delayed_reload = false
    new_layout = SpringboardLayout.alloc.init
                 # when LAYOUT_GRID
                 #   GridLayout.alloc.init
                 # when LAYOUT_LINE
                 #   delayed_reload = true
                 #   CoverFlowLayout.alloc.init
                 # when LAYOUT_COVERFLOW
                 #   delayed_reload = true
                 #   LineLayout.alloc.init
                 # when LAYOUT_STACKS
                 #   reload_data = true
                 #   StacksLayout.alloc.init
                 # when LAYOUT_SPIRAL
                 #   SpiralLayout.alloc.init
                 # end

    new_layout.invalidateLayout
    @layout_style = layout
    flag = (animated && !reload_data)

    self.classiCollectionView.setCollectionViewLayout(new_layout, animated:true)
    
    if reload_data
      self.classiCollectionView.reloadData
    elsif delayed_reload
      Dispatch::Queue.main.after(0.5) { self.collectionView.reloadData }
    end
    
  end 

  def handlePinch(gesture)
    #return nil unless @layout_style == LAYOUT_STACKS
    stacks_layout = self.classiCollectionView.collectionViewLayout
    
    if gesture.state == UIGestureRecognizerStateBegan
      initial_pinch_point = gesture.locationInView(self.classiCollectionView)
      pinched_cell_path   = self.classiCollectionView.indexPathForItemAtPoint(initial_pinch_point)
      stacks_layout.pinchedStackIndex = pinched_cell_path.section if pinched_cell_path
      
    elsif gesture.state == UIGestureRecognizerStateChanged
      stacks_layout.pinchedStackScale  = gesture.scale
      stacks_layout.pinchedStackCenter = gesture.locationInView(self.classiCollectionView)
      
    else
      if (stacks_layout.pinchedStackIndex >= 0)
        if stacks_layout.pinchedStackScale > 2.5
          self.changeToLayout("LAYOUT_SPRING", animated:true) # switch to GridLayout
        else
          # Find all the supplementary views
          #small_header_to_remove = self.collectionView.subviews.select { |subview| subview.is_a?(SmallConferenceHeader) } 
          stacks_layout.collapsing = true
          self.classiCollectionView.performBatchUpdates(-> {
            stacks_layout.pinchedStackIndex = -1
            stacks_layout.pinchedStackScale = 1.0
          }, completion:-> _ {
            stacks_layout.collapsing = false
            # remove them from the view hierarchy
            #small_header_to_remove.map(&:removeFromSuperview)
          })
        end
      end
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
      self.classiCollectionView.reloadData

      # if appunti.deleteAppuntoAtIndex(cell_path)        
      #   if appunti_count <= 1
      #     puts " reload"
      #     self.appuntiCollectionView.reloadData
      #   else
      #     puts "delete"
      #     self.appuntiCollectionView.deleteItemsAtIndexPaths([cell_path])
      #   end
      # end
      puts "Swipissimo"
    end
  end

  # def handleSwipeUp(gesture)
  #   #return unless self.layoutSupportsDelete
  #   start_point = gesture.locationInView(self.appuntiCollectionView)
  #   cell_path   = self.appuntiCollectionView.indexPathForItemAtPoint(start_point)
    
  #   if cell_path

  #     appunti = self.appuntiCollectionView.dataSource
  #     appunti_count = self.appuntiCollectionView.numberOfItemsInSection(cell_path.section)
  #     puts "SWIPEDOWN"

  #     # if appunti.deleteAppuntoAtIndex(cell_path)        
  #     #   if appunti_count <= 1
  #     #     puts " reload"
  #     #     #self.appuntiCollectionView.reloadData
  #     #   else
  #     #     puts "delete"
  #     #     #self.appuntiCollectionView.deleteItemsAtIndexPaths([cell_path])
  #     #   end
  #     # end
  #   end
  # end

  # def deleteAppuntoAtIndex(idx)
  #   return false if idx >= @appunti_in_corso.count
  #   @deletedSpeakers << @speakers.delete_at(idx)
  #   true
  # end


  # # collectionView delegates

  def collectionView(collectionView, numberOfItemsInSection:section)
    
    if collectionView == self.appuntiCollectionView
      if @cliente
        self.appunti_in_corso.count
      else
        0
      end
    elsif collectionView == self.classiCollectionView
      if @cliente
        self.appunti_completati.count
      else
        0
      end      
    # elsif collectionView == self.docentiCollectionView
    #   if @cliente && @cliente.docenti
    #     @cliente.docenti.count
    #   else
    #     0
    #   end      
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
    elsif collectionView == self.classiCollectionView
      if indexPath.section == 0
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("clienteAppuntoCell",
                                                                      forIndexPath:indexPath)
        cell.appunto =  @appunti_completati[indexPath.row]
      end   
    # elsif collectionView == self.docentiCollectionView
    #   if indexPath.section == 0
    #     cell = collectionView.dequeueReusableCellWithReuseIdentifier("docenteItem",
    #                                                                   forIndexPath:indexPath)
    #     cell.docente =  @cliente.docenti[indexPath.row]
    #   end   
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

      puts "TAPPED"

      self.performSegueWithIdentifier("nuovoAppunto", sender:appunto)
    elsif collectionView == self.classiCollectionView

      puts "TAPPED"

      appunto = @appunti_completati[indexPath.row]
      self.performSegueWithIdentifier("nuovoAppunto", sender:appunto)
    end
  end

  # SpringboardLayoutDelegate

  def isDeletionModeActiveForCollectionView(collectionView, layout:collectionViewLayout)
    if collectionView == self.appuntiCollectionView
      return isDeletionModeActive
    elsif collectionView == self.classiCollectionView
      return false
    end
  end


  # splitView delegates

  def splitViewController(svc, shouldHideViewController:vc, inOrientation:orientation)
    return false
  end




  def gestureRecognizer(gestureRecognizer, shouldReceiveTouch:touch)
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