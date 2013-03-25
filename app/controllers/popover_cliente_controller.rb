class PopoverClienteController < UITableViewController

  extend IB

  attr_accessor :delegate, :cliente, :appunti_in_corso

  def viewDidLoad
    super
    self.contentSizeForViewInPopover = CGSizeMake(320, 0)
    self.appunti_in_corso = []
    self.tableView.registerClass(AppuntoCell, forCellReuseIdentifier:"appuntoCell")
  end

  def viewWillAppear(animated)
    super
    
    self.tableView.reloadData

    self.navigationItem.leftBarButtonItem = UIBarButtonItem.imaged('38-house'.uiimage) {
     "pushClienteController".post_notification(self, cliente: @cliente)
    }
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.add {
      self.performSegueWithIdentifier("addAppunto", sender:self)
    }
  
    if appunti_in_corso.count == 0
      self.navigationItem.title = cliente.nome
    elsif appunti_in_corso.count == 1 
      self.navigationItem.title = "#{appunti_in_corso.count} appunto"
    else
      self.navigationItem.title = "#{appunti_in_corso.count} appunti"
    end
  end
  
  def viewDidAppear(animated)
    self.contentSizeForViewInPopover = self.tableView.contentSize
  end

  def appunti_in_corso
    @appunti_in_corso = []
    @appunti_in_corso = sorted_appunti.select { |a| a.status != "completato" }
    @appunti_in_corso
  end

  def sorted_appunti
    @sorted_appunti = []
    orderAppunti = NSSortDescriptor.sortDescriptorWithKey("created_at", ascending:false)
    @sorted_appunti = cliente.appunti.sortedArrayUsingDescriptors([orderAppunti])
    @sorted_appunti
  end


  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    appunti_in_corso.count
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    95
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = self.tableView.dequeueReusableCellWithIdentifier("appuntoCell")
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.appunto = appunti_in_corso[indexPath.row]
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true) unless Device.ipad?
    cell = tableView.cellForRowAtIndexPath(indexPath)
    self.performSegueWithIdentifier("displayAppunto", sender:cell )
  end

  # Storyboard methods
  def prepareForSegue(segue, sender:sender)

    if segue.identifier.isEqualToString("displayAppunto")
      indexPath = self.tableView.indexPathForCell(sender)
      appunto = self.tableView.cellForRowAtIndexPath(indexPath).appunto
      segue.destinationViewController.presentedInPopover = true
      segue.destinationViewController.appunto = appunto
    
    elsif segue.identifier.isEqualToString("addAppunto")

      controller = segue.destinationViewController
      controller.isNew = true
      controller.presentedInPopover = true
      #controller.appunto = appunto
      controller.cliente = cliente
      
    end
  end


end