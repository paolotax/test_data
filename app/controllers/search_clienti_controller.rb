class SearchClientiController < UITableViewController

  attr_accessor :delegate

  def viewDidLoad
    super
    self.title = "Cerca Clienti"
    self.tableView.registerClass(ClienteCell, forCellReuseIdentifier:"clienteCell")
    @searchString = ""
    true
  end

  def filter(searchString)
    @searchString = searchString
    Cliente.reset
    self.tableView.reloadData
  end
  
  def fetchControllerForTableView(tableView)
    Cliente.searchController(@searchString, nil)
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
    cell = tableView.dequeueReusableCellWithIdentifier("clienteCell")
    cell.cliente = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    cliente = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
    delegate.searchClientiController(self, didSelectCliente:cliente)
  end

end