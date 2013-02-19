class ClientiTableViewController < UITableViewController
  
  extend IB

  attr_accessor :refreshHeaderView, :detailViewController

  outlet :searchBar

  def viewDidLoad
    super
    view.dataSource = view.delegate = self
    setupPullToRefresh
    setupSearchBar
    if Device.ipad?
      self.detailViewController = self.splitViewController.viewControllers.lastObject.topViewController
    end
    true
  end

  def viewWillAppear(animated)
    super
    view.reloadData
  end

  def setupPullToRefresh
    @refreshHeaderView ||= begin
      rhv = RefreshTableHeaderView.alloc.initWithFrame(CGRectMake(0, 0 - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
      rhv.delegate = self
      rhv.refreshLastUpdatedDate    
      tableView.addSubview(rhv)
      rhv
    end
  end

  def setupSearchBar
    offset = CGPointMake(0, self.searchBar.frame.size.height)
    self.tableView.contentOffset = offset
  end

  def loadFromBackend
    SVProgressHUD.show
    Store.shared.backend.getObjectsAtPath("api/v1/clienti",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  @clienti = result.array
                                                  tableView.reloadData
                                                  doneReloadingTableViewData
                                                  SVProgressHUD.dismiss
                                                end,
                                failure: lambda do |operation, error|
                                                  SVProgressHUD.showErrorWithStatus("#{error.localizedDescription}")
                                                end)
  end

  # Storyboard methods
  def prepareForSegue(segue, sender:sender)

    if segue.identifier.isEqualToString("displayCliente")
      if (self.searchDisplayController.isActive)
        indexPath = self.searchDisplayController.searchResultsTableView.indexPathForCell(sender)
        view.endEditing(true)
        cliente = self.searchDisplayController.searchResultsTableView.cellForRowAtIndexPath(indexPath).cliente
      else
        indexPath = self.tableView.indexPathForCell(sender)
        cliente = self.tableView.cellForRowAtIndexPath(indexPath).cliente
      end  
      if Device.ipad?
        segue.destinationViewController.visibleViewController.listController = self
        segue.destinationViewController.visibleViewController.openCliente(cliente)
      else
        segue.destinationViewController.openCliente(cliente)
      end  
    end
  end

  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    Cliente.reset  
    @searchString = searchString
    true
  end

  def fetchControllerForTableView(tableView)
    if tableView == self.tableView then Cliente.controller else Cliente.searchController(@searchString) end
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
    cell = self.tableView.dequeueReusableCellWithIdentifier("ClienteCell")
    cell ||= ClienteCell.alloc.initWithStyle(UITableViewCellStyleDefault,
                                            reuseIdentifier:"ClienteCell")
    
    cell.cliente = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)

    # if (tableView == self.tableView)
    #   cell.cliente = @clienti[indexPath.row]
    # else
    #   cell.cliente = @searchResults[indexPath.row]
    # end
    return cell



    # cell = tableView.dequeueReusableCellWithIdentifier(CellID) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CellID).tap do |c|
    #   c.accessoryType = UIDevice.ipad? ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator
    # end
    
    # cell.textLabel.text = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath).nome
    cell
  end

  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    # self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath).remove
    # tableView.updates do
    #   if tableView.numberOfRowsInSection(indexPath.section) == 1
    #     tableView.deleteSections(NSIndexSet.indexSetWithIndex(indexPath.section), withRowAnimation:UITableViewRowAnimationFade)
    #   end
    #   tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
    # end
  end
  

  # UITableViewController methods

  # def tableView(tableView, numberOfRowsInSection:section)
  #   if (tableView == self.tableView)
  #     @clienti.count
  #   else
  #     @searchResults.count;
  #   end
  # end

  # def tableView(tableView, cellForRowAtIndexPath:indexPath)
  #   cell = self.tableView.dequeueReusableCellWithIdentifier("ClienteCell")
  #   cell ||= ClienteCell.alloc.initWithStyle(UITableViewCellStyleDefault,
  #                                           reuseIdentifier:"ClienteCell")
  #   if (tableView == self.tableView)
  #     cell.cliente = @clienti[indexPath.row]
  #   else
  #     cell.cliente = @searchResults[indexPath.row]
  #   end
  #   return cell
  # end


  # # UISearchBar UISearchDisplayController methods
  # def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
  #   self.filterClientiForTerm(searchString);
  #   true
  # end

  # def searchDisplayControllerDidEndSearch(controller)
  #   view.reloadData
  #   #loadFromBackend
  # end

  # def filterClientiForTerm(text)
  #   @searchResults = @clienti.select do |c|
  #     index = "#{c.nome} #{c.comune} #{c.frazione}".downcase  
  #     condition = text.downcase
  #     index.include?( condition )
  #   end  
  #   view.reloadData
  # end




  ## PullToRefresh 

  def reloadTableViewDataSource
    @reloading = true
  end
  
  def doneReloadingTableViewData
    @reloading = false
    @refreshHeaderView.refreshScrollViewDataSourceDidFinishLoading(self.tableView)
  end
  
  def scrollViewDidScroll(scrollView)
    @refreshHeaderView.refreshScrollViewDidScroll(scrollView)
  end
  
  def scrollViewDidEndDragging(scrollView, willDecelerate:decelerate)
    @refreshHeaderView.refreshScrollViewDidEndDragging(scrollView)
  end
  
  def refreshTableHeaderDidTriggerRefresh(view)
    self.reloadTableViewDataSource
    self.performSelector('loadFromBackend', withObject:nil, afterDelay:0)
  end
    
  def refreshTableHeaderDataSourceIsLoading(view)
    @reloading
  end
  
  def refreshTableHeaderDataSourceLastUpdated(view)
    NSDate.date
  end


end
