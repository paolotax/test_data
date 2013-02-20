class ClienteDetailViewController < UIViewController

  extend IB

  attr_accessor :cliente, :popoverViewController, :sorted_appunti, :listController

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
      self.appuntiCollectionView.registerClass(ClienteAppuntoCell, forCellWithReuseIdentifier:"clienteAppuntoCell")
      self.appuntiCollectionView.registerClass(UICollectionReusableView, 
           forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, 
                  withReuseIdentifier: "headerDaFare")
      self.appuntiCollectionView.collectionViewLayout = LineLayout.alloc.init

      # self.classiCollectionView.registerClass(ClasseItem, forCellWithReuseIdentifier:"classeItem")
      # self.docentiCollectionView.registerClass(DocenteItem, forCellWithReuseIdentifier:"docenteItem")

      self.appuntiCollectionView.setShowsHorizontalScrollIndicator(false)
      self.appuntiCollectionView.setShowsVerticalScrollIndicator(false)

      # self.classiCollectionView.setShowsHorizontalScrollIndicator(false)
      # self.classiCollectionView.setShowsVerticalScrollIndicator(false)

      # self.docentiCollectionView.setShowsHorizontalScrollIndicator(false)
      # self.docentiCollectionView.setShowsVerticalScrollIndicator(false)
    end
  end


  def sorted_appunti
    @sorted_appunti = []
    orderAppunti = NSSortDescriptor.sortDescriptorWithKey("created_at", ascending:false)
    @sorted_appunti = @cliente.appunti.sortedArrayUsingDescriptors([orderAppunti])
    @sorted_appunti
  end

  def viewWillAppear(animated)
    super
    load_cliente if @cliente
  end

  def openCliente(cliente)
    Appunto.reset
    
    self.cliente = cliente
    self.title = cliente.nome

    puts "open #{self.cliente.appunti.count}"
    #self.tableView.reloadData
    #self.popoverViewController.dismissPopoverAnimated(true) unless self.popoverViewController == nil
  end

  def load_cliente

    puts "load #{self.cliente.appunti.count}"

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

  #  segues

  def prepareForSegue(segue, sender:sender)
    
    if segue.identifier.isEqualToString("showForm")
      segue.destinationViewController.remote_cliente_id = @cliente.remote_id
    end
    
    if segue.identifier.isEqualToString("nuovoAppunto")
      
      if Device.ipad?
        segue.destinationViewController.visibleViewController.presentedAsModal = true
        segue.destinationViewController.visibleViewController.sourceController = self
        puts sender.class
        if sender.class == Appunto_Appunto_
          segue.destinationViewController.visibleViewController.appunto = sender
        else
          appunto = Appunto.add do |a|
            a.cliente = @cliente
            a.ClienteId = @cliente.ClienteId
            a.cliente_nome = @cliente.nome
            a.status = "da_fare"
            a.created_at = Time.now
          end 
          segue.destinationViewController.visibleViewController.appunto = appunto
        end
        segue.destinationViewController.visibleViewController.cliente = @cliente
      else
        segue.destinationViewController.appunto = appunto
        segue.destinationViewController.cliente = @cliente
      end
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




  # # collectionView delegates

  def collectionView(collectionView, numberOfItemsInSection:section)
    
    if collectionView == self.appuntiCollectionView
      if @cliente
        self.sorted_appunti.count
      else
        0
      end
    # elsif collectionView == self.classiCollectionView
    #   if @cliente && @cliente.classi
    #     @cliente.classi.count
    #   else
    #     0
    #   end      
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
        cell.appunto =  @sorted_appunti[indexPath.row]
      end
    # elsif collectionView == self.classiCollectionView
    #   if indexPath.section == 0
    #     cell = collectionView.dequeueReusableCellWithReuseIdentifier("classeItem",
    #                                                                   forIndexPath:indexPath)
    #     cell.classe =  @cliente.classi[indexPath.row]
    #   end   
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
    if collectionView == self.appuntiCollectionView
      appunto = @sorted_appunti[indexPath.row]
      self.performSegueWithIdentifier("nuovoAppunto", sender:appunto)
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


end