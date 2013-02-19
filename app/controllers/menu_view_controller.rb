class MenuViewController < UITableViewController

  attr_accessor :detailViewController
  
  def viewDidLoad
    super
    if Device.ipad?
      self.detailViewController = self.splitViewController.viewControllers.lastObject.topViewController
    end
    true
  end

  def login(sender)
    Store.shared.login
  end


end