class ClienteController < UITableViewController
  attr_accessor :cliente, :popoverViewController

  def viewDidLoad
    view.dataSource = view.delegate = self
  end

  def viewWillAppear(animated)
    #self.title = "Cliente"
    
    navigationItem.rightBarButtonItem = UIBarButtonItemAdd.withTarget(self, action:'addAppunto')

    @appuntoController ||= UITableViewControllerForNSManagedObject.alloc.initWithStyle(UITableViewStyleGrouped)
    @navAppuntoController ||= UINavigationControllerDoneCancel.withRootViewController(@appuntoController, target:self, done:'doneEditing', cancel:'cancelEditing')
    
    Appunto.reset
    view.reloadData
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown
  end
  
  def splitViewController(svc, willHideViewController:vc, withBarButtonItem:barButtonItem, forPopoverController:pc)
    barButtonItem.title = 'Appunti'
    self.navigationItem.setLeftBarButtonItem(barButtonItem)
    self.popoverViewController = pc
  end
  
  def splitViewController(svc, willShowViewController:avc, invalidatingBarButtonItem:barButtonItem) 
    self.navigationItem.setLeftBarButtonItems([], animated:false)
    self.popoverViewController = nil
  end
  
  def openCliente(cliente)
    Appunto.reset
    
    self.cliente = cliente
    self.title = cliente.nome
    self.tableView.reloadData
    self.popoverViewController.dismissPopoverAnimated(true) unless self.popoverViewController == nil
  end

  def addAppunto
    Appunto.add do |appunto|
      appunto.destinatario = "John#{rand(100)}"
      appunto.cliente = cliente
      @appuntoController.object = appunto
      @appuntoController.is_update = false
    end
    navigationController.presentModalViewController(@navAppuntoController, animated:true)
  end
  
  def editAppunto(appunto)
    @appuntoController.object = appunto
    @appuntoController.is_update = true
    navigationController.presentModalViewController(@navAppuntoController, animated:true)
  end
  
  def deleteEditing
    # Remove the player, the user selected 'Remove this player'
    @appuntoController.object.remove
    @appuntoController.dismissModalViewControllerAnimated(true)
    view.reloadData
  end
    
  def cancelEditing
    # Remove the appunto, the user selected 'Cancel'
    @appuntoController.object.remove unless @appuntoController.is_update
    @appuntoController.dismissModalViewControllerAnimated(true)
    view.reloadData
  end
  
  def doneEditing
    # Save the appunto, the user selected 'Done'
    @appuntoController.updateObject
    @appuntoController.object.update
    @appuntoController.dismissModalViewControllerAnimated(true)
    view.reloadData
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    return 0 if cliente == nil
    
    cliente.appunti.count
  end

  CellID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CellID) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CellID).tap do |c|
      c.accessoryType = UITableViewCellAccessoryNone
    end

    cell.textLabel.text = "#{cliente.appunti.objectAtIndex(indexPath.row).destinatario}"
    cell.detailTextLabel.text = "#{cliente.appunti.objectAtIndex(indexPath.row).note}"
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    editAppunto(cliente.appunti.objectAtIndex(indexPath.row))
  end
end