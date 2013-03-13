class PopoverClienteController < UITableViewController

  extend IB

  attr_accessor :cliente, :appunti_in_corso

  def viewDidLoad
    super

    self.navigationItem.leftBarButtonItem = UIBarButtonItem.imaged('07-map-marker'.uiimage) {
      "reload_annotations".post_notification(self, cliente: cliente)
    }

    self.appunti_in_corso = []
    self.tableView.registerClass(AppuntoCell, forCellReuseIdentifier:"appuntoCell")
  end
  


  def viewWillAppear(animated)
    super
    self.tableView.reloadData
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

    indexPath = self.tableView.indexPathForCell(sender)
    appunto = self.tableView.cellForRowAtIndexPath(indexPath).appunto

    if segue.identifier.isEqualToString("displayAppunto")
      segue.destinationViewController.presentedAsModal = true
      segue.destinationViewController.appunto = appunto
    end

  end


end