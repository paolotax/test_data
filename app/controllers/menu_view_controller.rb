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
    Store.shared.login {}
  end

  def importa(sender)
    Store.shared.clear
    Store.shared.login do
      puts "loggato"
      Store.shared.backend.getObjectsAtPath("api/v1/clienti",
                              parameters: nil,
                              success: lambda do |operation, result|
                                                puts "Clienti: #{result.array.count}"
                                                self.addAppunti
                                              end,
                              failure: lambda do |operation, error|
                                                puts error
                                              end)
    end
  end

  def addAppunti
    Store.shared.backend.getObjectsAtPath("api/v1/appunti",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Appunti: #{result.array.count}"
                                                  self.addLibri
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

  def addLibri
    Store.shared.backend.getObjectsAtPath("api/v1/libri",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Libri: #{result.array.count}"
                                                  self.addRighe
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

  def addRighe
    Store.shared.backend.getObjectsAtPath("api/v1/righe",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Righe: #{result.array.count}"
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

end