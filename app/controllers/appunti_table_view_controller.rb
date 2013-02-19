class AppuntiTableViewController < UITableViewController
  
  extend IB

  attr_accessor :refreshHeaderView

  outlet :searchBar

  def viewDidLoad
    super
    view.dataSource = view.delegate = self
    self.navigationItem.rightBarButtonItem = self.editButtonItem
    setupPullToRefresh
    setupSearchBar
    self.tableView.registerClass(AppuntoCell, forCellReuseIdentifier:"appuntoCell")
  end

  def viewDidAppear(animated)
    super
    Appunto.reset
    view.reloadData
  end

  def viewWillAppear(animated)
    super
    #loadFromBackend
  end

  # Storyboard methods
  def prepareForSegue(segue, sender:sender)

    if (self.searchDisplayController.isActive)
      indexPath = self.searchDisplayController.searchResultsTableView.indexPathForCell(sender)
      appunto = self.searchDisplayController.searchResultsTableView.cellForRowAtIndexPath(indexPath).appunto
    else
      indexPath = self.tableView.indexPathForCell(sender)
      appunto = self.tableView.cellForRowAtIndexPath(indexPath).appunto
    end
    
    puts "cliente_id #{appunto.ClienteId} appunto_id #{appunto.remote_id}"

    if segue.identifier.isEqualToString("displayAppunto")
      segue.destinationViewController.appunto = appunto

    elsif segue.identifier.isEqualToString("modalAppunto")
      segue.destinationViewController.visibleViewController.appunto = appunto
    end

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
    Store.shared.backend.getObjectsAtPath("api/v1/appunti",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  @appunti = result.array
                                                  tableView.reloadData
                                                  doneReloadingTableViewData
                                                  SVProgressHUD.dismiss
                                                end,
                                failure: lambda do |operation, error|
                                                  SVProgressHUD.showErrorWithStatus("#{error.localizedDescription}")
                                                end)
  end



  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    Appunto.reset  
    @searchString = searchString
    true
  end

  def fetchControllerForTableView(tableView)
    if tableView == self.tableView then Appunto.controller else Appunto.searchController(@searchString) end
  end

  # UITableViewDelegate

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
    cell = self.tableView.dequeueReusableCellWithIdentifier("appuntoCell")
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.appunto = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
    cell
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    95
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
  
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true) unless Device.ipad?
    cell = tableView.cellForRowAtIndexPath(indexPath)
    if Device.ipad?
      self.performSegueWithIdentifier("modalAppunto", sender:cell )
    else
      self.performSegueWithIdentifier("displayAppunto", sender:cell )
    end
  end

  # def tableView(tableView, commitEditingStyle:editing_style, forRowAtIndexPath:indexPath)
  #   if editing_style == UITableViewCellEditingStyleDelete
  #     editing_style = "UITableViewCellEditingStyleDelete"
  #     delete_appunto(self.tableView.cellForRowAtIndexPath(indexPath).appunto)
  #     @appunti.delete_at(indexPath.row)
  #     self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationAutomatic)
  #   end
  # end

  # def delete_appunto(appunto)
  #   puts "Deleting cliente #{appunto.remote_id}"
  #   App.delegate.backend.deleteObject(appunto, path:nil, parameters:nil,
  #                             success: lambda do |operation, result|
  #                                         puts "deleted"  
  #                                      end,
  #                             failure: lambda do |operation, error|
  #                                               App.alert error.localizedDescription
  #                                             end)
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