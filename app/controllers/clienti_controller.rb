class ClientiController < UIViewController
  
  extend IB

  attr_accessor :detailViewController, :refreshControl

  outlet :clientiTableView, UITableView

  def viewDidLoad
    super
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.addTarget(self, action:"loadFromBackend", forControlEvents:UIControlEventValueChanged)
    self.clientiTableView.addSubview(refreshControl)

    # non funzia
    self.clientiTableView.registerClass(ClienteCell, forCellReuseIdentifier:"clienteCell")

    # if Device.ipad?
    #   self.detailViewController = self.splitViewController.viewControllers.lastObject.topViewController
    # end
    true
  end


  def viewWillAppear(animated)
    super
    "clientiListDidLoadBackend".add_observer(self, :reload)
    "clientiListErrorLoadBackend".add_observer(self, :errorLoad)
    "errorLogin".add_observer(self, :errorLoad)
    reload
  end

  def viewWillDisappear(animated)
    super
    "clientiListDidLoadBackend".remove_observer(self, :reload)
    "clientiListErrorLoadBackend".remove_observer(self, :errorLoad)
    "errorLogin".remove_observer(self, :errorLoad)
  end
  
  def reload
    Cliente.reset
    self.clientiTableView.reloadData
    @refreshControl.endRefreshing
  end

  def errorLoad
    @refreshControl.endRefreshing
  end


  # Storyboard methods
  def prepareForSegue(segue, sender:sender)

    if segue.identifier.isEqualToString("displayCliente")

      if (self.searchDisplayController.isActive)
        indexPath = self.searchDisplayController.searchResultsTableView.indexPathForCell(sender)
        view.endEditing(true)
        cliente = self.searchDisplayController.searchResultsTableView.cellForRowAtIndexPath(indexPath).cliente
      else
        indexPath = self.clientiTableView.indexPathForCell(sender)
        cliente = self.clientiTableView.cellForRowAtIndexPath(indexPath).cliente
      end  
      if Device.ipad?
        segue.destinationViewController.visibleViewController.cliente = cliente
      else
        segue.destinationViewController.cliente = cliente
      end  
    end
  end

  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    Cliente.reset  
    @searchString = searchString
    true
  end

  def fetchControllerForTableView(tableView)
    if tableView == self.clientiTableView then Cliente.controller else Cliente.searchController(@searchString, nil) end
  end

  def numberOfSectionsInTableView(tableView)
    self.fetchControllerForTableView(tableView).sections.size
  end

  def tableView(tableView, titleForHeaderInSection:section)
    self.fetchControllerForTableView(tableView).sections[section].name
  end
  
  def tableView(tableView, numberOfRowsInSection:section)
    self.fetchControllerForTableView(tableView).sections[section].numberOfObjects
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = self.clientiTableView.dequeueReusableCellWithIdentifier("clienteCell")
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.cliente = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    cell = tableView.cellForRowAtIndexPath(indexPath)

    if Device.ipad?
      "pushClienteController".post_notification(self, cliente: cell.cliente)
    else  
      self.performSegueWithIdentifier("displayCliente", sender:cell )
    end
  end

  # def tableView(tableView, editingStyleForRowAtIndexPath:indexPath)
  #   if self.editing
  #     return UITableViewCellEditingStyleDelete
  #   else
  #     return UITableViewCellEditingStyleNone
  #   end
  # end

  # def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
  #   # self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath).remove
  #   # tableView.updates do
  #   #   if tableView.numberOfRowsInSection(indexPath.section) == 1
  #   #     tableView.deleteSections(NSIndexSet.indexSetWithIndex(indexPath.section), withRowAnimation:UITableViewRowAnimationFade)
  #   #   end
  #   #   tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
  #   # end
  # end

  private

    def loadFromBackend
      Store.shared.login do
        Store.shared.backend.getObjectsAtPath("api/v1/clienti",
                                    parameters: nil,
                                    success: lambda do |operation, result|
                                                      "clientiListDidLoadBackend".post_notification
                                                      @refreshControl.endRefreshing
                                                    end,
                                    failure: lambda do |operation, error|
                                                      "clientiListErrorLoadBackend".post_notification
                                                      App.alert("#{error.localizedDescription}")
                                                    end)
      end
    end

end
